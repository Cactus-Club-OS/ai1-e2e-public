#!/usr/bin/env bash
# Supply-chain guard: a pull request may add or update packages, but only from the
# approved registry. Fails if the diff adds a dependency from git, a URL, a local
# path, or a different registry.
# Inputs (env): BASE_REF (the pull request's target branch, e.g. main)
# Optional:     ALLOWED_REGISTRY (default https://registry.npmjs.org/)
set -euo pipefail

base="origin/${BASE_REF:?BASE_REF not set}"
allowed="${ALLOWED_REGISTRY:-https://registry.npmjs.org/}"
git fetch --quiet origin "$BASE_REF" || true

added_lines() { git diff --unified=0 "$base"...HEAD -- "$@" | grep -E '^\+[^+]' || true; }

added_pkg=$(added_lines 'package.json' '**/package.json')
added_lock=$(added_lines 'package-lock.json' '**/package-lock.json' 'npm-shrinkwrap.json' '**/npm-shrinkwrap.json')
added_npmrc=$(added_lines '.npmrc' '**/.npmrc')

problems=""

# Lockfile: every newly added "resolved" URL must come from the allowed registry.
bad_resolved=$(printf '%s\n' "$added_lock" | grep -E '"resolved":' | grep -Fv "\"$allowed" || true)
[ -n "$bad_resolved" ] && problems+=$'\nLockfile entries from outside the approved registry:\n'"$bad_resolved"

# package.json: no git / URL / file / tarball dependency specs.
# Metadata fields that legitimately hold URLs are ignored.
bad_spec=$(printf '%s\n' "$added_pkg" \
  | grep -Ev '"(homepage|url|funding|bugs|repository|author|email|\$schema|type)":' \
  | grep -E '"[^"]+":[[:space:]]*"(git\+|git:|github:|gitlab:|bitbucket:|https?:|file:|link:)' || true)
[ -n "$bad_spec" ] && problems+=$'\nDependencies from git, a URL or a local path:\n'"$bad_spec"

# .npmrc: no new registry lines.
bad_registry=$(printf '%s\n' "$added_npmrc" | grep -Ei 'registry[[:space:]]*=' || true)
[ -n "$bad_registry" ] && problems+=$'\nNew registry settings in .npmrc:\n'"$bad_registry"

if [ -n "$problems" ]; then
  echo "::error::Supply-chain guard failed. A maintainer must review these dependency sources before merge."
  printf '%s\n' "$problems"
  exit 1
fi
echo "Dependency sources: OK (only $allowed)."
