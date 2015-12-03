#!/bin/bash

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
  rsync -arz --delete-after /conf/pending/$GIT_PATH/* /conf/active/
  ls -r /conf/active
  ls -r /etc/bind
  rndc reload
}

function get_updates_from_github() {

  git_result=$(echo -n `git pull`) 
  if [  "$git_result" = "Already up-to-date." ]; then
    #already current, return false
    return 1
  else
    #time to update, return true
    return 0
  fi
}


function get_updates_from_url() {
  wget -nd -r -nc -np -e robots=off -R "index.html*" $URL
  if config_changed; then
    return 0
  else
    return 1
  fi
}

while true; do
  cd /conf/pending/
  get_updates
  sleep $REFRESH
done
