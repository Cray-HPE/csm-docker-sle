#
# MIT License
#
# (C) Copyright 2022-2024 Hewlett Packard Enterprise Development LP
#
# Permission is hereby granted, free of charge, to any person obtaining a
# copy of this software and associated documentation files (the "Software"),
# to deal in the Software without restriction, including without limitation
# the rights to use, copy, modify, merge, publish, distribute, sublicense,
# and/or sell copies of the Software, and to permit persons to whom the
# Software is furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included
# in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
# THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR
# OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,
# ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
# OTHER DEALINGS IN THE SOFTWARE.
#
ifeq ($(NAME),)
export NAME := $(shell basename $(shell pwd))
endif

ifeq ($(SLE_VERSION),)
export SLE_VERSION := $(shell awk -F ':' '/^FROM/{print $$NF; exit}' Dockerfile | awk '{print $$1}')
endif

ifeq ($(DOCKER_BUILDKIT),)
export DOCKER_BUILDKIT ?= 1
endif

ifeq ($(DOCKER_LOCAL_PLATFORM),)
export DOCKER_LOCAL_PLATFORM := $(shell docker version --format '{{.Server.Os}}/{{.Server.Arch}}')
endif

ifeq ($(DOCKER_PLATFORMS),)
export DOCKER_PLATFORMS ?= 'linux/amd64,linux/arm64,$(DOCKER_LOCAL_PLATFORM)'
endif

ifeq ($(BUILD_CACHE),)
export BUILD_CACHE ?= 'docker-build-cache'
endif

ifeq ($(DOCKER_BUILDER),)
DOCKER_BUILDER := $(shell docker buildx create --platform $(DOCKER_LOCAL_PLATFORM) --name $(BUILD_CACHE))
endif

ifeq ($(BUILD_ARGS),)
export BUILD_ARGS ?= --build-arg 'SLE_VERSION=${SLE_VERSION}' --secret id=SLES_REGISTRATION_CODE --builder $(BUILD_CACHE)
endif

ifeq ($(TIMESTAMP),)
export TIMESTAMP := $(shell date '+%Y%m%d%H%M%S')
endif

ifeq ($(VERSION),)
export VERSION ?= $(shell git rev-parse --short HEAD)
endif

.PHONY: all image print

all: image

print:
	@printf "%-20s: %s\n" Name $(NAME)
	@printf "%-20s: %s\n" DOCKER_BUILDKIT $(DOCKER_BUILDKIT)
	@printf "%-20s: %s\n" 'SLE Version' $(SLE_VERSION)
	@printf "%-20s: %s\n" Timestamp $(TIMESTAMP)
	@printf "%-20s: %s\n" Version $(VERSION)
	@printf "%-20s: %s\n" 'Docker Platforms' $(DOCKER_PLATFORMS)

image: print
    # For multi-platform builds. Leaves images in the local cache only
	docker buildx build \
		$(BUILD_ARGS) \
		${DOCKER_ARGS} \
		--platform $(DOCKER_PLATFORMS) \
		--cache-to type=local,dest=$(BUILD_CACHE) \
		--pull \
		.

    # Tags and loads the image for the local build architecture
	docker buildx build \
		$(BUILD_ARGS) \
		${DOCKER_ARGS} \
		--platform $(DOCKER_LOCAL_PLATFORM) \
		--cache-from type=local,src=$(BUILD_CACHE) \
		--pull \
		--load \
		-t '${NAME}:${SLE_VERSION}-${VERSION}-${TIMESTAMP}' \
		.
