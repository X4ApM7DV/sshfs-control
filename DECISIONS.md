# Decisions

## Background

This repository replaced a few one-off SSHFS commands that were easy to forget and easy to edit in the wrong place. The repeated parts are now in the Makefile. Machine-specific values stay in `config/mounts.local.mk`.

## Makefile backend

The Makefile owns the actual operations:

- `mount`
- `unmount`
- `remount`
- `status`
- `ls`
- `doctor`

That keeps the command surface small and makes it possible to run everything directly with `make` when debugging.

## Wrapper script

`bin/mountfs` is only a convenience wrapper around the Makefile. It resolves the repository path, then calls `make -C`.

This lets the command work from outside the repository, especially when symlinked into `~/lab/bin`.

## Local configuration

`config/mounts.example.mk` is committed so the expected variables are visible.

`config/mounts.local.mk` is ignored because it can contain real hostnames, usernames, mount paths and remote paths.

## Current scope

The project handles named SSHFS mounts on a local Linux machine. It does not try to manage SSH keys, create remote directories, install packages or configure systemd units.
