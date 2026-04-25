# Example SSHFS mount configuration.
#
# Copy this file to:
#   config/mounts.local.mk
#
# Then replace the placeholder values with your real local values.
# The local file is ignored by git.

REMOTE_SERVER ?= example.com
REMOTE_USER ?= deploy
LOCAL_BASE ?= $(HOME)/remote-mounts

TARGETS ?= web home

SSHFS_OPTS ?= reconnect,ServerAliveInterval=15,ServerAliveCountMax=3,StrictHostKeyChecking=accept-new

REMOTE_PATH_web ?= /srv/www/example.com/
LOCAL_DIR_web ?= $(LOCAL_BASE)/web

REMOTE_PATH_home ?= /home/deploy/
LOCAL_DIR_home ?= $(LOCAL_BASE)/home
