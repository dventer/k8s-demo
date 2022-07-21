FROM alpine:3.16.1

ENV  TERRAFORM_VERSION=1.1.7 \
     YQ_VERSION=4.14.1 \
     KUBECTL_VERSION=1.24.3 \
     HELM_VERSION=3.7.1 \
     HELM_DIFF_VERSION=3.1.3 

RUN  apk add --no-cache openssl git bash curl gettext jq && \
     curl -L https://github.com/mikefarah/yq/releases/download/v${YQ_VERSION}/yq_linux_amd64 -o /usr/bin/yq && \
     chmod 0755 /usr/bin/yq && \
     curl -L https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip | busybox unzip -p - > /usr/bin/terraform && \
     chmod 0755 /usr/bin/terraform && \
     curl -L https://storage.googleapis.com/kubernetes-release/release/v${KUBECTL_VERSION}/bin/linux/amd64/kubectl -o /usr/bin/kubectl && \
     chmod 0755 /usr/bin/kubectl && \
     curl -L https://get.helm.sh/helm-v${HELM_VERSION}-linux-amd64.tar.gz | tar zxO linux-amd64/helm > /usr/bin/helm && \
     chmod 0755 /usr/bin/helm && \
     mkdir -p ${HOME}/.local/share/helm/plugins/helm-diff/bin && \
     curl -L https://raw.githubusercontent.com/databus23/helm-diff/v${HELM_DIFF_VERSION}/plugin.yaml | yq eval 'del(.hooks)' - > ${HOME}/.local/share/helm/plugins/helm-diff/plugin.yaml && \
     curl -L https://github.com/databus23/helm-diff/releases/download/v${HELM_DIFF_VERSION}/helm-diff-linux.tgz | tar zxO diff/bin/diff > ${HOME}/.local/share/helm/plugins/helm-diff/bin/diff && \
     chmod 0755 ${HOME}/.local/share/helm/plugins/helm-diff/bin/diff
