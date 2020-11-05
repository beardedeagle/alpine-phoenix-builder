.PHONY: help version test iex shell build clean rebuild release
.NOTPARALLEL: build rebuild release
.DEFAULT_GOAL := help

VERSION ?= `cat VERSION`
MIN_VERSION := $(shell echo $(VERSION) | sed 's/\([0-9][0-9]*\)\.\([0-9][0-9]*\)\(\.[0-9][0-9]*\)*/\1.\2/')
IMAGE_NAME ?= beardedeagle/alpine-phoenix-builder

help: ## Show this message
	@echo "$(IMAGE_NAME):$(VERSION)"
	@echo
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-15s\033[0m %s\n", $$1, $$2}'

version: ## Show Makefile version
	@echo -e 'Elixir version: $(shell echo $(VERSION))'
	@echo -e 'Maintainer: beardedeagle <randy@heroictek.com>'
	@echo -e 'Last modified: 2020-11-05'

test: ## Test Docker image
	@docker run --rm -it $(IMAGE_NAME):$(VERSION) elixir --version

iex: ## Run iex shell in Docker image
	@docker run --rm -it $(IMAGE_NAME):$(VERSION) iex

shell: ## Boot to shell prompt in Docker image
	@docker run --rm -it $(IMAGE_NAME):$(VERSION) /bin/bash

build: ## Build Docker images
	@docker build --force-rm -t $(IMAGE_NAME):$(VERSION) -t $(IMAGE_NAME):$(MIN_VERSION) -t $(IMAGE_NAME):latest .

clean: ## Clean up generated Docker images
	@docker rmi --force $(IMAGE_NAME):$(VERSION) $(IMAGE_NAME):$(MIN_VERSION) $(IMAGE_NAME):latest

rebuild: clean build ## Rebuild Docker images

release: build ## Build and release Docker images to Docker Hub
	@docker push $(IMAGE_NAME):$(VERSION)
	@docker push $(IMAGE_NAME):$(MIN_VERSION)
	@docker push $(IMAGE_NAME):latest
