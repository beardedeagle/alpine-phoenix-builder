.PHONY: help test iex shell build clean rebuild release
.NOTPARALLEL: rebuild release

VERSION ?= `cat VERSION`
MAJ_VERSION := $(shell echo $(VERSION) | sed 's/\([0-9][0-9]*\)\.\([0-9][0-9]*\)\(\.[0-9][0-9]*\)*/\1/')
MIN_VERSION := $(shell echo $(VERSION) | sed 's/\([0-9][0-9]*\)\.\([0-9][0-9]*\)\(\.[0-9][0-9]*\)*/\1.\2/')
IMAGE_NAME ?= beardedeagle/alpine-phoenix-builder

## Print out Docker image name and version
help:
	@echo "$(IMAGE_NAME):$(VERSION)"
	@perl -nle'print $& if m{^[a-zA-Z_-]+:.*?## .*$$}' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

## Test the Docker image
test:
	docker run --rm -it $(IMAGE_NAME):$(VERSION) elixir -version

## Run an iex shell in the image
iex:
	docker run --rm -it $(IMAGE_NAME):$(VERSION) iex --erl "+K true"

## Boot to a shell prompt
shell:
	docker run --rm -it $(IMAGE_NAME):$(VERSION) /bin/bash

## Build the Docker image
build:
	docker build --force-rm -t $(IMAGE_NAME):$(VERSION) -t $(IMAGE_NAME):$(MIN_VERSION) -t $(IMAGE_NAME):$(MAJ_VERSION) -t $(IMAGE_NAME):latest .

## Clean up generated images
clean:
	@docker rmi --force $(IMAGE_NAME):$(VERSION) $(IMAGE_NAME):$(MIN_VERSION) $(IMAGE_NAME):$(MAJ_VERSION) $(IMAGE_NAME):latest

## Rebuild the Docker image
rebuild: clean build

## Rebuild and release the Docker image to Docker Hub
release: build
	docker push $(IMAGE_NAME):$(VERSION)
	docker push $(IMAGE_NAME):$(MIN_VERSION)
	docker push $(IMAGE_NAME):latest
