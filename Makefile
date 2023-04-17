#
# MIT License
#
# (C) Copyright 2022-2023 Hewlett Packard Enterprise Development LP
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

ifeq ($(DOCKER_BUILDKIT),)
export DOCKER_BUILDKIT ?= 1
endif

ifeq ($(BUILD_ARGS),)
export BUILD_ARGS ?= "--build-arg 'SLE_VERSION=${SLE_VERSION}' --secret id=SLES_REGISTRATION_CODE_amd64 --secret id=SLES_REGISTRATION_CODE_arm64"
endif

ifeq ($(SLE_VERSION),)
export SLE_VERSION := $(shell awk -F ':' '/^FROM/{print $$NF; exit}' Dockerfile | awk '{print $$1}')
endif

ifeq ($(TIMESTAMP),)
export TIMESTAMP := $(shell date '+%Y%m%d%H%M%S')
endif

ifeq ($(VERSION),)
export VERSION ?= $(shell git rev-parse --short HEAD)
endif

all: image

.PHONY: print
print:
	@printf "%-20s: %s\n" Name $(NAME)
	@printf "%-20s: %s\n" DOCKER_BUILDKIT $(DOCKER_BUILDKIT)
	@printf "%-20s: %s\n" 'SLE Version' $(SLE_VERSION)
	@printf "%-20s: %s\n" Timestamp $(TIMESTAMP)
	@printf "%-20s: %s\n" Version $(VERSION)

image: print
	docker buildx create --use
	docker buildx build --platform=linux/amd64,linux/arm64 --secret id=SLES_REGISTRATION_CODE --pull ${DOCKER_ARGS} .
	docker buildx build --platform linux/amd64 --load -t '${NAME}:${VERSION}' .
	docker buildx build --platform linux/amd64 --load -t '${NAME}:${VERSION}-${TIMESTAMP}' .
	docker buildx build --platform linux/amd64 --load -t '${NAME}:${SLE_VERSION}' .
	docker buildx build --platform linux/amd64 --load -t '${NAME}:${SLE_VERSION}-${VERSION}' .
	docker buildx build --platform linux/amd64 --load -t '${NAME}:${SLE_VERSION}-${VERSION}-${TIMESTAMP}' .
