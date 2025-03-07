# Oniro App Builder

Oniro App Builder provides a Dockerized tool for building Oniro/OpenHarmony applications.

## Features
- Pre-configured environment for Oniro/OpenHarmony ArkTS applications.
- Dockerized solution for consistent builds.
- Simple commands to build and package applications.

## Getting Started

### Prerequisites
Ensure [Docker](https://docs.docker.com/get-docker/) is installed.

### Build the Docker Image
Run the following command to build the Docker image:

```bash
$ docker build -t oniro-app-builder .
```

### Build an Application
Navigate to your application project and run:

```bash
$ docker run --rm -v $(pwd):/workspace oniro-app-builder
```

The output files will be in the `output` directory.

### Accessing the Container's Shell
To access the container's shell for debugging:

```bash
$ docker run --rm -it -v $(pwd):/workspace oniro-app-builder /bin/bash
```

### Signing a HAP Package

By default, the `build-profile.json5` file is configured to build an unsigned HAP package. This is achieved by keeping the `signingConfigs` array empty:

```json
{
    "app": {
        "signingConfigs": []
        // ... other configurations
    }
}
```

To sign the HAP package, you'll need to generate self-signing keys and related materials using DevEco Studio. Follow the instructions [here](https://developer.huawei.com/consumer/en/doc/harmonyos-guides-V5/ide-signing-V5#section18815157237) to create these files.  Currently, self-generation of keys outside of DevEco Studio is not supported (see [related issue](https://github.com/eclipse-oniro4openharmony/oniro-planning/issues/9)).

Once you have generated the signing materials (including `.cer`, `.p7b`, `.p12` files, and the "material" directory), copy them into your project directory.  These files will then be accessible within the Docker container when you mount your project.

Next, update your `build-profile.json5` file to reference the signing materials.  For example:

```json
{
    "app": {
        "signingConfigs": [
            {
                "name": "default",
                "material": {
                    "certpath": "./.secret/key.cer",
                    "storePassword": "your_store_password",
                    "keyAlias": "debugKey",
                    "keyPassword": "your_key_password",
                    "profile": "./.secret/key.p7b",
                    "signAlg": "SHA256withECDSA",
                    "storeFile": "./.secret/key.p12"
                }
            }
        ],
        // ... other configurations
    }
}
```

**Important:** Replace `"your_store_password"` and `"your_key_password"` with the actual passwords you set during the key generation process in DevEco Studio.  Also, ensure the paths to your signing materials are correct relative to the project root.  It is recommended to store the signing materials in a secure location within your project (e.g., a `.secret` directory) and to avoid committing these files to version control.

## Dockerfile Overview
The Dockerfile provides a complete environment for building Oniro/OpenHarmony ArkTS applications:
1. Uses `ubuntu:22.04` as the base image.
2. Installs dependencies (`curl`, `unzip`, `python3`, `nodejs`, etc.).
3. Downloads and installs OpenHarmony SDK.
4. Install project dependencies such as hvigorw, ohpm
5. Sets `/workspace` as the working directory.
6. Builds the application and outputs artifacts to the `output` directory.

## Environment Variables
- `OHOS_SDK_VERSION`: OpenHarmony SDK version (default: `5.0.0`).

## Contribution
Contributions are welcome! Create a pull request or open an issue for suggestions or issues.

## License
Licensed under [Apache License 2.0](LICENSE).
