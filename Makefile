VERSION := 2.20.0
DATE := $(shell date +"%Y-%m-%d")
IMAGE := us-docker.pkg.dev/jarvice/images/tensorflow:$(VERSION)-$(DATE)

all:
	docker build --pull --rm -f "Dockerfile" -t $(IMAGE) "."

push: all
	docker push $(IMAGE)
