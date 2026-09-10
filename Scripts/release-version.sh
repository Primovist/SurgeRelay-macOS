#!/bin/sh
set -eu

if [ -n "${SOURCE_DATE_EPOCH:-}" ]; then
  TZ=Asia/Shanghai date -r "$SOURCE_DATE_EPOCH" +%Y%m%d%H%M
else
  TZ=Asia/Shanghai date +%Y%m%d%H%M
fi
