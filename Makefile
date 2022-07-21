# set default shell
SHELL=/bin/bash -o pipefail -o errexit
ADMIN_TOKEN := $(shell echo "$$ADMIN_TOKEN" | base64 -d)

.PHONY: kubeconfig
kubeconfig:
	@kubectl config set-cluster default --server=https://5EA22ED7B31D18E08DA9BFD2B0AB5A11.gr7.ap-southeast-1.eks.amazonaws.com
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

