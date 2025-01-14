#!/usr/bin/env bash

set -eufx -o pipefail

# Supported cross systems
CROSS_SYSTEMS=(
  'null'
  '{ config = "x86_64-unknown-linux-musl"; useLLVM = true; isStatic = false; }'
  '{ config = "x86_64-unknown-linux-musl"; useLLVM = true; isStatic = true; }'
  '{ config = "x86_64-unknown-linux-musl"; useLLVM = false; isStatic = false; }'
  '{ config = "aarch64-unknown-linux-musl"; useLLVM = true; isStatic = false; }'
  '{ config = "aarch64-unknown-linux-musl"; useLLVM = true; isStatic = true; }'
  '{ config = "aarch64-unknown-linux-musl"; useLLVM = false; isStatic = false; }'
  `{ config = "riscv64-unknown-linux-gnu"; useLLVM = false; isStatic = false; }`
)

for CROSS_SYSTEM in "${CROSS_SYSTEMS[@]}"
do
  echo "-> Compiling '${CROSS_SYSTEM}' cross system"
  BUILD_OUTPUT=$(nix-build shell.nix -A inputDerivation --arg crossSystem "${CROSS_SYSTEM}")

  echo "-> Performing '${CROSS_SYSTEM}' testing"
  nix-shell --pure --arg crossSystem "${CROSS_SYSTEM}" --run ./tests/crates/build_all.sh

  echo "-> Pushing '${CROSS_SYSTEM}' artifacts to the Cachix"
  cachix push nixpkgs-cross-overlay "$BUILD_OUTPUT"
done
