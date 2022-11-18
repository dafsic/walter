SHELL=/usr/bin/env bash

PROJECT:=github.com/dafsic/walter

GO_VERSION:=$(shell go version)
BUILD_TIME:=$(shell date +%Y-%m-%dT%H:%M:%S%z)
COMMIT_HASH:=$(shell git rev-parse --short=8 HEAD || echo unknown)
#COMMIT_HASH:=$(shell git log --pretty=format:"%h" -1)
GIT_BRANCH:=$(shell git rev-parse --abbrev-ref HEAD)
GIT_TAG:=$(shell git describe --tags `git rev-list --tags --max-count=1`)

GO_LDFLAGS += -X '$(PROJECT)/version.BUILD_TIME=$(BUILD_TIME)'
GO_LDFLAGS += -X '$(PROJECT)/version.GO_VERSION=$(GO_VERSION)'
GO_LDFLAGS += -X '$(PROJECT)/version.COMMIT_HASH=$(COMMIT_HASH)'
GO_LDFLAGS += -X '$(PROJECT)/version.GIT_BRANCH=$(GIT_BRANCH)'
GO_LDFLAGS += -X '$(PROJECT)/version.PROJECT_VERSION=$(GIT_TAG)'
GO_LDFLAGS += -s -w

.PHONY: default water clean check

default: check water ## Build the default binary file

check: ## Check working tree is clean or not
ifneq ($(shell git status -s),)
	$(error You must run git commit)
endif

water: ## Build the water blockchain daemon
	rm -f water
	GOOS=linux GOARCH=amd64 CGO_ENABLE=0 go build -ldflags "$(GO_LDFLAGS)" -o water ./cmd/daemon

water-cli: ## Build the clinet
	rm -f water-cli
	GOOS=linux GOARCH=amd64 CGO_ENABLE=0 go build -ldflags "$(GO_LDFLAGS)" -o water-cli ./cmd/client

clean: ## Remove previous build
	go clean

help: ## Display this help screen
	@grep -h -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'