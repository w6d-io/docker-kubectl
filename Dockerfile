# === Stage 1: Builder ==================================================
FROM python:3.11-slim AS builder

ENV DEBIAN_FRONTEND=noninteractive

WORKDIR /tmp/build
# Install minimal tools to fetch/install CLIs
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl ca-certificates gnupg unzip tar gzip xz-utils binutils && \
    # --- kubectl ---
    curl -sSL -o kubectl https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl && \
    chmod +x kubectl && strip kubectl && \
    # --- helm ---
    curl -sSL https://get.helm.sh/helm-v3.14.4-linux-amd64.tar.gz | tar -xz && \
    mv linux-amd64/helm . && chmod +x helm && strip helm && \
    # --- go-yq ---
    curl -sSL -o go-yq https://github.com/mikefarah/yq/releases/latest/download/yq_linux_amd64 && \
    chmod +x go-yq && strip go-yq && \
    # --- AWS CLI v2 ---
    curl -sSL "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o awscliv2.zip && \
    unzip awscliv2.zip && ./aws/install -i /aws-cli -b /tmp/build/aws-bin && \
    # --- gcloud SDK ---
    curl -sSL https://dl.google.com/dl/cloudsdk/channels/rapid/downloads/google-cloud-cli-470.0.0-linux-x86_64.tar.gz \
      -o gcloud.tgz && \
    tar -xzf gcloud.tgz && \
    ./google-cloud-sdk/install.sh --quiet --path-update=false --usage-reporting=false && \
    strip ./google-cloud-sdk/bin/gcloud || true && \
    strip ./google-cloud-sdk/bin/gsutil || true

# === Stage 2: Final Slim Runtime =======================================
FROM python:3.11-slim

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

#ENV PATH="/usr/local/aws-cli/v2/current/bin:/google-cloud-sdk/bin:$PATH"

# Only install runtime essentials
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl gnupg unzip tar gzip xz-utils binutils ca-certificates bash jq gettext postgresql-client && \
    pip install --no-cache-dir yq jira tabulate docopt colorlog && \
    rm -rf /var/lib/apt/lists/* /root/.cache /tmp/*

# Copy tools from builder
COPY --from=builder /tmp/build/kubectl /usr/local/bin/kubectl
COPY --from=builder /tmp/build/helm /usr/local/bin/helm
COPY --from=builder /tmp/build/go-yq /usr/local/bin/go-yq
#COPY --from=builder /aws-cli /usr/local/aws-cli
#COPY --from=builder /aws-cli/v2/current/bin/aws /usr/local/bin/aws
#COPY --from=builder /tmp/build/google-cloud-sdk /opt/google-cloud-sdk
#ENV PATH="/usr/local/aws-cli/v2/current/bin:/opt/google-cloud-sdk/bin:$PATH"

# Optional: symlink helm3
RUN ln -s /usr/local/bin/helm /usr/local/bin/helm3

# Add your scripts
COPY scripts/* /usr/local/bin/
