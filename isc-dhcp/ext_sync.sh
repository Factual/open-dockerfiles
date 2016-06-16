#!/bin/bash

set -e

REFRESH=${REFRESH:-300}

function config_changed() {
  res=$(diff -qr /conf/pending/ /conf/active/)
  if [ -n "$res" ]; then
    return 0
  else
    return 1
  fi
}

function get_updates() {
  if [ -n "$GITHUB_REPO" ]; then
    get_updates_from_github && sync_and_reload
  elif [ -n "$URL" ]; then
    get_updates_from_url && sync_and_reload
  fi
}

function sync_and_reload() {
  mv /conf/active /conf/backup
  mkdir -p /conf/active
  cp -r /conf/pending/"$GIT_PATH"/* /conf/active
  echo "Validating config and reloading..."
  if config_valid; then
    echo "Config valid. Reloading..."
    /etc/init.d/isc-dhcp-server restart
    rm -r /conf/backup
  else
    echo "Config NOT valid. Reverting..."
    mv /conf/backup/* /conf/active
    rm -r /conf/backup
  fi
}

function get_updates_from_github() {
  git_result=$(echo -n "$(git pull)")
  if [ "$git_result" = "Already up-to-date." ]; then
    return 1
  else
    return 0
  fi
}

function config_valid() {
  /usr/sbin/dhcpd -t -cf /etc/dhcp/dhcpd.conf
}

function get_updates_from_url() {
  wget -nd -r -nc -e robots=off -R "index.html*" "$URL"
  if config_changed; then
    return 0
  else
    return 1
  fi
}

sleep 20

while true; do
  cd /conf/pending
  get_updates
  sleep "$REFRESH"
done

