#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
PROJECTS=("$@")

if [ ${#PROJECTS[@]} -eq 0 ]; then
  PROJECTS=(flopoco zpu hardh264 synthetic/bigram jcore riscv-w7 neorv32
            mixed_cic fft/verilog)
fi

TMP_DIR=$(mktemp -d)
trap 'rm -rf "$TMP_DIR"' EXIT

for project in "${PROJECTS[@]}"; do
  dir="$ROOT_DIR/$project"
  json_file="$TMP_DIR/$project.json"

  mkdir -p $(dirname "$json_file")

  (cd "$dir" && JSON_FILE="$json_file" TIME=json ./test.sh)
done

for project in "${PROJECTS[@]}"; do
  json_file="$TMP_DIR/$project.json"

  min_ms=$(jq -rs '
        map(.results[0].min)
        | map(select(. != null))
        | min? // empty
        | . * 1000
      ' "$json_file" | awk 'NF { printf "%.0f\n", $1 }')

  printf "$min_ms\t"
done

echo
