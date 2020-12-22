FROM alpine:3.6 as helm3
ENV DESIRED_VERSION v3.2.1
RUN apk add --update ca-certificates openssl bash curl
RUN curl https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3 | bash

FROM alpine:3.6
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
RUN apk add --update ca-certificates openssl bash gettext git curl make jq coreutils gawk
RUN curl -L -o /usr/local/bin/kubectl https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl
COPY --from=helm3 /usr/local/bin/helm /usr/local/bin/helm
COPY --from=helm3 /usr/local/bin/helm /usr/local/bin/helm3
RUN apk add --update python3 && \
    python3 -m ensurepip && \
    rm -r /usr/lib/python*/ensurepip && \
    pip3 install --upgrade pip setuptools && \
    if [ ! -e /usr/bin/pip ]; then ln -s pip3 /usr/bin/pip ; fi && \
    if [[ ! -e /usr/bin/python ]]; then ln -sf /usr/bin/python3 /usr/bin/python; fi && \
    rm -r /root/.cache
RUN pip install yq --upgrade
RUN chmod +x /usr/local/bin/kubectl \
 && rm /var/cache/apk/*

