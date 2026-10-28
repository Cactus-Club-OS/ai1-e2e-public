#!/usr/bin/env bash
# Fail if the repository contains files that usually hold secrets.
# Belt-and-braces for the push ruleset; works on every GitHub plan.
set -euo pipefail

pattern='(^|/)(\.env(\.[A-Za-z0-9_-]+)?|.*\.pem|.*\.key|.*\.p12|.*\.pfx|id_rsa|id_ed25519|.*\.env\.bak.*|\.env\.bak.*)$'
allowed='(^|/)\.env\.(example|sample|template)$'

hits=$(git ls-files | grep -E "$pattern" | grep -Ev "$allowed" || true)
if [ -n "$hits" ]; then
  echo "::error::Secret-type files are tracked in git. Remove them, rotate anything they contained, and use .env.example for placeholders:"
  printf '%s\n' "$hits" | sed 's/^/  /'
  exit 1
fi
echo "Forbidden files: none found."
