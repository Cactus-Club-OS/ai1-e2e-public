#!/usr/bin/env bash
# Fail the check when a pull request is marked "do not merge".
# Inputs (env): PR_TITLE, PR_LABELS (comma-separated)
set -euo pipefail

hold_labels='^(hold|on-hold|do-not-merge|dnm|wip|needs-qa|blocked)$'
title="${PR_TITLE:-}"
labels="${PR_LABELS:-}"

IFS=',' read -r -a label_list <<< "$labels"
for label in "${label_list[@]}"; do
  if printf '%s' "$label" | tr '[:upper:]' '[:lower:]' | grep -Eq "$hold_labels"; then
    echo "::error::On hold: label '$label' is set. Remove it when the change is ready to merge."
    exit 1
  fi
done

if printf '%s' "$title" | grep -Eiq '(\[(wip|hold|draft|dnm)[^]]*\]|do not merge|do-not-merge)'; then
  echo "::error::On hold: the title says this is not ready (WIP / hold / draft / do not merge)."
  exit 1
fi

echo "Hold guard: not on hold."
