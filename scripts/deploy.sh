#!/bin/bash

function dry_run {
	ENVIRONMENT=$(echo ${changes} | cut -d/ -f1)
	SQUAD=$(echo ${changes} | cut -d/ -f2)
	HELM_REPO=https://dventer.github.io/helm-chart
	LIST_NAMESPACE=$(yq e '.project[]' ${changes})
	kubectl get ns --no-headers | awk '{print $1}' > namespace
	cat namespace
	for namespace in ${LIST_NAMESPACE};do 
			if ! [[ $(grep -e "^${namespace}$" namespace) ]]; then
				helm upgrade --install namespace-rbac --repo ${HELM_REPO} namespace-rbac \
				--set squad=${SQUAD} --set environment=${ENVIRONMENT} --set project=${namespace} --set name=${namespace} \
				-n ${namespace} --create-namespace --wait --timeout 120s --dry-run;
			fi;
		done
}
function deploy {
	for namespace in ${LIST_NAMESPACE};do 
			if ! [[ $(grep -e "^${namespace}$" namespace) ]]; then
				helm upgrade --install namespace-rbac --repo ${HELM_REPO} namespace-rbac \
				--set squad=${SQUAD} --set environment=${ENVIRONMENT} --set project=${namespace} --set name=${namespace} \
				-n ${namespace} --create-namespace --wait --timeout 120s
				send_token $namespace;
			fi;
		done
}


#### Function for set VARIABLE in BITBUCKET_REPOSITORY ######
function send_token {
	while ! kubectl get secret -n $1 $1-$ENVIRONMENT-serviceaccount-token > /dev/null; do
		echo "wait for $1 secret..." && sleep 1;done
	SERVICE_ACCOUNT=$(kubectl get secret -n $1 $1-$ENVIRONMENT-serviceaccount-token -o jsonpath='{.data.token}')
	CA_CERT=$(kubectl get secret -n $1 $1-$ENVIRONMENT-serviceaccount-token -o jsonpath='{.data.ca\.crt}')
	ACCESS_TOKEN=$(curl -X POST -u "$OAUTH_KEY:$OAUTH_SECRET" https://bitbucket.org/site/oauth2/access_token -d grant_type=client_credentials | jq -r '.access_token')
	echo $ACCESS_TOKEN

	retry=0
	until [ $retry -gt 5 ] || [ -n $ACCESS_TOKEN ]
	do
		echo Retry: $retry
	((retry++))
	done

	curl --request POST -H "Authorization: Bearer $ACCESS_TOKEN" \
	--url "https://api.bitbucket.org/2.0/repositories/jefriadv/$1/pipelines_config/variables/" \
	--header 'Accept: application/json' \
	--header 'Content-Type: application/json' \
	--data '{
	"key": "SERVICE_ACCOUNT",
	"value": "'"${SERVICE_ACCOUNT}"'",
	"secured": true
	}'

	sleep 2 && printf "\n\n"

	curl --request POST -H "Authorization: Bearer $ACCESS_TOKEN" \
	--url "https://api.bitbucket.org/2.0/repositories/jefriadv/$1/pipelines_config/variables/" \
	--header 'Accept: application/json' \
	--header 'Content-Type: application/json' \
	--data '{
	"key": "CA_CERT",
	"value": "'"${CA_CERT}"'",
	"secured": true
	}'
}