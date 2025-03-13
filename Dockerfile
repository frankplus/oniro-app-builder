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

# Install command line tools
ENV CMD_PATH="$HOME/command-line-tools"
COPY /tools/cmd_tools_installer.sh /tmp/cmd_tools_installer.sh
RUN . /tmp/cmd_tools_installer.sh

# Set OHOS_BASE_SDK_HOME environment variable
ENV OHOS_BASE_SDK_HOME="$CMD_PATH/sdk/default/openharmony"

# Set OHOS_BASE_SDK_HOME environment variable
ENV OHOS_BASE_SDK_HOME="${HOME}/setup-ohos-sdk/linux"

# Install command line tools
ENV CMD_PATH="$HOME/command-line-tools"
COPY /tools/cmd_tools_installer.sh /tmp/cmd_tools_installer.sh
RUN . /tmp/cmd_tools_installer.sh

# Copy the entire tools directory
ENV TOOLS_DIR=/root/tools
COPY ./tools $TOOLS_DIR

# Set permissions for scripts in the tools directory
RUN chmod +x $TOOLS_DIR/*.sh

# Setup .npmrc File
RUN echo "@ohos:registry=https://repo.harmonyos.com/npm/" > $HOME/.npmrc

# Run npm install inside the tools directory
RUN cd $TOOLS_DIR && npm install

# Add cmd-tools and TOOLS_DIR to PATH
ENV PATH="$PATH:$CMD_PATH/bin:$TOOLS_DIR"

# Set work directory
WORKDIR /workspace

# Set the default command to run builder
CMD ["builder.sh"]
