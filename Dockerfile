# Dockerfile for building an Oniro/OpenHarmony application

# Use a base image with required build tools
FROM ubuntu:22.04

SHELL ["/bin/bash", "-c"] 

# Install dependencies
RUN apt update && \
    apt install -y curl unzip python3 python3-pip openjdk-11-jdk git jq && \
    python3 -m pip install --upgrade pip && \
    curl -fsSL https://deb.nodesource.com/setup_18.x | bash - && \
    apt install -y nodejs

# Set environment variables
ENV HOME=/root
ENV OHOS_SDK_VERSION=4.1

# Copy install_ohos_sdk.sh and cmd-tools
COPY install_ohos_sdk.sh /tmp/install_ohos_sdk.sh

# Run install_ohos_sdk.sh
RUN chmod +x /tmp/install_ohos_sdk.sh &&  \
    export INPUT_VERSION=$OHOS_SDK_VERSION && \
    export INPUT_MIRROR="false" && \
    export INPUT_COMPONENTS="all" && \
    export INPUT_FIXUP_PATH="true"&& \
    export INPUT_CACHE="false" && \
    export INPUT_WAS_CACHED="false" && \
    source /tmp/install_ohos_sdk.sh

# Setup .npmrc File
RUN echo "@ohos:registry=https://repo.harmonyos.com/npm/" > $HOME/.npmrc

COPY ./cmd-tools ${HOME}/cmd-tools

COPY ./builder.sh /tmp/builder.sh
RUN chmod +x /tmp/builder.sh

# Set work directory
WORKDIR /workspace

# Set the default command to run builder
CMD ["/tmp/builder.sh"]