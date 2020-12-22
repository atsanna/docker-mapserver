DOCKER_TAG ?= latest
export DOCKER_TAG
MAPSERVER_BRANCH ?= master
WITH_ORACLE ?= OFF
DOCKER_IMAGE = camptocamp/mapserver
ROOT = $(dir $(realpath $(firstword $(MAKEFILE_LIST))))
GID = $(shell id -g)
UID = $(shell id -u)

all: acceptance

.PHONY: pull
pull:
	for image in `find -name Dockerfile | xargs grep --no-filename ^FROM | awk '{print $$2}'`; do docker pull $$image; done

.PHONY: build
build:
	docker build --tag=$(DOCKER_IMAGE):$(DOCKER_TAG) --target=runner --build-arg=MAPSERVER_BRANCH=$(MAPSERVER_BRANCH) --build-arg=WITH_ORACLE=$(WITH_ORACLE) .

.PHONY: acceptance
acceptance: build
	(cd acceptance_tests/ && docker-compose up -d)
	(cd acceptance_tests/ && docker-compose exec -T acceptance bash -c 'cd /acceptance_tests ; py.test -vv --color=yes --junitxml /tmp/junitxml/results.xml')
	(cd acceptance_tests/ && docker-compose down)

.PHONY: clean
clean:
	rm -rf acceptance_tests/junitxml/
