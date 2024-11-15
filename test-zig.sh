#!/usr/bin/env bash

PROGRAM_NAME="$1"
#ZIG="$2"
PARAMS=("$@")
ROOT_DIR="$(cd "$(dirname "$0")"; pwd)"
if [[ -z "$ZIG" ]]; then
  ZIG="$ROOT_DIR/solana-zig/zig"
fi

set -e
PROGRAM_DIR=$ROOT_DIR/$PROGRAM_NAME
cd $PROGRAM_DIR/zig
$ZIG build --summary all -freference-trace --verbose
SBF_OUT_DIR="$PROGRAM_DIR/zig/zig-out/lib" cargo test --manifest-path "$PROGRAM_DIR/Cargo.toml" "${PARAMS[@]:2}"
