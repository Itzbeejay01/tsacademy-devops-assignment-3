# TS Academy DevOps Assignment 3

## CI/CD with GitHub Actions

This repository contains my solution for **Assignment 3 — CI/CD with GitHub Actions** from the TS Academy DevOps practical assignment.

The project provides a Bash diagnostic application, automated linting and tests, Docker packaging, Docker smoke tests, and a GitHub Actions workflow with ordered jobs:

```text
validate
   |
   v
 test
   |
   v
docker
```

## Project Structure

```text
.
├── README.md
├── app/
│   └── app.sh
├── scripts/
│   ├── lint.sh
│   └── build.sh
├── tests/
│   └── test.sh
├── .github/
│   └── workflows/
│       └── ci.yml
├── Dockerfile
├── compose.yaml
├── .dockerignore
└── grade.sh
```

## Application Commands

```bash
./app/app.sh system-info
./app/app.sh check-host <host>
./app/app.sh check-port <host> <port>
./app/app.sh help
```

Exit codes:

- `0` — success
- `1` — operational/runtime failure
- `2` — invalid command or input

## Setup

Clone the repository:

```bash
git clone https://github.com/Itzbeejay01/tsacademy-devops-assignment-3.git
cd tsacademy-devops-assignment-3
```

Ensure the Bash scripts are executable:

```bash
chmod +x grade.sh app/*.sh scripts/*.sh tests/*.sh
```

## Run the Application

```bash
./app/app.sh help
./app/app.sh system-info
./app/app.sh check-host localhost
./app/app.sh check-port example.com 443
```

## Linting

The lint script verifies required files and runs `bash -n` syntax validation against the Bash scripts.

```bash
./scripts/lint.sh
```

## Automated Tests

The test suite contains more than eight meaningful tests covering help, system information, invalid commands, missing arguments, valid host handling, and port validation.

```bash
./tests/test.sh
```

## Docker

Build the image:

```bash
docker build -t devops-tool .
```

Smoke-test it:

```bash
docker run --rm devops-tool help
docker run --rm devops-tool system-info
```

Or use the provided build script:

```bash
./scripts/build.sh
```

Docker Compose can also run the tool:

```bash
docker compose run --rm devops-tool help
docker compose run --rm devops-tool system-info
```

## GitHub Actions

The workflow in `.github/workflows/ci.yml` runs on both `push` and `pull_request`.

The jobs are intentionally ordered with `needs:`:

1. `validate` runs linting.
2. `test` runs only after `validate` succeeds.
3. `docker` runs only after `test` succeeds and builds/smoke-tests the image.

## CI Failure Demonstration

A feature branch is used to deliberately introduce a failing test so that GitHub Actions records a failed CI run. The failure is then corrected in a follow-up commit and CI is run again successfully. The final repository state is passing.

## Local Grading

Run:

```bash
./grade.sh
```

The supplied grader checks repository structure, Bash syntax, executable permissions, workflow triggers and job dependencies, application behaviour, linting, Docker build/smoke tests, the student test suite, and basic Git history.

## Assumptions

- The scripts are graded in a Linux environment.
- Docker is installed and running for Docker checks.
- Network connectivity may vary, so a successfully resolved host is treated as a successful host check even when ICMP/ping is blocked.
- No cloud deployment is required.
