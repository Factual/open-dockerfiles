.PHONY: build run

build:
	@docker build -f Dockerfile.alpine --rm -t factual/s3-backed-ftp:alpine .

run: build
	@docker run -d \
	--restart=always \
	-p 21-22:21-22 \
	-p 30000-30100:30000-30100 \
	--env-file env.list \
	--cap-add SYS_ADMIN \
	--cap-add MKNOD \
	--device /dev/fuse \
	--security-opt apparmor=unconfined \
	factual/s3-backed-ftp:alpine
