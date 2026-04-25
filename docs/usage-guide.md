# Usage Guide

## Overview

`sshfs-control` mounts named SSHFS targets from a local Linux machine.

Use `make` directly, or use `bin/mountfs` as a shorter wrapper.

## Initial setup

Clone the repository:

```bash
git clone https://github.com/X4ApM7DV/sshfs-control.git
cd sshfs-control
```

Install SSHFS if needed:

```bash
sudo apt update
sudo apt install sshfs
```

Create your local config:

```bash
cp config/mounts.example.mk config/mounts.local.mk
nano config/mounts.local.mk
```

Make the wrapper executable:

```bash
chmod +x bin/mountfs
```

Run the doctor command:

```bash
make doctor
```

## Core commands

### List available targets

```bash
make list-targets
bin/mountfs list
```

### Print resolved configuration

```bash
make print-config TARGET=web
bin/mountfs config web
```

### Mount a target

```bash
make mount TARGET=web
bin/mountfs mount web
```

### Check status

```bash
make status TARGET=web
bin/mountfs status web
```

### List mounted files

```bash
make ls TARGET=web
bin/mountfs ls web
```

### Unmount a target

```bash
make unmount TARGET=web
bin/mountfs unmount web
```

### Remount a target

```bash
make remount TARGET=web
bin/mountfs remount web
```

## Adding a new target

Edit `config/mounts.local.mk`.

Add the new target name to `TARGETS`:

```makefile
TARGETS ?= web home logs
```

Define the matching remote and local paths:

```makefile
REMOTE_PATH_logs := /var/log/
LOCAL_DIR_logs := $(LOCAL_BASE)/remote-logs
```

Use the target:

```bash
bin/mountfs mount logs
```

## Using ~/lab/bin

One useful placement:

```text
~/lab/infra/sshfs-control
```

Symlink the wrapper:

```bash
ln -sf ~/lab/infra/sshfs-control/bin/mountfs ~/lab/bin/mountfs
```

Confirm `~/lab/bin` is in your `PATH`:

```bash
echo "$PATH"
```

Then run:

```bash
mountfs list
mountfs mount web
mountfs status web
mountfs unmount web
```

## Troubleshooting

### Mount does not appear

Check the resolved config:

```bash
bin/mountfs config web
```

Confirm SSH works without SSHFS:

```bash
ssh user@example.com
```

Confirm the remote path exists:

```bash
ssh user@example.com 'ls -la /remote/path'
```

### Unmount fails

A process may be using the mount point.

Check active processes:

```bash
lsof +D /path/to/mount
```

Then close the process or terminal using that directory and retry:

```bash
bin/mountfs unmount web
```

### Invalid target

If you see an invalid target error, confirm that both variables exist:

```makefile
REMOTE_PATH_targetname := /remote/path/
LOCAL_DIR_targetname := /local/path/
```

The suffix after `REMOTE_PATH_` and `LOCAL_DIR_` must match the target name.

## Local config

Never commit:

```text
config/mounts.local.mk
```

That file is ignored because it can contain real hostnames, usernames and paths.
