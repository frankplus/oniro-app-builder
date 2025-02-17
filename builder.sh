#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

# Print commands and their arguments as they are executed
set -x

export CMD_PATH="${HOME}/command-line-tools" 
export PROJECT_PATH=/workspace
export PATH="$CMD_PATH/bin:$PATH"
export OHOS_BASE_SDK_HOME="${HOME}/setup-ohos-sdk/linux"

# Setup command-line-tools
echo "=== Setting up Command-line Tools ==="
chmod +x ${HOME}/cmd-tools/sdk-11/installer.sh && \
    ${HOME}/cmd-tools/sdk-11/installer.sh

# Install project dependencies
echo "=== Installing Project Dependencies ==="
ohpm install --all

# Verify Installation
echo "=== Environment Variables ===" && \
echo "PATH: $PATH" && \
echo "OHOS_BASE_SDK_HOME: $OHOS_BASE_SDK_HOME" && \
echo "CMD_PATH: $CMD_PATH" && \
echo "=== OHPM Installation ===" && \
which ohpm && \
ohpm -v && \
echo "=== Hvigor Installation ===" && \
which hvigorw && \
hvigorw --version && \
echo "=== Installation Directories ===" && \
echo "Command-line Tools:" && \
tree -L 3 $CMD_PATH && \
echo "OpenHarmony SDK:" && \
tree -L 3 $OHOS_BASE_SDK_HOME && \
echo "=== Node.js Version ===" && \
node --version && \
npm --version && \
echo "=== NPM Configuration ===" && \
cat $HOME/.npmrc

# Initialize and Build
hvigorw --version --accept-license && \
hvigorw clean --no-parallel --no-daemon && \
hvigorw assembleHap --mode module -p product=default --stacktrace --no-parallel --no-daemon