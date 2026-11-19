#!/bin/bash
# Run a command in the cybervisi0n NX build image (devkitA64 + libnx + portlibs).
# The repo is mounted at its own path; nx_deps (SoundTouch for Switch) is mounted too when it is a symlink.
CWD=$(pwd)
MOUNTS=(-v "$CWD:$CWD")
if [ -L "$CWD/nx_deps" ]; then
  DEPS=$(readlink -f "$CWD/nx_deps")
  MOUNTS+=(-v "$DEPS:$DEPS")
fi
exec docker run --rm --user $(id -u):$(id -g) -e HOME=/tmp -e DEVKITPRO=/opt/devkitpro \
  "${MOUNTS[@]}" -w "$CWD" cybervisi0n/pokeplatinum-build:v2 bash -c "$*"
