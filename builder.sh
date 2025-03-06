#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

# Check for necessary environment variables
if [ -z "$OHOS_BASE_SDK_HOME" ]; then
    echo "::error::OHOS_BASE_SDK_HOME environment variable is not set"
    exit 1
fi

if [ -z "$PROJECT_PATH" ]; then
    echo "::error::PROJECT_PATH environment variable is not set"
    exit 1
fi

if [ -z "$CMD_PATH" ]; then
    echo "::error::CMD_PATH environment variable is not set"
    exit 1
fi

setup_hvigorw() {
    echo "::group::Setting up hvigorw..."
    
    # Validate PROJECT_PATH is set
    if [ -z "$PROJECT_PATH" ]; then
        echo "::error::PROJECT_PATH environment variable is not set"
        return 1
    fi

    # Check if hvigorw exists in the project
    if [ ! -f "$PROJECT_PATH/hvigorw" ]; then
        echo "::error::hvigorw file not found at: $PROJECT_PATH/hvigorw"
        return 1
    fi

    # Ensure bin directory exists
    mkdir -p "$CMD_PATH/bin"

    # Create the hvigorw script with the resolved PROJECT_PATH
    cat > "$CMD_PATH/bin/hvigorw" << EOF
#!/usr/bin/env bash

set -e
HVIGORW_PATH="$PROJECT_PATH/hvigorw"

# Preserve current directory
ORIGINAL_DIR="\$(pwd)"

# Change to the project directory, execute hvigorw, then return
(cd "$PROJECT_PATH" && exec bash "\$HVIGORW_PATH" "\$@")
RC=\$?

# Return to original directory (though not strictly necessary due to subshell)
cd "\$ORIGINAL_DIR"
exit \$RC
EOF

    # Verify the script was created
    if [ ! -f "$CMD_PATH/bin/hvigorw" ]; then
        echo "::error::Failed to create hvigorw script"
        return 1
    fi

    # Make the script executable
    chmod +x "$CMD_PATH/bin/hvigorw"

    echo "::debug::hvigorw script created at: $CMD_PATH/bin/hvigorw"
    echo "::debug::Points to project hvigorw at: $PROJECT_PATH/hvigorw"
    echo "::endgroup::"
}

install_dependencies() {
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
    echo "=== Node.js Version ===" && \
    node --version && \
    npm --version && \
    echo "=== NPM Configuration ===" && \
    cat $HOME/.npmrc
}

setup_hvigorw
install_dependencies

# Initialize and Build
cd $PROJECT_PATH
hvigorw --version --accept-license && \
hvigorw clean --no-parallel --no-daemon && \
hvigorw assembleHap --mode module -p product=default --stacktrace --no-parallel --no-daemon