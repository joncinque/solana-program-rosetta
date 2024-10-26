#!/usr/bin/env bash
PROGRAM_NAME="$1"
ROOT_DIR="$(cd "$(dirname "$0")"; pwd)"
#set -e
PROGRAM_DIR=$ROOT_DIR/$PROGRAM_NAME
cd $PROGRAM_DIR/pinocchio
cargo build-sbf
ROSETTA_LIBRARY="pinocchio" SBF_OUT_DIR="$ROOT_DIR/target/deploy" cargo test --manifest-path "$PROGRAM_DIR/Cargo.toml"