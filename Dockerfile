# Dockerfile for building an Oniro/OpenHarmony application

# Use a base image with required build tools
FROM ubuntu:22.04

# Use bash shell
SHELL ["/bin/bash", "-c"] 

# Install dependencies
RUN apt update && \
    apt install -y curl unzip python3 python3-pip openjdk-11-jdk git jq && \
    python3 -m pip install --upgrade pip && \
    curl -fsSL https://deb.nodesource.com/setup_18.x | bash - && \
    apt install -y nodejs

# Set environment variables
ENV HOME=/root
ENV OHOS_SDK_VERSION=5.0.0

# Copy and run install_ohos_sdk.sh
COPY install_ohos_sdk.sh /tmp/install_ohos_sdk.sh
RUN chmod +x /tmp/install_ohos_sdk.sh && \
    export INPUT_VERSION=$OHOS_SDK_VERSION && \
    export INPUT_MIRROR="false" && \
    export INPUT_COMPONENTS="all" && \
    export INPUT_FIXUP_PATH="true" && \
    export INPUT_CACHE="false" && \
    export INPUT_WAS_CACHED="false" && \
    source /tmp/install_ohos_sdk.sh

# Set OHOS_BASE_SDK_HOME environment variable
ENV OHOS_BASE_SDK_HOME="${HOME}/setup-ohos-sdk/linux"

# Setup .npmrc File
RUN echo "@ohos:registry=https://repo.harmonyos.com/npm/" > $HOME/.npmrc

# Install command line tools
ENV CMD_PATH="/root/command-line-tools"
COPY cmd_tools_installer.sh /tmp/cmd_tools_installer.sh
RUN chmod +x /tmp/cmd_tools_installer.sh && \
    source /tmp/cmd_tools_installer.sh

# Add cmd-tools to PATH
ENV PATH="$PATH:$CMD_PATH/bin"

# Copy and set permissions for builder script
COPY ./builder.sh /tmp/builder.sh
RUN chmod +x /tmp/builder.sh

# Set work directory
ENV PROJECT_PATH=/workspace
WORKDIR /workspace

# Set the default command to run builder
CMD ["/tmp/builder.sh"]