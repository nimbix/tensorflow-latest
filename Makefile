VERSION := 2.21.0
DATE := $(shell date +"%Y-%m-%d")
IMAGE := us-docker.pkg.dev/jarvice/images/tensorflow:$(VERSION)-$(DATE)

all:
	docker build --pull --rm -f "Dockerfile" -t $(IMAGE) --build-arg TENSOR_VERSION=$(VERSION) "."

push: all
	docker push $(IMAGE)
