# set default shell
SHELL=/bin/bash -o pipefail -o errexit
TAG ?= $(shell git rev-parse --short origin/master)
REGISTRY=venter
APP=sample-app
CHART=sample-deployment

.PHONY: build
build: ## Build docker image
	echo "Building docker image ..."
	@docker build ./${APP} -t ${REGISTRY}/${APP}:$(TAG) -f ${APP}/Dockerfile


.PHONY: push
push:
	docker push ${REGISTRY}/${APP}:${TAG}

.PHONY: deploy
deploy:
	@helm upgrade --install ${APP} charts/${CHART} \
	--set image.repository=${REGISTRY}/${APP} \
	--set image.tag=${TAG} -n ${APP} --set project=${APP} --set environment=staging --squad=data

.PHONY: rollback
rollback: 
	@helm rollback ${APP} -n ${APP}