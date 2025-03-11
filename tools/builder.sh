#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

show_usage() {
    echo "Usage: $0 [project_directory] [--generate-signing-configs|-s]"
    echo "If no project_directory is provided, the current directory will be used."
    echo "Use --generate-signing-configs or -s to generate signature keys and configs."
}

# Check for necessary environment variables
if [ -z "$OHOS_BASE_SDK_HOME" ]; then
    echo "::error::OHOS_BASE_SDK_HOME environment variable is not set"
    exit 1
fi

if [ -z "$CMD_PATH" ]; then
    echo "::error::CMD_PATH environment variable is not set"
    exit 1
fi

if [ -z "$TOOLS_DIR" ]; then
    echo "::error::TOOLS_DIR environment variable is not set"
    exit 1
fi

# Get the project directory from the first argument, default to the current directory
PROJECT_DIR=${1:-$(pwd)}

# This is a basic check to see if the project is an OpenHarmony project.
# A more robust check might involve verifying if runtimeOS is set to 'OpenHarmony'.
check_openharmony_project() {
    if [ ! -f "$PROJECT_DIR/build-profile.json5" ]; then
        echo "::error::This is not an OpenHarmony project. 'build-profile.json5' not found."
        exit 1
    fi
    echo "=== OpenHarmony project detected ==="
}

# Setup hvigorw if not already present
setup_hvigorw() {
    if [ ! -f "$PROJECT_DIR/hvigorw" ]; then
        echo "=== hvigorw not found. Setting up hvigorw ==="
        cp "$TOOLS_DIR/hvigorw" "$PROJECT_DIR"
        cp -r "$TOOLS_DIR/hvigor" "$PROJECT_DIR"
        echo "=== hvigorw setup complete ==="
    else
        echo "=== hvigorw already present ==="
    fi

    chmod +x "$PROJECT_DIR/hvigorw"
}

install_dependencies() {
    echo "=== Installing Project Dependencies ==="
    cd "$PROJECT_DIR"
    ohpm install --all

    # Verify Installation
    echo "=== Environment Variables ===" && \
    echo "PATH: $PATH" && \
    echo "OHOS_BASE_SDK_HOME: $OHOS_BASE_SDK_HOME" && \
    echo "CMD_PATH: $CMD_PATH" && \
    echo "=== OHPM Installation ===" && \
    which ohpm && \
    ohpm -v && \
    echo "=== Node.js Version ===" && \
    node --version && \
    npm --version && \
    echo "=== NPM Configuration ===" && \
    cat $HOME/.npmrc
}

generate_signing_configs() {
    echo "=== Generating Signature Keys and Configs ==="
    node "$TOOLS_DIR/generate_signing_configs.js"
    echo "=== Signature Keys and Configs Generation Complete ==="
}

# Show usage if help is requested
if [[ "$1" == "--help" || "$1" == "-h" ]]; then
    show_usage
    exit 0
fi

# Check if the generate signing configs flag is set
if [[ "$1" == "--generate-signing-configs" || "$1" == "-s" ]]; then
    generate_signing_configs
    exit 0
fi

check_openharmony_project
setup_hvigorw
install_dependencies

# Initialize and Build
cd "$PROJECT_DIR"
./hvigorw --version --accept-license && \
./hvigorw clean --no-parallel --no-daemon && \
./hvigorw assembleHap --mode module -p product=default --stacktrace --no-parallel --no-daemon