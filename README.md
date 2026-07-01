# dqt-examples

A port of [Qt 6.4.2 base examples](https://github.com/qt/qtbase/tree/6.4.2/examples) from C++ to D using [DQt](https://github.com/tim-dlang/dqt) bindings.

## Requirements

- [LDC](https://github.com/ldc-developers/ldc) (D compiler) ≥ 1.40
- [DUB](https://dub.pm/) (D package manager) ≥ 1.40
- Qt 6.4.2 (shared libraries)

## Dev Containers (VS Code)

This repository includes a [Dev Container](https://code.visualstudio.com/docs/devcontainers/containers) configuration that provides a fully reproducible environment with Qt 6.4.2 and the D toolchain preinstalled.

### Prerequisites

- [Docker](https://docs.docker.com/get-docker/)
- [VS Code](https://code.visualstudio.com/) with the [Dev Containers](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-containers) extension

### Quick start

1. Open the repository in VS Code.
2. When prompted, click **Reopen in Container**. Alternatively, run the **Dev Containers: Reopen in Container** command from the command palette (`Ctrl+Shift+P`).

> **Note:** the initial build compiles Qt 6.4.2 from source and may take 30–60 minutes depending on your machine.

### X11 forwarding (Linux)

The container binds `/tmp/.X11-unix` and sets the `DISPLAY` environment variable automatically. On the host, grant Docker access to your X server:

```bash
xhost +local:
```

After that, GUI examples should work out of the box on Linux hosts.

## License

BSD-3-Clause (same as the original Qt examples).
