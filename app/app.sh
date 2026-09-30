#!/usr/bin/env bash

# TS Academy DevOps Assignment 3
# Bash diagnostic application used by local tests, Docker, and GitHub Actions.

set -u

show_help() {
  cat <<'EOF'
Usage: app.sh <command> [arguments]

Commands:
  system-info               Display Linux system information
  check-host <host>         Resolve and check a host
  check-port <host> <port>  Validate and check TCP connectivity
  help                      Display this help message

Exit codes:
  0  success
  1  operational/runtime failure
  2  invalid command or input
EOF
}

valid_host() {
  local host="$1"
  [[ -n "$host" && "$host" =~ ^[A-Za-z0-9._:-]+$ ]]
}

resolve_host() {
  local host="$1"
  local resolved=""

  if command -v getent >/dev/null 2>&1; then
    resolved=$(getent ahostsv4 "$host" 2>/dev/null | awk 'NR==1 {print $1}')
    [[ -n "$resolved" ]] || resolved=$(getent hosts "$host" 2>/dev/null | awk 'NR==1 {print $1}')
  fi

  if [[ -z "$resolved" ]] && command -v nslookup >/dev/null 2>&1; then
    resolved=$(nslookup "$host" 2>/dev/null | awk '/^Address: / {print $2; exit}')
  fi

  printf '%s' "$resolved"
}

system_info() {
  echo "========== System Information =========="
  printf 'Hostname: %s\n' "$(hostname)"
  printf 'Current user: %s\n' "$(id -un)"
  printf 'Date/Time: %s\n' "$(date '+%Y-%m-%d %H:%M:%S %Z')"

  if [[ -r /etc/os-release ]]; then
    . /etc/os-release
    printf 'Operating system: %s\n' "${PRETTY_NAME:-${NAME:-Linux}}"
  else
    printf 'Operating system: %s\n' "$(uname -s)"
  fi

  printf 'Kernel: %s\n' "$(uname -r)"
  printf 'Architecture: %s\n' "$(uname -m)"
  printf 'Uptime: %s\n' "$(uptime 2>/dev/null || echo unavailable)"

  if command -v nproc >/dev/null 2>&1; then
    printf 'CPU cores: %s\n' "$(nproc)"
  fi

  if command -v free >/dev/null 2>&1; then
    echo "Memory:"
    free -h
  elif [[ -r /proc/meminfo ]]; then
    echo "Memory:"
    awk '/MemTotal|MemAvailable/ {print "  " $1 " " $2 " " $3}' /proc/meminfo
  fi

  echo "========================================"
  return 0
}

check_host() {
  local host="${1:-}"

  if [[ -z "$host" ]]; then
    echo "Error: check-host requires a host." >&2
    echo "Usage: app.sh check-host <host>" >&2
    return 2
  fi

  if ! valid_host "$host"; then
    echo "Error: invalid host: $host" >&2
    return 2
  fi

  local resolved
  resolved=$(resolve_host "$host")

  if [[ -z "$resolved" ]]; then
    echo "Error: unable to resolve host: $host" >&2
    return 1
  fi

  echo "Host: $host"
  echo "Resolved address: $resolved"

  if command -v ping >/dev/null 2>&1; then
    if ping -c 1 -W 2 "$host" >/dev/null 2>&1; then
      echo "Connectivity: ping reachable"
    else
      echo "Connectivity: host resolved; ping did not reply"
    fi
  else
    echo "Connectivity: host resolved; ping unavailable"
  fi

  return 0
}

check_port() {
  local host="${1:-}"
  local port="${2:-}"

  if [[ -z "$host" ]]; then
    echo "Error: check-port requires a host." >&2
    echo "Usage: app.sh check-port <host> <port>" >&2
    return 2
  fi

  if [[ -z "$port" ]]; then
    echo "Error: check-port requires a port." >&2
    echo "Usage: app.sh check-port <host> <port>" >&2
    return 2
  fi

  if ! valid_host "$host"; then
    echo "Error: invalid host: $host" >&2
    return 2
  fi

  if ! [[ "$port" =~ ^[0-9]+$ ]]; then
    echo "Error: port must be an integer from 1 to 65535." >&2
    return 2
  fi

  if (( port < 1 || port > 65535 )); then
    echo "Error: port must be between 1 and 65535." >&2
    return 2
  fi

  local resolved
  resolved=$(resolve_host "$host")
  if [[ -z "$resolved" ]]; then
    echo "Error: unable to resolve host: $host" >&2
    return 1
  fi

  echo "Host: $host"
  echo "Resolved address: $resolved"
  echo "Checking TCP port: $port"

  if command -v nc >/dev/null 2>&1; then
    if nc -z -w 3 "$host" "$port" >/dev/null 2>&1; then
      echo "TCP $host:$port is reachable"
      return 0
    fi

    echo "TCP $host:$port is closed or unreachable" >&2
    return 1
  fi

  if command -v timeout >/dev/null 2>&1; then
    if timeout 3 bash -c "exec 3<>/dev/tcp/$host/$port" >/dev/null 2>&1; then
      echo "TCP $host:$port is reachable"
      return 0
    fi

    echo "TCP $host:$port is closed or unreachable" >&2
    return 1
  fi

  echo "Error: no supported TCP connectivity utility is available." >&2
  return 1
}

if [[ $# -eq 0 ]]; then
  echo "Error: missing command." >&2
  show_help >&2
  exit 2
fi

COMMAND="$1"
shift

case "$COMMAND" in
  system-info)
    if [[ $# -ne 0 ]]; then
      echo "Error: system-info does not accept additional arguments." >&2
      exit 2
    fi
    system_info
    ;;
  check-host)
    if [[ $# -ne 1 ]]; then
      echo "Error: check-host requires exactly one host." >&2
      exit 2
    fi
    check_host "$1"
    ;;
  check-port)
    if [[ $# -ne 2 ]]; then
      echo "Error: check-port requires a host and port." >&2
      exit 2
    fi
    check_port "$1" "$2"
    ;;
  help|-h|--help)
    if [[ $# -ne 0 ]]; then
      echo "Error: help does not accept additional arguments." >&2
      exit 2
    fi
    show_help
    ;;
  *)
    echo "Error: invalid command: $COMMAND" >&2
    show_help >&2
    exit 2
    ;;
esac
