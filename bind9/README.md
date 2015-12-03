# bind9 (named) in a docker

This image fetches its config from github or a url path and does a graceful reload when the config changes.  As a result, it can be part of a highly available but independent set of dns servers.

## Running


### Github Checkout Example

```bash
docker run --restart=always --name bind9 -e GITHUB_REPO="git@github.com:Factual/some-repo-where-we-keep-configs.git" -e GITHUB_SSH_KEY="`cat ~/.ssh/my_deploy_key`" -e GIT_PATH="/bind9" -e REFRESH=60 factual/bind9
```

### URL Example

```bash
docker run --restart=always --name bind9 -e -e URL="https://my-config-files.factual.com/services/bind9/" -e REFRESH=60 factual/bind9
```

## Environment Variables

- GITHUB_REPO
- GITHUB_SSH_KEY 
- GIT_PATH
- URL
- REFRESH (default: 300)
