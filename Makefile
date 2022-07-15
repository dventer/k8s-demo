# set default shell
SHELL=/bin/bash -o pipefail -o errexit
TAG := $(shell git rev-parse --short origin/master)
REGISTRY=venter
APP=sample-app
CHART=sample-deployment

.PHONY: build
build: ## Build docker image
	echo "Building docker image ..."
	@docker build ./${APP} -t ${REGISTRY}/${APP}:$(TAG) -f ${APP}/Dockerfile


.PHONY: push
push:
	docker push ${REGISTRY}/${APP}:$(TAG)

.PHONY: kubeconfig
kubeconfig:
	@kubectl config set-cluster eks-staging --server=https://5EA22ED7B31D18E08DA9BFD2B0AB5A11.gr7.ap-southeast-1.eks.amazonaws.com \
	--certificate-authority=/tmp/ca.crt --embed-certs
	@kubectl config set-credentials sample-app --token ${SA_TOKEN}
	@kubectl config set-context sample-app --user=sample-app
	@kubectl config use-context sample-app
.PHONY: deploy
deploy:
	@helm upgrade --install ${APP} charts/${CHART} \
	--set image.repository=${REGISTRY}/${APP} \
	--set image.tag=${TAG} -n ${APP} --set project=${APP} --set environment=staging --squad=data

.PHONY: rollback
rollback: 
	@helm rollback ${APP} -n ${APP}