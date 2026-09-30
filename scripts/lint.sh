#!/usr/bin/env bash

# Validate required project files and Bash syntax.

set -u

PASS=0
FAIL=0

pass() {
  echo "PASS: $1"
  PASS=$((PASS + 1))
}

fail() {
  echo "FAIL: $1"
  FAIL=$((FAIL + 1))
}

required_files=(
  "README.md"
  "app/app.sh"
  "scripts/lint.sh"
  "scripts/build.sh"
  "tests/test.sh"
  "Dockerfile"
  "compose.yaml"
  ".dockerignore"
  ".github/workflows/ci.yml"
  "grade.sh"
)

for file in "${required_files[@]}"; do
  if [[ -f "$file" ]]; then
    pass "Required file exists: $file"
  else
    fail "Missing required file: $file"
  fi
done

bash_files=(
  "app/app.sh"
  "scripts/lint.sh"
  "scripts/build.sh"
  "tests/test.sh"
  "grade.sh"
)

for file in "${bash_files[@]}"; do
  if [[ ! -f "$file" ]]; then
    continue
  fi

  if bash -n "$file" >/dev/null 2>&1; then
    pass "Bash syntax: $file"
  else
    fail "Bash syntax error: $file"
  fi
done

echo
echo "=============================="
echo "Lint passed: $PASS"
echo "Lint failed: $FAIL"
echo "=============================="

[[ $FAIL -eq 0 ]]
