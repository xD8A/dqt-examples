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

## Examples

All examples are ports of the [Qt 6.4.2 Widgets tutorials](https://github.com/qt/qtbase/tree/6.4.2/examples/widgets/tutorials) and reside under `examples/widgets/tutorials/`.

### Getting Started (`gettingStarted/gsQt/`)

A 5-part series that progressively builds a Qt Widgets application:
- **part1** — basic window with a widget
- **part2** — layouts and child widgets
- **part3** — signals and slots
- **part4** — custom dialogs
- **part5** — complete application with menus and toolbars

### Widgets Tutorial (`widgets/`)

A 4-part series on basic widget usage:
- **toplevel** — creating top-level windows
- **childwidget** — embedding child widgets
- **windowlayout** — arranging widgets in a window
- **nestedlayouts** — nesting layouts for complex UIs

### Address Book (`addressbook/`)

A 7-part series that builds a complete address book application:
- **part1** — basic UI setup
- **part2** — adding contacts
- **part3** — browsing contacts
- **part4** — editing and removing contacts
- **part5** — finding and sorting
- **part6** — importing and exporting
- **part7** — custom dialogs and final polish

### Model/View (`modelview/`)

A 7-part series on Qt's Model/View programming pattern:
- **1_readonly** — read-only table model
- **2_formatting** — custom formatting
- **3_changingmodel** — dynamically changing models
- **4_headers** — row and column headers
- **5_edit** — editing items
- **6_treeview** — tree views
- **7_selections** — selection handling

### Notepad (`notepad/`)

A standalone text editor with file I/O, menus, toolbars, font selection, and formatting toggles.

## License

BSD-3-Clause (same as the original Qt examples).
