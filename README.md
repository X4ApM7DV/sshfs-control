# sshfs-control

Small SSHFS mount helper for local Linux machines.

It keeps named mount targets in one config file and exposes the common SSHFS operations through `make` or the `bin/mountfs` wrapper.

## Purpose

This application is for machines where the same remote paths are mounted repeatedly with SSHFS. The repository keeps the commands and examples tracked, while real hostnames, usernames and local paths stay in `config/mounts.local.mk`.

## Features

- Named mount targets
- Makefile-based command backend
- Simple CLI wrapper
- Local override config model
- Clean git workflow for infrastructure tooling

## Roadmap

- Support multiple servers and per-target SSH aliases
- Add read-only target support
- Add batch mount and unmount operations
- Add prerequisite checks for sshfs and fusermount
- Optional systemd user integration

## Project structure

```text
sshfs-control/
├── Makefile
├── README.md
├── LICENSE
├── DECISIONS.md
├── .gitignore
├── bin/
│   └── mountfs
├── config/
│   └── mounts.example.mk
└── docs/
    └── usage-guide.md
```

## Requirements

- Linux
- `make`
- `sshfs`
- `mountpoint`
- `fusermount` or `fusermount3`

Install dependencies on Ubuntu or Debian:

```bash
sudo apt update
sudo apt install sshfs
```

## Quick start

Clone the repository:

```bash
git clone https://github.com/X4ApM7DV/sshfs-control.git
cd sshfs-control
```

Create local configuration from the example file:

```bash
cp config/mounts.example.mk config/mounts.local.mk
```

Edit your local configuration:

```bash
nano config/mounts.local.mk
```

Make the CLI wrapper executable:

```bash
chmod +x bin/mountfs
```

Run a basic health check:

```bash
make doctor
```

Mount a target:

```bash
make mount TARGET=web
```

Or use the wrapper:

```bash
bin/mountfs mount web
```

## Optional: add to your PATH

If you want to run `mountfs` from anywhere, you can add it to your PATH.

Example:

```bash
ln -s /path/to/sshfs-control/bin/mountfs ~/.local/bin/mountfs
```

Make sure the destination directory is in your PATH.

## Configuration

Tracked:

```text
config/mounts.example.mk
```

Ignored:

```text
config/mounts.local.mk
```

Keep real hostnames, usernames and personal filesystem paths in the ignored local file.

You can define per-target SSHFS options using `SSHFS_OPTS_<target>`.

## Example commands

```bash
make list-targets
make print-config TARGET=web
make mount TARGET=web
make status TARGET=web
make ls TARGET=web
make unmount TARGET=web
make remount TARGET=web
```

Using the wrapper:

```bash
bin/mountfs list
bin/mountfs config web
bin/mountfs mount web
bin/mountfs status web
bin/mountfs ls web
bin/mountfs unmount web
bin/mountfs remount web
```

## Adding a target

Add the target name to `TARGETS`:

```makefile
TARGETS ?= web home logs
```

Then define the matching variables:

```makefile
REMOTE_PATH_logs := /var/log/
LOCAL_DIR_logs := $(LOCAL_BASE)/logs
```

Use it:

```bash
bin/mountfs mount logs
```

## License

MIT
