#!/usr/bin/env bash
# Flag pull requests that change the gates themselves. This step does not block on its own:
# CODEOWNERS + the "require code owner review" rule do the blocking. It makes the change
# visible in the run summary so nobody approves it by accident.
# Inputs (env): BASE_REF
set -euo pipefail

base="origin/${BASE_REF:?BASE_REF not set}"
git fetch --quiet origin "$BASE_REF" || true

gate_files=$(git diff --name-only "$base"...HEAD \
  | grep -E '^(\.github/|CODEOWNERS$|\.github/CODEOWNERS$|scripts/ci/|\.node-version$)' || true)

if [ -n "$gate_files" ]; then
  echo "::warning::This pull request changes gate files. It needs a code-owner review and must never auto-merge."
  {
    echo "### Gate change"
    echo "This pull request changes the checks or review rules. A human code owner must review it."
    echo
    printf '%s\n' "$gate_files" | sed 's/^\(.*\)$/- `\1`/'
  } >> "${GITHUB_STEP_SUMMARY:-/dev/null}"
else
  echo "Gate files: unchanged."
fi
