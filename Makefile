# set default shell
SHELL=/bin/bash -o pipefail -o errexit
TAG ?= $(shell git rev-parse --short origin/master)
REGISTRY=venter
APP=sample-app
CHART=sample-deployment

.PHONY: build
build: ## Build docker image
	echo "Building docker image ..."
	@docker build -t ${REGISTRY}/${APP}:$(TAG) .


.PHONY: push
push:
	docker push ${REGISTRY}/${APP}:${TAG}

.PHONY: deploy
deploy:
	@helm upgrade --install ${APP} charts/${CHART} \
	--set image.repository=${REGISTRY}/${APP} \
	--set image.tag=${TAG} -n ${APP}

.PHONY: rollback
rollback: 
	@helm rollback ${APP} -n ${APP}