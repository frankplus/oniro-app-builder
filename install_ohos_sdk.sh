#!/usr/bin/env bash

set -eux

# Set these environment variables before running the script
: "${INPUT_VERSION:?INPUT_VERSION needs to be set}"

# Take SDK installation directory as an argument
if [ "$#" -ne 1 ]; then
  echo "Usage: $0 <sdk_installation_directory>"
  exit 1
fi

WORK_DIR="$1"
URL_BASE="https://repo.huaweicloud.com/openharmony/os"
OS_FILENAME="ohos-sdk-windows_linux-public.tar.gz"

mkdir -p "${WORK_DIR}"
cd "${WORK_DIR}"

# Download and extract the SDK
function download_and_extract_sdk() {
    DOWNLOAD_URL="${URL_BASE}/${INPUT_VERSION}-Release/${OS_FILENAME}"
    echo "Downloading OHOS SDK from ${DOWNLOAD_URL}"
    curl --fail -L -O "${DOWNLOAD_URL}"
    curl --fail -L -O "${DOWNLOAD_URL}.sha256"

    # Verify the download
    echo "$(cat "${OS_FILENAME}.sha256") ${OS_FILENAME}" | sha256sum --check --status

    # Extract SDK
    VERSION_MAJOR=${INPUT_VERSION%%.*}
    if (( VERSION_MAJOR >= 5 )); then
      tar -xf "${OS_FILENAME}"
    else
      tar -xf "${OS_FILENAME}" --strip-components=1
    fi
    rm "${OS_FILENAME}" "${OS_FILENAME}.sha256"

    # Set up SDK directories
    rm -rf windows
    cd linux
    OHOS_BASE_SDK_HOME="$PWD"
    extract_sdk_components
}

# Extract components
function extract_sdk_components() {
    COMPONENTS=(*.zip)
    for COMPONENT in "${COMPONENTS[@]}"; do
        echo "Extracting component ${COMPONENT}"
        if [[ -f "${COMPONENT}" ]]; then
          unzip "${COMPONENT}"
        else
          echo "Failed to find component ${COMPONENT}"
          ls -la
          exit 1
        fi
        component_dir=${COMPONENT%%-*}
        API_VERSION=$(jq -r '.apiVersion' < "${component_dir}/oh-uni-package.json")
        if [ "$INPUT_FIXUP_PATH" = "true" ]; then
            mkdir -p "${API_VERSION}"
            mv "${component_dir}" "${API_VERSION}/"
        fi
    done
    rm ./*.zip
}

# Run the download and extraction process
download_and_extract_sdk

# Environment setup
OHOS_NDK_HOME="${OHOS_BASE_SDK_HOME}"
OHOS_SDK_NATIVE="${OHOS_BASE_SDK_HOME}/native"
cd "${OHOS_SDK_NATIVE}"
SDK_VERSION="$(jq -r .version < oh-uni-package.json )"
API_VERSION="$(jq -r .apiVersion < oh-uni-package.json )"
echo "OHOS_BASE_SDK_HOME=${OHOS_BASE_SDK_HOME}"
echo "OHOS_NDK_HOME=${OHOS_NDK_HOME}"
echo "OHOS_SDK_NATIVE=${OHOS_SDK_NATIVE}"
echo "sdk-version=${SDK_VERSION}"
echo "api-version=${API_VERSION}"
