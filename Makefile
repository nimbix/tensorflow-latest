all:
	DOCKER_BUILDKIT=1 docker build --pull --rm -f "Dockerfile" -t us-docker.pkg.dev/jarvice/images/tensorflow:2.13.0 "."

push: all
	docker push us-docker.pkg.dev/jarvice/images/tensorflow:2.13.0
