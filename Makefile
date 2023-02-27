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

ifeq ($(GO_VERSION),)
export GO_VERSION := $(shell awk -v replace="'" '/goVersion/{gsub(replace,"", $$NF); print $$NF; exit}' Jenkinsfile.github)
endif

ifeq ($(TIMESTAMP),)
export TIMESTAMP := $(shell date '+%Y%m%d%H%M%S')
endif

ifeq ($(VERSION),)
export VERSION ?= $(shell git rev-parse --short HEAD)
endif

all: image

image:
	docker build --secret id=SLES_REGISTRATION_CODE --pull ${DOCKER_ARGS} --tag '${NAME}:${VERSION}' .
	docker tag '${NAME}:${VERSION}' ${NAME}:${VERSION}-${TIMESTAMP}
	docker tag '${NAME}:${VERSION}' ${NAME}:${SLES_VERSION}
	docker tag '${NAME}:${VERSION}' ${NAME}:${SLES_VERSION}-${VERSION}
	docker tag '${NAME}:${VERSION}' ${NAME}:${SLES_VERSION}-${VERSION}-${TIMESTAMP}
