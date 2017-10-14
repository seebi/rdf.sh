export CONTAINER_NAME=seebi-rdf.sh
export KILLTIMEOUT=10
TIME_STAMP=$(shell date --iso-8601=seconds)

# git investigation
export GITBRANCH?=$(shell git rev-parse --abbrev-ref HEAD)
# same for git describe
export GITDESCRIBE?=$(shell git describe --always --dirty)

export IMAGE_NAME=${CONTAINER_NAME}:${GITDESCRIBE}

# create the main tag (latest / develop / unknown)
export TAG_SUFFIX=$(subst /,_,$(GITBRANCH))
ifeq ($(GITBRANCH), master)
	export TAG_SUFFIX=latest
endif

# add an additional tag based on branch name (master -> latest)
export TAG_BRANCH=${CONTAINER_NAME}:${TAG_SUFFIX}

# add primary tag based on git versioning
export TAG_VERSION=${CONTAINER_NAME}:${GITDESCRIBE}

export DOCKER_CMD=docker

LS_BUILD_DATE=--label "org.label-schema.build-date=${TIME_STAMP}"
LS_VCS_REF=--label "org.label-schema.vcs-ref=${GITDESCRIBE}"
LS_VERSION=--label "org.label-schema.version=${TAG_VERSION}"
LABEL_SCHEMA=${LS_BUILD_DATE} ${LS_VCS_REF} ${LS_VERSION}

check: tests
	shellcheck rdf */*.sh

TESTS ?= $(shell cd tests; echo *_test.sh)
tests: ${TESTS}
%_test.sh:
	cd tests; shunit2/shunit2 $@

## build the image based on docker file and latest repository
build-image:
	$(DOCKER_CMD) build -t ${IMAGE_NAME} ${LABEL_SCHEMA} .

## start a container which deletes automatically
test-image:
	$(DOCKER_CMD) run -i -t --name=${CONTAINER_NAME} --rm ${IMAGE_NAME}

## inspect the image by starting a shell session in a self-destructing container
shell-on-image: 
	$(DOCKER_CMD) run -i -t --rm ${IMAGE_NAME} sh

## tag the local image with a registry tag
tag-image:
	$(DOCKER_CMD) tag ${IMAGE_NAME} ${TAG_VERSION}
	$(DOCKER_CMD) tag ${IMAGE_NAME} ${TAG_BRANCH}

## push the local image to the registry
push-image: tag
	$(DOCKER_CMD) push ${TAG_VERSION}
	$(DOCKER_CMD) push ${TAG_BRANCH}

## pull the image from the registry and tag it in order to use other targets
pull-image:
	$(DOCKER_CMD) pull ${TAG_BRANCH}
	$(DOCKER_CMD) tag ${TAG_BRANCH} ${IMAGE_NAME}
	$(DOCKER_CMD) tag ${TAG_BRANCH} ${TAG_VERSION}

## show this help screen
help:
	@printf "Available targets\n\n"
	@awk '/^[a-zA-Z\-\_0-9]+:/ { \
		helpMessage = match(lastLine, /^## (.*)/); \
		if (helpMessage) { \
			helpCommand = substr($$1, 0, index($$1, ":")-1); \
			helpMessage = substr(lastLine, RSTART + 3, RLENGTH); \
			printf "%-15s %s\n", helpCommand, helpMessage; \
		} \
	} \
	{ lastLine = $$0 }' $(MAKEFILE_LIST)
