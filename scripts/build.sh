#!/usr/bin/env bash

# Build the Docker image and run smoke tests.

set -u

IMAGE="devops-tool"

if ! command -v docker >/dev/null 2>&1; then
  echo "ERROR: Docker is required." >&2
  exit 1
fi

echo "Building Docker image: $IMAGE"
docker build -t "$IMAGE" .

echo "Smoke test: help"
docker run --rm "$IMAGE" help >/tmp/devops-tool-help.log 2>&1

echo "Smoke test: system-info"
docker run --rm "$IMAGE" system-info >/tmp/devops-tool-system.log 2>&1

echo "Smoke test: invalid command must fail"
docker run --rm "$IMAGE" invalid-command >/tmp/devops-tool-invalid.log 2>&1
rc=$?

if [[ $rc -eq 0 ]]; then
  echo "ERROR: invalid command unexpectedly succeeded." >&2
  cat /tmp/devops-tool-invalid.log
  exit 1
fi

echo "Docker build and smoke tests passed."
exit 0
