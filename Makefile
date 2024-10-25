VERSION := 2.18.0
DATE := $(shell date +"%Y-%m-%d")
IMAGE := us-docker.pkg.dev/jarvice/images/tensorflow:$(VERSION)-$(DATE)

all:
	podman build --pull --rm -f "Dockerfile" -t $(IMAGE) "."

push: all
	podman push $(IMAGE)
