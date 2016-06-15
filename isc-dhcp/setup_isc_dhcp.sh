#!/bin/bash

set -e

GIT_BRANCH="${GIT_BRANCH:-master}"
INTERFACES="${INTERFACES:-eth0}"

function prepare_once() {
  mkdir -p /conf/active/
  mkdir -p /conf/pending/
  ln -s /conf/active /etc/dhcp
  cd /conf/pending/
  if [ -n "$GITHUB_REPO" ]; then
    # Use github repo
    prepare_once_github
  elif [ -n "$URL" ]; then
    # Use a url
    prepare_once_url
  else
    echo "No repo or URL supplied" && exit 1
  fi
  rsync -arz --delete-after /conf/pending/"$GIT_PATH"/* /conf/active/
  return 0
}

function prepare_once_github() {
  echo "$GITHUB_SSH_KEY" > ~/.ssh/github_key && chmod 600 ~/.ssh/github_key
  if [ -z "$GIT_PATH" ]; then
    # If no git_path is set checkout whole repo
    git clone "$GITHUB_REPO" --branch "$GIT_BRANCH" --single-branch .
  else
    # If git_path is set do sparse checkout of directory we want
    git clone -n "$GITHUB_REPO" --branch "$GIT_BRANCH" --single-branch .
    git config core.sparseCheckout true
    echo "$GIT_PATH" >> .git/info/sparse-checkout
    git checkout "$GIT_BRANCH"
  fi
}

function prepare_one_url() {
  return 0
}

echo "Initializing..."
sed -i "s/INTERFACES=\"\"/INTERFACES=\"$INTERFACES\"/g" /etc/default/isc-dhcp-server && echo -e "\nSetting interfaces to: $INTERFACES\n"
[[ -z "$GIT_PATH" ]] && echo "GIT_PATH not set...checking out whole git repo"
[[ ! -z "$GIT_PATH" ]] && echo "GIT_PATH set...checking out directory $GIT_PATH in $GITHUB_REPO"
prepare_once && echo "Done with initialization"
chown -R dhcpd:dhcpd /etc/dhcp

