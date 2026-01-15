# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Post-install setup scripts for Fedora Kinoite (immutable Fedora with KDE). Split into two scripts with a reboot in between (required for rpm-ostree repo changes to take effect).

## Build

```bash
./build.sh
```

Creates `setup-1.sh` (pre-reboot) and `setup-2.sh` (post-reboot).

## Architecture

Source files in `source/` by number prefix:
- `000-helpers.sh` - shared helper functions (included in both scripts)
- `1xx` - pre-install scripts (setup-1.sh): hostname
- `2xx` - repo setup steps (setup-2.sh): flatpak repos, RPM Fusion
- `3xx` - rpm-ostree steps (setup-2.sh): packages, removals, GPU drivers, ffmpeg
- `4xx` - flatpaks (setup-2.sh)

Data files in `packages/`:
- `rpm-ostree-packages` - packages to layer (one per line, sorted alphabetically)
- `flatpaks` - flatpak app IDs to install (one per line, sorted alphabetically)
- `repos/*.repo` - custom yum repos
- `hooks/<package>.sh` - per-package setup hooks (run if package is selected)

When multiple install options exist (flatpak, rpm, AppImage), prefer officially supported methods.

Build placeholders (`@@NAME@@`) in source files are replaced with data file content. Hooks are wrapped in if statements checking if the package was selected.

Functions prefixed with `setup_1` or `setup_2` are discovered and run in sorted order per script.
