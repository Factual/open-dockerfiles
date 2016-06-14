# isc-dhcp in a docker

This image will fetch all dhcp config files from github or a url path and reload when it detects changes.

If checking out from Github you can perform a sparse checkout of the repo by supplying a `GIT_PATH` environment variable. This will be the directory checked out from the Github repo.

If you want to specify an interface besides `eth0` or in addition to `eth0` set the `INTERFACES` environmnet variable to all the interfaces you want the server to listen on. The `INTERFACES` variable should be a space separated list of interface names.

# Running
## Github checkout Example
```
docker run --restart=always --name isc-dhcp -e GITHUB_REPO="git@github.com:Factual/some-repo-where-we-keep-configs.git" -e GITHUB_SSH_KEY="`cat ~/.ssh/my_deploy_key`" -e GIT_PATH="/isc-dhcp" -e INTERFACES="eth0 eth1" -e REFRESH=300 factual/isc-dhcp
```

## URL Example
```
docker run --restart=always --name isc-dhcp -e URL="https://my-config-files.factual.com/services/isc-dhcp/" -e REFRESH=300 factual/isc-dhcp
```

# Env Variables

### Github Sync
  - GITHUB_REPO
  - GITHUB_SSH_KEY
  - GIT_PATH
  - GIT_BRANCH (default: master)

### URL Sync
  - URL

### Common
  - REFRESH (default: 300)
  - INTERFACES (default: eth0)
