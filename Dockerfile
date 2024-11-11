# Dockerfile for building an Oniro/OpenHarmony application

# Use a base image with required build tools
FROM ubuntu:22.04

# Install dependencies
RUN apt update && \
    apt install -y curl unzip python3 python3-pip openjdk-11-jdk git jq && \
    python3 -m pip install --upgrade pip && \
    curl -fsSL https://deb.nodesource.com/setup_18.x | bash - && \
    apt install -y nodejs

# Set environment variables
ENV HOME=/root
ENV SHELL=/bin/bash
ENV OHOS_SDK_VERSION=4.1
ENV HVIGOR_VERSION=5
ENV NODE_VERSION=18
ENV OHOS_SDK_HOME="${HOME}/setup-ohos-sdk"
ENV HVIGOR_PATH="${HOME}/hvigor-installation"

# Copy install_ohos_sdk.sh from local directory
COPY install_ohos_sdk.sh /tmp/install_ohos_sdk.sh

# Run install_ohos_sdk.sh
RUN chmod +x /tmp/install_ohos_sdk.sh && \
    INPUT_VERSION=${OHOS_SDK_VERSION} INPUT_FIXUP_PATH=false /tmp/install_ohos_sdk.sh ${OHOS_SDK_HOME}

# Install hvigor and its plugins
RUN mkdir -p ${HVIGOR_PATH} && \
    cd ${HVIGOR_PATH} && \
    echo "@ohos:registry=https://repo.harmonyos.com/npm/" > .npmrc && \
    npm install "@ohos/hvigor@${HVIGOR_VERSION}" "@ohos/hvigor-ohos-plugin@${HVIGOR_VERSION}"

# Set work directory
WORKDIR /workspace

# Command to build the Oniro/OpenHarmony application
CMD NODE_PATH=${HVIGOR_PATH}"/node_modules" node ${HVIGOR_PATH}/node_modules/@ohos/hvigor/bin/hvigor.js \
    --no-daemon assembleHap -p product=default -p buildMode=release && \
    cp -r entry/build/default/outputs/default/*.hap /workspace/output/
