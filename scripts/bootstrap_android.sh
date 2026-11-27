#!/usr/bin/env bash
set -euo pipefail

if ! command -v flutter >/dev/null 2>&1; then
  echo "Flutter is required. Install Flutter stable and ensure it is on PATH." >&2
  exit 1
fi

if [ ! -d android ]; then
  flutter create --platforms=android --org com.sbikazis --project-name x12o .
fi

flutter pub get
