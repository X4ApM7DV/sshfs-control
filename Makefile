# sshfs-control
# Makefile backend for named SSHFS mount operations.

SHELL := /usr/bin/env bash

TARGET ?= web

CONFIG_EXAMPLE := config/mounts.example.mk
CONFIG_LOCAL := config/mounts.local.mk

include $(CONFIG_EXAMPLE)
-include $(CONFIG_LOCAL)

REMOTE_PATH := $(REMOTE_PATH_$(TARGET))
LOCAL_DIR := $(LOCAL_DIR_$(TARGET))
TARGET_SSHFS_OPTS := $(or $(SSHFS_OPTS_$(TARGET)),$(SSHFS_OPTS))
TARGETS := $(strip $(TARGETS))

.PHONY: help list-targets check-tools check-target print-config mount unmount remount status ls doctor

help:
	@echo "sshfs-control"
	@echo ""
	@echo "Usage:"
	@echo "  make list-targets"
	@echo "  make print-config TARGET=web"
	@echo "  make mount TARGET=web"
	@echo "  make status TARGET=web"
	@echo "  make ls TARGET=web"
	@echo "  make unmount TARGET=web"
	@echo "  make remount TARGET=web"
	@echo "  make doctor"

list-targets:
	@echo "Available targets:"
	@for target in $(TARGETS); do \
		echo "  $$target"; \
	done

check-tools:
	@command -v sshfs >/dev/null 2>&1 || { echo "Missing required command: sshfs"; exit 1; }
	@command -v fusermount >/dev/null 2>&1 || command -v fusermount3 >/dev/null 2>&1 || { echo "Missing required command: fusermount or fusermount3"; exit 1; }
	@command -v mountpoint >/dev/null 2>&1 || { echo "Missing required command: mountpoint"; exit 1; }

check-target:
	@if [ -z "$(REMOTE_PATH)" ] || [ -z "$(LOCAL_DIR)" ]; then \
		echo "Invalid or undefined target: $(TARGET)"; \
		echo ""; \
		$(MAKE) --no-print-directory list-targets; \
		exit 1; \
	fi

print-config: check-target
	@echo "TARGET=$(TARGET)"
	@echo "REMOTE_SERVER=$(REMOTE_SERVER)"
	@echo "REMOTE_USER=$(REMOTE_USER)"
	@echo "REMOTE_PATH=$(REMOTE_PATH)"
	@echo "LOCAL_DIR=$(LOCAL_DIR)"
	@echo "TARGET_SSHFS_OPTS=$(TARGET_SSHFS_OPTS)"

mount: check-tools check-target
	@echo "Ensuring mount point exists: $(LOCAL_DIR)"
	@mkdir -p "$(LOCAL_DIR)"
	@if mountpoint -q "$(LOCAL_DIR)"; then \
		echo "Already mounted: $(LOCAL_DIR)"; \
	else \
		echo "Mounting $(REMOTE_USER)@$(REMOTE_SERVER):$(REMOTE_PATH) -> $(LOCAL_DIR)"; \
		sshfs -o "$(TARGET_SSHFS_OPTS)" "$(REMOTE_USER)@$(REMOTE_SERVER):$(REMOTE_PATH)" "$(LOCAL_DIR)"; \
		if mountpoint -q "$(LOCAL_DIR)"; then \
			echo "Mounted OK: $(LOCAL_DIR)"; \
		else \
			echo "Mount failed: $(LOCAL_DIR)"; \
			exit 1; \
		fi; \
	fi

unmount: check-tools check-target
	@if mountpoint -q "$(LOCAL_DIR)"; then \
		echo "Unmounting $(LOCAL_DIR)"; \
		if command -v fusermount3 >/dev/null 2>&1; then \
			fusermount3 -u "$(LOCAL_DIR)"; \
		else \
			fusermount -u "$(LOCAL_DIR)"; \
		fi; \
	else \
		echo "Not mounted: $(LOCAL_DIR)"; \
	fi

remount: check-target
	@$(MAKE) --no-print-directory unmount TARGET="$(TARGET)"
	@$(MAKE) --no-print-directory mount TARGET="$(TARGET)"

status: check-target
	@if mountpoint -q "$(LOCAL_DIR)"; then \
		echo "Mounted: $(LOCAL_DIR)"; \
	else \
		echo "Not mounted: $(LOCAL_DIR)"; \
	fi

ls: check-target
	@if mountpoint -q "$(LOCAL_DIR)"; then \
		ls -la "$(LOCAL_DIR)"; \
	else \
		echo "Not mounted: $(LOCAL_DIR)"; \
		exit 1; \
	fi

doctor: check-tools
	@echo "Required commands found."
	@if [ -f "$(CONFIG_LOCAL)" ]; then \
		echo "Local config found: $(CONFIG_LOCAL)"; \
	else \
		echo "Local config not found: $(CONFIG_LOCAL)"; \
		echo "Create it with: cp $(CONFIG_EXAMPLE) $(CONFIG_LOCAL)"; \
	fi
	@$(MAKE) --no-print-directory list-targets
