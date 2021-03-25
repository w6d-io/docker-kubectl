FROM debian:10
ARG VCS_REF
ARG BUILD_DATE
ARG VERSION
ARG USER_EMAIL="david.alexandre@w6d.io"
ARG USER_NAME="David ALEXANDRE"
LABEL maintainer="${USER_NAME} <${USER_EMAIL}>" \
        org.label-schema.vcs-ref=$VCS_REF \
        org.label-schema.vcs-url="https://github.com/w6d-io/kubectl" \
        org.label-schema.build-date=$BUILD_DATE \
        org.label-schema.version=$VERSION

ENV DESIRED_VERSION $DESIRED_VERSION
RUN apt update && apt install -y ca-certificates openssl bash gettext git curl make jq coreutils gawk python3 python3-pip && \
    curl https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3 | bash && \
    curl -L -o /usr/local/bin/kubectl https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl && \
    ln -s /usr/local/bin/helm /usr/local/bin/helm3 && \
    pip3 install --upgrade pip setuptools && \
    if [ ! -e /usr/bin/pip ]; then ln -s pip3 /usr/bin/pip ; fi && \
    if [[ ! -e /usr/bin/python ]]; then ln -sf /usr/bin/python3 /usr/bin/python; fi && \
    rm -rf /root/.cache && rm -rf /var/lib/apt/lists/* && \
    pip install yq --upgrade && \
    chmod +x /usr/local/bin/kubectl
COPY scripts/* /usr/local/bin/

