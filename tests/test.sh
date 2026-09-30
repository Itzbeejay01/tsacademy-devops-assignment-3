#!/usr/bin/env bash

# Automated tests for app/app.sh.

set -u

APP="./app/app.sh"
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

expect_rc() {
  local name="$1"
  local expected="$2"
  shift 2

  "$@" >/tmp/assignment3-test-output.log 2>&1
  local rc=$?

  if [[ $rc -eq $expected ]]; then
    pass "$name"
  else
    fail "$name (expected $expected, got $rc)"
    cat /tmp/assignment3-test-output.log
  fi
}

if [[ ! -x "$APP" ]]; then
  echo "ERROR: $APP is not executable." >&2
  exit 1
fi

expect_rc "help succeeds" 0 "$APP" help
expect_rc "system-info succeeds" 0 "$APP" system-info
expect_rc "invalid command returns exit code 2" 2 "$APP" invalid-command
expect_rc "missing host for check-host returns exit code 2" 2 "$APP" check-host
expect_rc "valid localhost check succeeds" 0 "$APP" check-host localhost
expect_rc "missing port returns exit code 2" 2 "$APP" check-port localhost
expect_rc "non-numeric port returns exit code 2" 2 "$APP" check-port localhost abc
expect_rc "port 0 returns exit code 2" 2 "$APP" check-port localhost 0
expect_rc "port 65536 returns exit code 2" 2 "$APP" check-port localhost 65536
expect_rc "missing command returns exit code 2" 2 "$APP"

# Temporary intentional failure for the required CI failure demonstration.
expect_rc "intentional CI failure demonstration" 0 bash -c "exit 1"

echo
echo "=============================="
echo "Tests passed: $PASS"
echo "Tests failed: $FAIL"
echo "=============================="

[[ $FAIL -eq 0 ]]
