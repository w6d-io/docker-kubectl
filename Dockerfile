FROM ubuntu:21.10
ARG VCS_REF
ARG BUILD_DATE
ARG VERSION
ARG USER_EMAIL="david.alexandre@w6d.io"
ARG USER_NAME="David ALEXANDRE"
LABEL maintainer="${USER_NAME} <${USER_EMAIL}>" \
        org.label-schema.vcs-ref=$VCS_REF \
        org.label-schema.vcs-url="https://github.com/w6d-io/docker-kubectl" \
        org.label-schema.build-date=$BUILD_DATE \
        org.label-schema.version=$VERSION

ENV DESIRED_VERSION=$DESIRED_VERSION \
    DEBIAN_FRONTEND=noninteractive
RUN apt update && apt install -y apt-transport-https ca-certificates gnupg openssl bash gettext git curl jq make coreutils gawk python3 python3-pip && \
    echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] http://packages.cloud.google.com/apt cloud-sdk main" | tee -a /etc/apt/sources.list.d/google-cloud-sdk.list && \
    curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key --keyring /usr/share/keyrings/cloud.google.gpg  add - && \
    apt-get update -y && \
    apt-get install google-cloud-sdk -y && \
    curl https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3 | bash && \
    curl -L -o /usr/local/bin/kubectl https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl && \
    ln -s /usr/local/bin/helm /usr/local/bin/helm3 && \
    pip3 install --upgrade pip setuptools && \
    if [ ! -e /usr/bin/pip ]; then ln -s pip3 /usr/bin/pip ; fi && \
    if [ ! -h /usr/bin/python ]; then ln -sf /usr/bin/python3 /usr/bin/python; fi && \
    rm -rf /root/.cache && rm -rf /var/lib/apt/lists/* && \
    pip3 install yq --upgrade && \
    pip3 install awscli && \
    chmod +x /usr/local/bin/kubectl
COPY scripts/* /usr/local/bin/

