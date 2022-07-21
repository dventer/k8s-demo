# set default shell
SHELL=/bin/bash -o pipefail -o errexit
ADMIN_TOKEN := $(shell echo "$$ADMIN_TOKEN" | base64 -d)

.PHONY: kubeconfig
kubeconfig:
	@kubectl config set-cluster default --server=${EKS_ADDRESS}
	@kubectl config set-credentials default --token ${ADMIN_TOKEN}
	@kubectl config set-context default --user=default --cluster=default
	@yq -i '.clusters[].cluster.certificate-authority-data = strenv(EKS_STAGING_CA)' /root/.kube/config
	@kubectl config use-context default

.PHONY: deploy
deploy:
	@source scripts/deploy.sh && deploy

.PHONY: plan
plan:
	@source scripts/deploy.sh && dry_run

