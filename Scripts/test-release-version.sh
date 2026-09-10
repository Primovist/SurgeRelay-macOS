#!/bin/sh
set -eu

script_dir=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
version=$(SOURCE_DATE_EPOCH=1789012440 "$script_dir/release-version.sh")

case "$version" in
  [0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]) ;;
  *) echo "invalid release version: $version" >&2; exit 1 ;;
esac

[ "$version" = "202609101154" ] || {
  echo "expected Asia/Shanghai version 202609101154, got $version" >&2
  exit 1
}
