.PHONY: build push run

build:
	@docker build -f Dockerfile.alpine --rm -t factual/s3-backed-ftp:alpine .

push:
	@docker push factual/s3-backed-ftp:alpine

run: build
	@docker run -d \
	--restart always \
	-p 21-22:21-22 \
	-p 30000-30100:30000-30100 \
	--memory 2G \
	--env-file env.list \
	--volume /etc/ssh/ssh_host_ed25519_key:/etc/ssh/ssh_host_ed25519_key \
	--volume /etc/ssh/ssh_host_ed25519_key.pub:/etc/ssh/ssh_host_ed25519_key.pub \
	--volume /etc/ssh/ssh_host_rsa_key:/etc/ssh/ssh_host_rsa_key \
	--volume /etc/ssh/ssh_host_rsa_key.pub:/etc/ssh/ssh_host_rsa_key.pub \
	--cap-add SYS_ADMIN \
	--cap-add MKNOD \
	--device /dev/fuse \
	--security-opt apparmor=unconfined \
	--name "s3fs-alpine" \
	factual/s3-backed-ftp:alpine
