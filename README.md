# Oniro App Builder

Oniro App Builder provides a Dockerized tool and a `.deb` package for building Oniro/OpenHarmony applications.

## Features
- Pre-configured environment for Oniro/OpenHarmony ArkTS applications.
- Dockerized solution for consistent builds.
- `.deb` package for easy installation of tools and SDK setup.
- `onirobuilder` executable for managing SDK and build commands.

## Getting Started

### Install Oniro App Builder
Download and install the `.deb` package:

```bash
$ sudo dpkg -i onirobuilder.deb
$ sudo apt-get install -fy  # Fix missing dependencies if needed
```

### Initialize the Environment
Run the following command to install the OpenHarmony SDK and required tools:

```bash
$ onirobuilder init
```

### Build an Application
Navigate to your application project and run:

```bash
$ onirobuilder build
```

The output files will be in the `output` directory.

### Signing a HAP Package
To generate the HAP signing certificates and profile, run:

```bash
$ onirobuilder sign
```

This updates the `build-profile.json5` file with the new signing configs.

### Using Docker
Alternatively, you can use the Dockerized environment:

#### Prerequisites
Ensure [Docker](https://docs.docker.com/get-docker/) is installed.

1. Build the Docker image:

    ```bash
    $ docker build -t oniro-app-builder .
    ```

2. Build an application:

    ```bash
    $ docker run --rm -v $(pwd):/workspace oniro-app-builder build
    ```

3. Access the container's shell for debugging:

    ```bash
    $ docker run --rm -it -v $(pwd):/workspace oniro-app-builder /bin/bash
    ```

## Dockerfile Overview
The Dockerfile provides a complete environment for building Oniro/OpenHarmony ArkTS applications:
1. Uses `ubuntu:22.04` as the base image.
2. Installs dependencies (`curl`, `unzip`, `python3`, `nodejs`, etc.).
3. Installs the `.deb` package containing `onirobuilder`.
4. Runs `onirobuilder init` to set up the environment.
5. Sets `/workspace` as the working directory.
6. Builds the application and outputs artifacts to the `output` directory.

## Environment Variables
- `OHOS_SDK_VERSION`: OpenHarmony SDK version (default: `5.0.0`).

## Contribution
Contributions are welcome! Create a pull request or open an issue for suggestions or issues.

## License
Licensed under [Apache License 2.0](LICENSE).
