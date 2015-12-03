#!/bin/bash
GIT_BRANCH=${GIT_BRANCH:-"master"}


function prepare_once() {
  mkdir -p /conf/active/
  mkdir -p /conf/pending/
  ln -s /conf/active /etc/bind
  cd /conf/pending/
  if [ -n "$GITHUB_REPO" ]; then
    prepare_once_github
  elif [ -n "$URL" ]; then
    prepare_once_url
  fi
  rsync -arz --delete-after /conf/pending/$GIT_PATH/* /conf/active/
  return 0
}

function prepare_once_github() {
  echo "$GITHUB_SSH_KEY" > ~/.ssh/github_key && chmod 600 ~/.ssh/github_key
  if [ -z "$GIT_PATH" ]; then
    git clone $GITHUB_REPO --branch $GIT_BRANCH --single-branch .
  else
    git clone -n $GITHUB_REPO --branch $GIT_BRANCH --single-branch .
    git config core.sparseCheckout true
    echo "$GIT_PATH" >> .git/info/sparse-checkout
    git checkout $GIT_BRANCH
  fi
}

function prepare_once_url() {
  return 0
}

echo "Initializing..."
prepare_once && echo "Done with initialization."

echo "Starting named"
/usr/sbin/named -g -c /etc/bind/named.conf -u bind
