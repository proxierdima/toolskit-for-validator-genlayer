#!/usr/bin/env bash
set -Eeuo pipefail

DIR="${1:-}"
if [[ -z "$DIR" ]]; then
  read -r -p "Enter full install path (DIR): " DIR
fi
[[ -n "$DIR" ]] || { echo "ERROR: DIR is empty" >&2; exit 1; }

mkdir -p "$DIR"
mkdir -p "$DIR/checks"
mkdir -p "$DIR/docs"
mkdir -p "$DIR/examples"
mkdir -p "$DIR/install"
mkdir -p "$DIR/monitor"
mkdir -p "$DIR/recovery"

FILE="toolkit.sh"
cat > "$DIR/$FILE" <<'EOF'
#!/usr/bin/env bash
set -Eeuo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
GENLAYER_WORKSPACE="${GENLAYER_WORKSPACE:-$HOME/genlayer}"

need_cmd() {
  command -v "$1" >/dev/null 2>&1 || {
    echo "ERROR: missing command: $1" >&2
    exit 1
  }
}

ui_header() {
  gum style \
    --border rounded \
    --padding "1 2" \
    --margin "1 0" \
    --foreground 212 \
    --border-foreground 212 \
    "GenLayer Validator Toolkit" \
    "A practical operator toolkit for deployment, validation, monitoring, and recovery of GenLayer full nodes and validators."
}

show_workspace_info() {
  gum style --border rounded --padding "1 2" --margin "1 0" "$(printf '%s\n' \
    "Workspace: $GENLAYER_WORKSPACE" \
    "Toolkit:   $ROOT_DIR")"
}

run_script() {
  local script="$1"
  shift || true
  GENLAYER_WORKSPACE="$GENLAYER_WORKSPACE" "$script" "$@"
}

pager_file() {
  local file="$1"
  if command -v less >/dev/null 2>&1; then
    less -R "$file"
  else
    cat "$file"
  fi
}

install_menu() {
  while true; do
    ui_header
    show_workspace_info

    local choice
    choice="$(
      gum choose --header "Install" \
        "Install full node" \
        "Install validator" \
        "Bootstrap workspace" \
        "Reinstall workspace" \
        "Configure existing node" \
        "Back"
    )" || return 0

    case "$choice" in
      "Install full node")
        run_script "$ROOT_DIR/install/install_fullnode.sh"
        ;;
      "Install validator")
        run_script "$ROOT_DIR/install/install_validator.sh"
        ;;
      "Bootstrap workspace")
        run_script "$ROOT_DIR/install/bootstrap_workspace.sh"
        ;;
      "Reinstall workspace")
        FORCE_BOOTSTRAP=1 run_script "$ROOT_DIR/install/bootstrap_workspace.sh"
        ;;
      "Configure existing node")
        run_script "$ROOT_DIR/install/configure_existing_node.sh"
        ;;
      "Back")
        return 0
        ;;
    esac
  done
}

checks_menu() {
  while true; do
    ui_header
    show_workspace_info

    local choice
    choice="$(
      gum choose --header "Checks" \
        "Preflight config" \
        "Doctor wrapper" \
        "Check RPC" \
        "Check WSS" \
        "Check sync / health" \
        "Back"
    )" || return 0

    case "$choice" in
      "Preflight config")
        run_script "$ROOT_DIR/checks/check_config.py" "$GENLAYER_WORKSPACE"
        ;;
      "Doctor wrapper")
        run_script "$ROOT_DIR/checks/doctor_wrapper.sh"
        ;;
      "Check RPC")
        run_script "$ROOT_DIR/checks/check_rpc.sh"
        ;;
      "Check WSS")
        run_script "$ROOT_DIR/checks/check_wss.sh"
        ;;
      "Check sync / health")
        run_script "$ROOT_DIR/checks/check_sync_health.sh"
        ;;
      "Back")
        return 0
        ;;
    esac

    printf '\n'
    read -r -p "Press Enter to continue..."
  done
}

monitor_menu() {
  while true; do
    ui_header
    show_workspace_info

    local choice
    choice="$(
      gum choose --header "Monitor" \
        "Run one-shot health monitor" \
        "Run watch loop" \
        "Telegram alert test" \
        "Prometheus notes" \
        "Back"
    )" || return 0

    case "$choice" in
      "Run one-shot health monitor")
        run_script "$ROOT_DIR/monitor/genlayer_health_monitor.sh"
        ;;
      "Run watch loop")
        WATCH=1 run_script "$ROOT_DIR/monitor/genlayer_health_monitor.sh"
        ;;
      "Telegram alert test")
        TEST_MESSAGE="GenLayer toolkit test alert" run_script "$ROOT_DIR/monitor/telegram_alerts.sh"
        ;;
      "Prometheus notes")
        pager_file "$ROOT_DIR/monitor/prometheus/README.md"
        ;;
      "Back")
        return 0
        ;;
    esac

    printf '\n'
    read -r -p "Press Enter to continue..."
  done
}

recovery_menu() {
  while true; do
    ui_header
    show_workspace_info

    local choice
    choice="$(
      gum choose --header "Recovery" \
        "Safe restart" \
        "Resync node" \
        "Diagnose and fix" \
        "Back"
    )" || return 0

    case "$choice" in
      "Safe restart")
        run_script "$ROOT_DIR/recovery/safe_restart.sh"
        ;;
      "Resync node")
        run_script "$ROOT_DIR/recovery/resync_node.sh"
        ;;
      "Diagnose and fix")
        run_script "$ROOT_DIR/recovery/diagnose_and_fix.sh"
        ;;
      "Back")
        return 0
        ;;
    esac

    printf '\n'
    read -r -p "Press Enter to continue..."
  done
}

docs_menu() {
  while true; do
    ui_header
    show_workspace_info

    local choice
    choice="$(
      gum choose --header "Docs" \
        "Troubleshooting" \
        "Architecture" \
        "Runbook" \
        "Back"
    )" || return 0

    case "$choice" in
      "Troubleshooting")
        pager_file "$ROOT_DIR/docs/troubleshooting.md"
        ;;
      "Architecture")
        pager_file "$ROOT_DIR/docs/architecture.md"
        ;;
      "Runbook")
        pager_file "$ROOT_DIR/docs/runbook.md"
        ;;
      "Back")
        return 0
        ;;
    esac
  done
}

examples_menu() {
  while true; do
    ui_header
    show_workspace_info

    local choice
    choice="$(
      gum choose --header "Examples" \
        "env.example" \
        "config.yaml" \
        "docker-compose.override.yaml" \
        "Back"
    )" || return 0

    case "$choice" in
      "env.example")
        pager_file "$ROOT_DIR/examples/env.example"
        ;;
      "config.yaml")
        pager_file "$ROOT_DIR/examples/config.yaml"
        ;;
      "docker-compose.override.yaml")
        pager_file "$ROOT_DIR/examples/docker-compose.override.yaml"
        ;;
      "Back")
        return 0
        ;;
    esac
  done
}

main() {
  need_cmd bash
  need_cmd python3
  need_cmd gum
  need_cmd curl
  need_cmd jq

  while true; do
    ui_header
    show_workspace_info

    local choice
    choice="$(
      gum choose --header "Main menu" \
        "Install" \
        "Checks" \
        "Monitor" \
        "Recovery" \
        "Docs" \
        "Examples" \
        "Exit"
    )" || exit 0

    case "$choice" in
      "Install")
        install_menu
        ;;
      "Checks")
        checks_menu
        ;;
      "Monitor")
        monitor_menu
        ;;
      "Recovery")
        recovery_menu
        ;;
      "Docs")
        docs_menu
        ;;
      "Examples")
        examples_menu
        ;;
      "Exit")
        exit 0
        ;;
    esac
  done
}

main "$@"
EOF

FILE="install/bootstrap_workspace.sh"
cat > "$DIR/$FILE" <<'EOF'
#!/usr/bin/env bash
set -Eeuo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
GENLAYER_WORKSPACE="${GENLAYER_WORKSPACE:-$HOME/genlayer}"
NODE_VERSION="${NODE_VERSION:-v0.5.7}"
GENVM_EXECUTOR_VERSION="${GENVM_EXECUTOR_VERSION:-v0.2.16}"
FORCE_BOOTSTRAP="${FORCE_BOOTSTRAP:-0}"

NODE_URL="https://storage.googleapis.com/gh-af/genlayer-node/bin/amd64/${NODE_VERSION}/genlayer-node-linux-amd64-${NODE_VERSION}.tar.gz"
GENVM_EXECUTOR_URL="https://github.com/genlayerlabs/genvm/releases/download/${GENVM_EXECUTOR_VERSION}/genvm-linux-amd64-executor.tar.xz"

SUDO=""
if [[ "${EUID:-$(id -u)}" -ne 0 ]]; then
  SUDO="sudo"
fi

log() { printf '%s\n' "$*"; }
need_cmd() { command -v "$1" >/dev/null 2>&1 || { echo "ERROR: missing command: $1" >&2; exit 1; }; }

workspace_ready() {
  [[ -d "$GENLAYER_WORKSPACE" ]] || return 1
  [[ -f "$GENLAYER_WORKSPACE/docker-compose.yaml" ]] || return 1
  [[ -f "$GENLAYER_WORKSPACE/configs/node/config.yaml" ]] || return 1
  [[ -f "$GENLAYER_WORKSPACE/genvm-module-web-docker.yaml" ]] || return 1
  [[ -x "$GENLAYER_WORKSPACE/bin/genlayernode" ]] || return 1
  [[ -d "$GENLAYER_WORKSPACE/third_party/genvm/executor" ]] || return 1
  return 0
}

install_base_packages() {
  need_cmd apt-get

  $SUDO apt-get update
  $SUDO apt-get install -y \
    ca-certificates \
    curl \
    wget \
    tar \
    xz-utils \
    jq \
    python3 \
    rsync \
    gpg \
    lsb-release

  if ! command -v gum >/dev/null 2>&1; then
    $SUDO mkdir -p /etc/apt/keyrings
    curl -fsSL https://repo.charm.sh/apt/gpg.key | $SUDO gpg --dearmor -o /etc/apt/keyrings/charm.gpg
    echo "deb [signed-by=/etc/apt/keyrings/charm.gpg] https://repo.charm.sh/apt/ * *" | $SUDO tee /etc/apt/sources.list.d/charm.list >/dev/null
    $SUDO apt-get update
    $SUDO apt-get install -y gum
  fi

  if ! command -v docker >/dev/null 2>&1; then
    printf '%s\n' "WARN: docker not found. In WSL use Docker Desktop integration. On Linux install Docker separately."
  fi
}

download_file() {
  local url="$1"
  local out="$2"

  if command -v curl >/dev/null 2>&1; then
    curl -fL --retry 3 --connect-timeout 15 -o "$out" "$url"
  else
    wget -O "$out" "$url"
  fi
}

extract_node_archive() {
  local archive="$1"
  local tmpdir="$2"

  mkdir -p "$tmpdir/node"
  tar -xzf "$archive" -C "$tmpdir/node"

  local root
  root="$(find "$tmpdir/node" -mindepth 1 -maxdepth 1 -type d | head -n1)"
  [[ -n "$root" && -d "$root" ]] || {
    echo "ERROR: failed to detect node archive root" >&2
    exit 1
  }

  if [[ -d "$GENLAYER_WORKSPACE" ]]; then
    local backup="${GENLAYER_WORKSPACE}.backup.$(date +%Y%m%d%H%M%S)"
    mv "$GENLAYER_WORKSPACE" "$backup"
    log "Existing workspace moved to: $backup"
  fi

  mkdir -p "$(dirname "$GENLAYER_WORKSPACE")"
  mv "$root" "$GENLAYER_WORKSPACE"
}

extract_genvm_executor() {
  local archive="$1"
  local tmpdir="$2"

  mkdir -p "$tmpdir/genvm"
  tar -xJf "$archive" -C "$tmpdir/genvm"

  local dst="$GENLAYER_WORKSPACE/third_party/genvm/executor"
  mkdir -p "$dst"

  if [[ -d "$tmpdir/genvm/executor" ]]; then
    rsync -a "$tmpdir/genvm/executor/" "$dst/"
  else
    rsync -a "$tmpdir/genvm/" "$dst/"
  fi
}

main() {
  install_base_packages

  if workspace_ready && [[ "$FORCE_BOOTSTRAP" != "1" ]]; then
    log "Workspace already ready: $GENLAYER_WORKSPACE"
    exit 0
  fi

  local tmpdir
  tmpdir="$(mktemp -d)"
  trap 'rm -rf "$tmpdir"' EXIT

  local node_archive="$tmpdir/genlayer-node.tar.gz"
  local executor_archive="$tmpdir/genvm-executor.tar.xz"

  log "Downloading node package: $NODE_VERSION"
  download_file "$NODE_URL" "$node_archive"

  log "Downloading genvm executor: $GENVM_EXECUTOR_VERSION"
  download_file "$GENVM_EXECUTOR_URL" "$executor_archive"

  log "Extracting node archive"
  extract_node_archive "$node_archive" "$tmpdir"

  log "Extracting genvm executor"
  extract_genvm_executor "$executor_archive" "$tmpdir"

  if [[ ! -f "$GENLAYER_WORKSPACE/.env" && -f "$GENLAYER_WORKSPACE/.env.example" ]]; then
    cp "$GENLAYER_WORKSPACE/.env.example" "$GENLAYER_WORKSPACE/.env"
    log "Created .env from .env.example"
  fi

  log "Workspace ready: $GENLAYER_WORKSPACE"
}

main "$@"
EOF

FILE="install/configure_existing_node.sh"
cat > "$DIR/$FILE" <<'EOF'
#!/usr/bin/env bash
set -Eeuo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
GENLAYER_WORKSPACE="${GENLAYER_WORKSPACE:-$HOME/genlayer}"

DEFAULT_HTTP="https://zksync-os-testnet-genlayer.zksync.dev"
DEFAULT_WS="wss://zksync-os-testnet-genlayer.zksync.dev/ws"

DEFAULT_NODE_VERSION="v0.5.7"
DEFAULT_LOGGING_LEVEL="INFO"

HOST_WEBDRIVER_PORT="4444"
HOST_RPC_PORT="9151"
HOST_OPS_PORT="9153"

INTERNAL_ADMIN_PORT="9155"
INTERNAL_RPC_PORT="9151"
INTERNAL_OPS_PORT="9153"

DEFAULT_WEBDRIVER_HOST="http://webdriver-container:4444"

ENV_FILE="$GENLAYER_WORKSPACE/.env"
NODE_CONFIG_FILE="$GENLAYER_WORKSPACE/configs/node/config.yaml"
GENVM_WEB_FILE="$GENLAYER_WORKSPACE/genvm-module-web-docker.yaml"

need_cmd() {
  command -v "$1" >/dev/null 2>&1 || {
    echo "ERROR: missing command: $1" >&2
    exit 1
  }
}

die() {
  echo "ERROR: $*" >&2
  exit 1
}

ui_header() {
  gum style \
    --border rounded \
    --padding "1 2" \
    --margin "1 0" \
    --foreground 212 \
    --border-foreground 212 \
    "GenLayer Node Setup" \
    "modern wizard on gum"
}

ui_step() { gum style --bold --foreground 86 "$1"; }
ui_note() { gum style --foreground 245 "$1"; }
ui_kv() { gum format "{{ Bold \"$1\" }}: $2"; }

ensure_repo_layout() {
  [[ -x "$GENLAYER_WORKSPACE/bin/genlayernode" ]] || die "missing $GENLAYER_WORKSPACE/bin/genlayernode"
  [[ -f "$GENLAYER_WORKSPACE/docker-compose.yaml" ]] || die "missing $GENLAYER_WORKSPACE/docker-compose.yaml"
  [[ -f "$GENLAYER_WORKSPACE/third_party/genvm/bin/setup.py" ]] || die "missing $GENLAYER_WORKSPACE/third_party/genvm/bin/setup.py"
  [[ -f "$ENV_FILE" ]] || die "missing $ENV_FILE"
  [[ -f "$NODE_CONFIG_FILE" ]] || die "missing $NODE_CONFIG_FILE"
  [[ -f "$GENVM_WEB_FILE" ]] || die "missing $GENVM_WEB_FILE"
}

is_http_url() { [[ "$1" =~ ^https?://[^[:space:]]+$ ]]; }
is_ws_url()   { [[ "$1" =~ ^wss?://[^[:space:]]+$ ]]; }
is_eth_addr() { [[ "$1" =~ ^0x[0-9a-fA-F]{40}$ ]]; }
is_uint()     { [[ "$1" =~ ^[0-9]+$ ]]; }
is_env_name() { [[ "$1" =~ ^[A-Z_][A-Z0-9_]*$ ]]; }

ask_input() {
  local prompt="$1"
  local value="${2:-}"
  gum input --prompt "> " --placeholder "$prompt" --value "$value"
}

ask_password() {
  local prompt="$1"
  gum input --password --prompt "> " --placeholder "$prompt"
}

ask_required_input() {
  local prompt="$1"
  local def="${2:-}"
  local out
  while true; do
    out="$(ask_input "$prompt" "$def")" || exit 1
    [[ -n "$out" ]] && { printf '%s' "$out"; return 0; }
    gum log --level error "Значение обязательно"
  done
}

ask_http_url() {
  local prompt="$1" def="$2" v
  while true; do
    v="$(ask_input "$prompt" "$def")" || exit 1
    if is_http_url "$v"; then
      printf '%s' "$v"
      return 0
    fi
    gum log --level error "Ожидается HTTP URL формата http:// или https://"
  done
}

ask_ws_url() {
  local prompt="$1" def="$2" v
  while true; do
    v="$(ask_input "$prompt" "$def")" || exit 1
    if is_ws_url "$v"; then
      printf '%s' "$v"
      return 0
    fi
    gum log --level error "Ожидается WSS / WS URL формата ws:// или wss://"
  done
}

ask_eth_addr() {
  local prompt="$1" def="${2:-}" v
  while true; do
    v="$(ask_input "$prompt" "$def")" || exit 1
    if is_eth_addr "$v"; then
      printf '%s' "$v"
      return 0
    fi
    gum log --level error "Ожидается адрес формата 0x + 40 hex-символов"
  done
}

ask_password_twice() {
  local label="$1" a b
  while true; do
    a="$(ask_password "$label")" || exit 1
    [[ -n "$a" ]] || { gum log --level error "Значение обязательно"; continue; }
    b="$(ask_password "Повторите: $label")" || exit 1
    [[ "$a" == "$b" ]] && { printf '%s' "$a"; return 0; }
    gum log --level error "Пароли не совпадают"
  done
}

choose_network() {
  ui_step "Шаг 1 из 7 · сеть"
  NETWORK_NAME="$(
    gum choose \
      --header "Выберите сеть" \
      "Asimov" \
      "Bradbury" \
      "Custom"
  )" || exit 1

  case "$NETWORK_NAME" in
    Asimov)
      RPC_URL_DEFAULT="$DEFAULT_HTTP"
      WS_URL_DEFAULT="$DEFAULT_WS"
      CONSENSUS_ADDRESS="0xe66B434bc83805f380509642429eC8e43AE9874a"
      GENESIS="17326"
      ;;
    Bradbury)
      RPC_URL_DEFAULT="$DEFAULT_HTTP"
      WS_URL_DEFAULT="$DEFAULT_WS"
      CONSENSUS_ADDRESS="0x8aCE036C8C3C5D603dB546b031302FCf149648E8"
      GENESIS="501711"
      ;;
    Custom)
      RPC_URL_DEFAULT="$DEFAULT_HTTP"
      WS_URL_DEFAULT="$DEFAULT_WS"
      CONSENSUS_ADDRESS="$(ask_eth_addr "Custom: consensus AddressManager address")"
      while true; do
        GENESIS="$(ask_input "Custom: genesis block number" "17326")" || exit 1
        is_uint "$GENESIS" && break
        gum log --level error "Genesis должен быть целым числом"
      done
      ;;
    *)
      die "unknown network"
      ;;
  esac
}

ask_rpc_screen() {
  ui_step "Шаг 2 из 7 · RPC"
  RPC_URL="$(ask_http_url "HTTP RPC URL" "$RPC_URL_DEFAULT")"
  WS_URL="$(ask_ws_url "WSS / WS RPC URL" "$WS_URL_DEFAULT")"
}

choose_mode() {
  ui_step "Шаг 3 из 7 · режим"

  if [[ "${DEFAULT_NODE_MODE:-}" == "full" || "${DEFAULT_NODE_MODE:-}" == "validator" ]]; then
    NODE_MODE="$DEFAULT_NODE_MODE"
    gum style --foreground 245 "Использую предустановленный режим: $NODE_MODE"
  else
    NODE_MODE="$(
      gum choose \
        --header "Выберите режим ноды" \
        "full" \
        "validator"
    )" || exit 1
  fi

  case "$NODE_MODE" in
    full)
      VALIDATOR_WALLET_ADDRESS=""
      OPERATOR_ADDRESS=""
      BALANCE_ENDPOINT="false"
      ;;
    validator)
      VALIDATOR_WALLET_ADDRESS="$(ask_eth_addr "validator wallet address")"
      OPERATOR_ADDRESS="$(ask_eth_addr "operator address")"
      BALANCE_ENDPOINT="true"
      ;;
    *)
      die "unknown mode"
      ;;
  esac
}

choose_llm_provider() {
  ui_step "Шаг 4 из 7 · LLM provider"
  local choice
  choice="$(
    gum choose \
      --header "Выберите LLM provider" \
      "OPENROUTERKEY" \
      "HEURISTKEY" \
      "GEMINIKEY" \
      "ANTHROPICKEY" \
      "COMPUT3KEY" \
      "IOINTELLIGENCE_API_KEY" \
      "XAIKEY" \
      "ATOMAKEY" \
      "CHUTES_API_KEY" \
      "MORPHEUS_API_KEY" \
      "Custom"
  )" || exit 1

  if [[ "$choice" == "Custom" ]]; then
    while true; do
      LLM_VAR_NAME="$(ask_input "Имя env-переменной LLM provider" "OPENROUTERKEY")" || exit 1
      LLM_VAR_NAME="$(printf '%s' "$LLM_VAR_NAME" | tr '[:lower:]' '[:upper:]')"
      is_env_name "$LLM_VAR_NAME" && break
      gum log --level error "Имя должно быть в формате UPPER_CASE_WITH_UNDERSCORES"
    done
  else
    LLM_VAR_NAME="$choice"
  fi
}

ask_api_key_screen() {
  ui_step "Шаг 5 из 7 · API key"
  ui_note "Ввод видимый. Подтверждение не требуется."
  LLM_VAR_VALUE="$(ask_required_input "API key для $LLM_VAR_NAME")"
}

ask_password_screen() {
  ui_step "Шаг 6 из 7 · пароль ноды"
  NODE_PASSWORD="$(ask_password_twice "Пароль для node keystore")"
}

show_summary_and_confirm() {
  ui_step "Шаг 7 из 7 · проверка"

  local summary
  summary="$(cat <<EOF2
$(ui_kv "Сеть" "$NETWORK_NAME")
$(ui_kv "HTTP RPC" "$RPC_URL")
$(ui_kv "WSS RPC" "$WS_URL")
$(ui_kv "Consensus address" "$CONSENSUS_ADDRESS")
$(ui_kv "Genesis" "$GENESIS")
$(ui_kv "Режим" "$NODE_MODE")
$(ui_kv "Validator wallet" "${VALIDATOR_WALLET_ADDRESS:-<empty>}")
$(ui_kv "Operator address" "${OPERATOR_ADDRESS:-<empty>}")
$(ui_kv "LLM provider" "$LLM_VAR_NAME")

$(ui_note "Будут изменены только существующие файлы:")
- .env
- configs/node/config.yaml
- genvm-module-web-docker.yaml
EOF2
)"
  gum style --border rounded --padding "1 2" --margin "1 0" "$summary"
  gum confirm "Применить изменения?" || exit 1
}

backup_existing() {
  local ts
  ts="$(date +%Y%m%d%H%M%S)"
  cp "$ENV_FILE" "$ENV_FILE.bak.$ts"
  cp "$NODE_CONFIG_FILE" "$NODE_CONFIG_FILE.bak.$ts"
  cp "$GENVM_WEB_FILE" "$GENVM_WEB_FILE.bak.$ts"
}

patch_env_file() {
  ROOT_DIR="$GENLAYER_WORKSPACE" \
  HOST_WEBDRIVER_PORT="$HOST_WEBDRIVER_PORT" \
  DEFAULT_NODE_VERSION="$DEFAULT_NODE_VERSION" \
  HOST_RPC_PORT="$HOST_RPC_PORT" \
  HOST_OPS_PORT="$HOST_OPS_PORT" \
  NODE_PASSWORD="$NODE_PASSWORD" \
  DEFAULT_LOGGING_LEVEL="$DEFAULT_LOGGING_LEVEL" \
  LLM_VAR_NAME="$LLM_VAR_NAME" \
  LLM_VAR_VALUE="$LLM_VAR_VALUE" \
  python3 - <<'PY'
from pathlib import Path
import os, re

p = Path(os.environ["ROOT_DIR"]) / ".env"
text = p.read_text()

updates = {
    "WEBDRIVER_PORT": os.environ["HOST_WEBDRIVER_PORT"],
    "NODE_VERSION": os.environ["DEFAULT_NODE_VERSION"],
    "NODE_CONFIG_PATH": "./configs/node/config.yaml",
    "NODE_DATA_PATH": "./data",
    "NODE_RPC_PORT": os.environ["HOST_RPC_PORT"],
    "NODE_OPS_PORT": os.environ["HOST_OPS_PORT"],
    "NODE_PASSWORD": os.environ["NODE_PASSWORD"],
    "GENLAYERNODE_LOGGING_LEVEL": os.environ["DEFAULT_LOGGING_LEVEL"],
    "LLM_PROVIDER_VAR": os.environ["LLM_VAR_NAME"],
    os.environ["LLM_VAR_NAME"]: os.environ["LLM_VAR_VALUE"],
}

for key, value in updates.items():
    line = f"{key}={value}"
    pattern = re.compile(rf"^{re.escape(key)}=.*$", re.M)
    if pattern.search(text):
        text = pattern.sub(line, text, count=1)
    else:
        if text and not text.endswith("\n"):
            text += "\n"
        text += line + "\n"

p.write_text(text)
PY
}

patch_node_config_file() {
  CONFIG_FILE="$NODE_CONFIG_FILE" \
  RPC_URL="$RPC_URL" \
  WS_URL="$WS_URL" \
  CONSENSUS_ADDRESS="$CONSENSUS_ADDRESS" \
  GENESIS="$GENESIS" \
  DEFAULT_LOGGING_LEVEL="$DEFAULT_LOGGING_LEVEL" \
  NODE_MODE="$NODE_MODE" \
  VALIDATOR_WALLET_ADDRESS="$VALIDATOR_WALLET_ADDRESS" \
  OPERATOR_ADDRESS="$OPERATOR_ADDRESS" \
  INTERNAL_ADMIN_PORT="$INTERNAL_ADMIN_PORT" \
  INTERNAL_RPC_PORT="$INTERNAL_RPC_PORT" \
  INTERNAL_OPS_PORT="$INTERNAL_OPS_PORT" \
  BALANCE_ENDPOINT="$BALANCE_ENDPOINT" \
  python3 - <<'PY'
from pathlib import Path
import os
import re
import sys

p = Path(os.environ["CONFIG_FILE"])
lines = p.read_text().splitlines(True)

def q(s: str) -> str:
    s = s.replace("\\", "\\\\").replace('"', '\\"')
    return f'"{s}"'

wanted = {
    ("rollup", "genlayerchainrpcurl"): q(os.environ["RPC_URL"]),
    ("rollup", "genlayerchainwebsocketurl"): q(os.environ["WS_URL"]),
    ("consensus", "consensusaddress"): q(os.environ["CONSENSUS_ADDRESS"]),
    ("consensus", "genesis"): os.environ["GENESIS"],
    ("logging", "level"): q(os.environ["DEFAULT_LOGGING_LEVEL"]),
    ("node", "mode"): q(os.environ["NODE_MODE"]),
    ("node", "validatorWalletAddress"): q(os.environ["VALIDATOR_WALLET_ADDRESS"]),
    ("node", "operatorAddress"): q(os.environ["OPERATOR_ADDRESS"]),
    ("node", "admin", "port"): os.environ["INTERNAL_ADMIN_PORT"],
    ("node", "rpc", "port"): os.environ["INTERNAL_RPC_PORT"],
    ("node", "ops", "port"): os.environ["INTERNAL_OPS_PORT"],
    ("node", "ops", "endpoints", "balance"): os.environ["BALANCE_ENDPOINT"],
}

seen = set()
stack = []
line_re = re.compile(r'^(\s*)([A-Za-z0-9_]+):(.*?)(\r?\n?)$')

for i, line in enumerate(lines):
    m = line_re.match(line)
    if not m:
        continue

    indent, key, rest, nl = m.groups()
    indent_len = len(indent)

    while stack and indent_len <= stack[-1][0]:
        stack.pop()

    current_path = tuple(k for _, k in stack) + (key,)

    comment = ""
    value_part = rest
    if "#" in rest:
        hash_pos = rest.index("#")
        value_part = rest[:hash_pos]
        comment = rest[hash_pos:].rstrip("\r\n")

    if current_path in wanted:
        new_line = f"{indent}{key}: {wanted[current_path]}"
        if comment:
            new_line += f" {comment.lstrip()}"
        new_line += nl or "\n"
        lines[i] = new_line
        seen.add(current_path)

    stripped = value_part.strip()
    if stripped == "":
        stack.append((indent_len, key))

missing = [path for path in wanted if path not in seen]
if missing:
    sys.stderr.write(
        "Не удалось найти ключи в configs/node/config.yaml:\n- " +
        "\n- ".join(".".join(x) for x in missing) + "\n"
    )
    sys.exit(1)

p.write_text("".join(lines))
PY
}

patch_genvm_web_config() {
  GENVM_WEB_FILE="$GENVM_WEB_FILE" \
  DEFAULT_WEBDRIVER_HOST="$DEFAULT_WEBDRIVER_HOST" \
  python3 - <<'PY'
from pathlib import Path
import os, re

p = Path(os.environ["GENVM_WEB_FILE"])
text = p.read_text()
value = "webdriver_host: " + os.environ["DEFAULT_WEBDRIVER_HOST"]

pattern = re.compile(r'(?m)^([ \t]*webdriver_host:[ \t]*).*$')
if pattern.search(text):
    text = pattern.sub(value, text, count=1)
else:
    if text and not text.endswith("\n"):
        text += "\n"
    text += value + "\n"

p.write_text(text)
PY
}

show_done() {
  gum style \
    --border rounded \
    --padding "1 2" \
    --margin "1 0" \
    --foreground 42 \
    --border-foreground 42 \
    "Готово" \
    "Изменены .env, configs/node/config.yaml, genvm-module-web-docker.yaml"
}

main() {
  need_cmd gum
  need_cmd python3
  ensure_repo_layout

  ui_header
  choose_network
  ask_rpc_screen
  choose_mode
  choose_llm_provider
  ask_api_key_screen
  ask_password_screen
  show_summary_and_confirm

  backup_existing
  patch_env_file
  patch_node_config_file
  patch_genvm_web_config

  show_done
}

main "$@"
EOF

FILE="install/install_fullnode.sh"
cat > "$DIR/$FILE" <<'EOF'
#!/usr/bin/env bash
set -Eeuo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
GENLAYER_WORKSPACE="${GENLAYER_WORKSPACE:-$HOME/genlayer}"

GENLAYER_WORKSPACE="$GENLAYER_WORKSPACE" "$ROOT_DIR/install/bootstrap_workspace.sh"
DEFAULT_NODE_MODE=full GENLAYER_WORKSPACE="$GENLAYER_WORKSPACE" "$ROOT_DIR/install/configure_existing_node.sh"
GENLAYER_WORKSPACE="$GENLAYER_WORKSPACE" "$ROOT_DIR/checks/check_config.py" "$GENLAYER_WORKSPACE" || true
EOF

FILE="install/install_validator.sh"
cat > "$DIR/$FILE" <<'EOF'
#!/usr/bin/env bash
set -Eeuo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
GENLAYER_WORKSPACE="${GENLAYER_WORKSPACE:-$HOME/genlayer}"

GENLAYER_WORKSPACE="$GENLAYER_WORKSPACE" "$ROOT_DIR/install/bootstrap_workspace.sh"
DEFAULT_NODE_MODE=validator GENLAYER_WORKSPACE="$GENLAYER_WORKSPACE" "$ROOT_DIR/install/configure_existing_node.sh"
GENLAYER_WORKSPACE="$GENLAYER_WORKSPACE" "$ROOT_DIR/checks/check_config.py" "$GENLAYER_WORKSPACE" || true
EOF

FILE="checks/check_config.py"
cat > "$DIR/$FILE" <<'EOF'
#!/usr/bin/env python3
from pathlib import Path
import os
import re
import sys

workspace = Path(sys.argv[1] if len(sys.argv) > 1 else os.environ.get("GENLAYER_WORKSPACE", str(Path.home() / "genlayer")))
cfg_path = workspace / "configs/node/config.yaml"
env_path = workspace / ".env"

if not cfg_path.exists():
    print(f"ERROR: missing {cfg_path}", file=sys.stderr)
    sys.exit(2)
if not env_path.exists():
    print(f"ERROR: missing {env_path}", file=sys.stderr)
    sys.exit(2)

cfg_text = cfg_path.read_text()
cfg_lines = cfg_text.splitlines(True)
env_lines = env_path.read_text().splitlines()

def yaml_get(lines, target):
    stack = []
    line_re = re.compile(r'^(\s*)([A-Za-z0-9_]+):(.*)$')
    for line in lines:
        m = line_re.match(line.rstrip("\n"))
        if not m:
            continue
        indent, key, rest = m.groups()
        indent_len = len(indent)
        while stack and indent_len <= stack[-1][0]:
            stack.pop()
        path = tuple(k for _, k in stack) + (key,)
        if path == target:
            value = rest.strip()
            if "#" in value:
                value = value.split("#", 1)[0].rstrip()
            value = value.strip()
            if len(value) >= 2 and value[0] == '"' and value[-1] == '"':
                value = value[1:-1]
            return value
        if rest.strip() == "":
            stack.append((indent_len, key))
    return None

env = {}
for raw in env_lines:
    line = raw.strip()
    if not line or line.startswith("#") or "=" not in line:
        continue
    k, v = line.split("=", 1)
    env[k.strip()] = v.strip()

errors = []
warns = []

rpc = yaml_get(cfg_lines, ("rollup", "genlayerchainrpcurl"))
wss = yaml_get(cfg_lines, ("rollup", "genlayerchainwebsocketurl"))
consensus = yaml_get(cfg_lines, ("consensus", "consensusaddress"))
genesis = yaml_get(cfg_lines, ("consensus", "genesis"))
mode = yaml_get(cfg_lines, ("node", "mode"))
validator = yaml_get(cfg_lines, ("node", "validatorWalletAddress"))
operator = yaml_get(cfg_lines, ("node", "operatorAddress"))

def is_eth(v):
    return bool(v) and re.fullmatch(r'0x[0-9a-fA-F]{40}', v) is not None

if not rpc or rpc == "FILLME":
    errors.append("rollup.genlayerchainrpcurl пустой или FILLME")
elif not re.match(r'^https?://', rpc):
    errors.append("rollup.genlayerchainrpcurl должен начинаться с http:// или https://")

if not wss or wss == "FILLME":
    errors.append("rollup.genlayerchainwebsocketurl пустой или FILLME")
elif re.match(r'^https?://', wss):
    errors.append("rollup.genlayerchainwebsocketurl ошибочно указан как http(s), нужен ws:// или wss://")
elif not re.match(r'^wss?://', wss):
    errors.append("rollup.genlayerchainwebsocketurl должен начинаться с ws:// или wss://")

if not is_eth(consensus):
    errors.append("consensus.consensusaddress невалидный")

if not genesis or not genesis.isdigit():
    errors.append("consensus.genesis должен быть целым числом")

if mode not in {"full", "validator"}:
    errors.append("node.mode должен быть full или validator")

if mode == "validator":
    if not is_eth(validator):
        errors.append("node.validatorWalletAddress обязателен и должен быть валидным для validator mode")
    if not is_eth(operator):
        errors.append("node.operatorAddress обязателен и должен быть валидным для validator mode")

provider_var = env.get("LLM_PROVIDER_VAR", "").strip()
if not provider_var:
    warns.append("В .env не найден LLM_PROVIDER_VAR")
else:
    if provider_var not in env:
        errors.append(f"В .env нет переменной {provider_var}, указанной в LLM_PROVIDER_VAR")
    elif not env.get(provider_var, "").strip():
        errors.append(f"LLM provider variable {provider_var} пустая")

legacy_patterns = {
    "genlayerchainrpcurl_http": r'(?m)^\s*genlayerchainrpcurl_http\s*:',
    "websocketurl": r'(?m)^\s*websocketurl\s*:',
    "consensus_address": r'(?m)^\s*consensus_address\s*:',
}
for key, pattern in legacy_patterns.items():
    if re.search(pattern, cfg_text):
        warns.append(f"Обнаружено возможное старое поле после breaking upgrade: {key}")

if errors:
    print("PRECHECK: FAIL")
    for e in errors:
        print(f"- ERROR: {e}")
else:
    print("PRECHECK: OK")

for w in warns:
    print(f"- WARN: {w}")

sys.exit(1 if errors else 0)
EOF

FILE="checks/check_rpc.sh"
cat > "$DIR/$FILE" <<'EOF'
#!/usr/bin/env bash
set -Eeuo pipefail

GENLAYER_WORKSPACE="${GENLAYER_WORKSPACE:-$HOME/genlayer}"
CONFIG_FILE="$GENLAYER_WORKSPACE/configs/node/config.yaml"

read_cfg_value() {
  local path="$1"
  CONFIG_FILE="$CONFIG_FILE" CFG_PATH="$path" python3 - <<'PY'
from pathlib import Path
import os
import re

cfg = Path(os.environ["CONFIG_FILE"]).read_text().splitlines(True)
target = tuple(os.environ["CFG_PATH"].split("."))

stack = []
line_re = re.compile(r'^(\s*)([A-Za-z0-9_]+):(.*)$')

for line in cfg:
    m = line_re.match(line.rstrip("\n"))
    if not m:
        continue
    indent, key, rest = m.groups()
    indent_len = len(indent)
    while stack and indent_len <= stack[-1][0]:
        stack.pop()
    path = tuple(k for _, k in stack) + (key,)
    if path == target:
        value = rest.strip()
        if "#" in value:
            value = value.split("#", 1)[0].rstrip()
        value = value.strip()
        if len(value) >= 2 and value[0] == '"' and value[-1] == '"':
            value = value[1:-1]
        print(value)
        break
    if rest.strip() == "":
        stack.append((indent_len, key))
PY
}

jsonrpc_call() {
  local url="$1"
  local method="$2"
  local params="$3"

  curl -fsS "$url" \
    -H 'content-type: application/json' \
    --data "{\"jsonrpc\":\"2.0\",\"method\":\"$method\",\"params\":$params,\"id\":1}"
}

RPC_URL="${1:-$(read_cfg_value "rollup.genlayerchainrpcurl")}"
CONSENSUS_ADDRESS="${2:-$(read_cfg_value "consensus.consensusaddress")}"

echo "RPC URL: $RPC_URL"
echo "eth_chainId:"
jsonrpc_call "$RPC_URL" "eth_chainId" '[]' | jq .

if [[ -n "$CONSENSUS_ADDRESS" ]]; then
  echo
  echo "eth_getCode($CONSENSUS_ADDRESS):"
  jsonrpc_call "$RPC_URL" "eth_getCode" "[\"$CONSENSUS_ADDRESS\",\"latest\"]" | jq .
fi
EOF

FILE="checks/check_sync_health.sh"
cat > "$DIR/$FILE" <<'EOF'
#!/usr/bin/env bash
set -Eeuo pipefail

GENLAYER_WORKSPACE="${GENLAYER_WORKSPACE:-$HOME/genlayer}"
CONFIG_FILE="$GENLAYER_WORKSPACE/configs/node/config.yaml"
ENV_FILE="$GENLAYER_WORKSPACE/.env"

read_cfg_value() {
  local path="$1"
  CONFIG_FILE="$CONFIG_FILE" CFG_PATH="$path" python3 - <<'PY'
from pathlib import Path
import os
import re

cfg = Path(os.environ["CONFIG_FILE"]).read_text().splitlines(True)
target = tuple(os.environ["CFG_PATH"].split("."))

stack = []
line_re = re.compile(r'^(\s*)([A-Za-z0-9_]+):(.*)$')

for line in cfg:
    m = line_re.match(line.rstrip("\n"))
    if not m:
        continue
    indent, key, rest = m.groups()
    indent_len = len(indent)
    while stack and indent_len <= stack[-1][0]:
        stack.pop()
    path = tuple(k for _, k in stack) + (key,)
    if path == target:
        value = rest.strip()
        if "#" in value:
            value = value.split("#", 1)[0].rstrip()
        value = value.strip()
        if len(value) >= 2 and value[0] == '"' and value[-1] == '"':
            value = value[1:-1]
        print(value)
        break
    if rest.strip() == "":
        stack.append((indent_len, key))
PY
}

read_env_value() {
  local key="$1"
  [[ -f "$ENV_FILE" ]] || return 0
  grep -E "^${key}=" "$ENV_FILE" | tail -n1 | cut -d= -f2- || true
}

jsonrpc_call() {
  local url="$1"
  local method="$2"
  curl -fsS "$url" \
    -H 'content-type: application/json' \
    --data "{\"jsonrpc\":\"2.0\",\"method\":\"$method\",\"params\":[],\"id\":1}"
}

REMOTE_RPC="$(read_cfg_value "rollup.genlayerchainrpcurl")"
LOCAL_RPC_PORT="${NODE_RPC_PORT:-$(read_env_value NODE_RPC_PORT)}"
LOCAL_OPS_PORT="${NODE_OPS_PORT:-$(read_env_value NODE_OPS_PORT)}"

LOCAL_RPC_PORT="${LOCAL_RPC_PORT:-9151}"
LOCAL_OPS_PORT="${LOCAL_OPS_PORT:-9153}"

LOCAL_RPC="http://127.0.0.1:${LOCAL_RPC_PORT}"
LOCAL_OPS="http://127.0.0.1:${LOCAL_OPS_PORT}"

echo "Remote RPC: $REMOTE_RPC"
echo "Local RPC:  $LOCAL_RPC"
echo "Local OPS:  $LOCAL_OPS"

echo
echo "Health endpoint:"
if curl -fsS "$LOCAL_OPS/health" 2>/dev/null; then
  echo
  echo "health: OK"
else
  echo "health: FAIL"
fi

echo
REMOTE_HEX="$(jsonrpc_call "$REMOTE_RPC" "eth_blockNumber" 2>/dev/null | jq -r '.result // empty' || true)"
LOCAL_HEX="$(jsonrpc_call "$LOCAL_RPC" "eth_blockNumber" 2>/dev/null | jq -r '.result // empty' || true)"

echo "remote block: ${REMOTE_HEX:-<n/a>}"
echo "local block:  ${LOCAL_HEX:-<n/a>}"

if [[ -n "$REMOTE_HEX" && -n "$LOCAL_HEX" ]]; then
  REMOTE_DEC=$((REMOTE_HEX))
  LOCAL_DEC=$((LOCAL_HEX))
  LAG=$((REMOTE_DEC - LOCAL_DEC))
  echo "lag blocks: $LAG"
fi
EOF

FILE="checks/check_wss.sh"
cat > "$DIR/$FILE" <<'EOF'
#!/usr/bin/env bash
set -Eeuo pipefail

GENLAYER_WORKSPACE="${GENLAYER_WORKSPACE:-$HOME/genlayer}"
CONFIG_FILE="$GENLAYER_WORKSPACE/configs/node/config.yaml"

read_cfg_value() {
  local path="$1"
  CONFIG_FILE="$CONFIG_FILE" CFG_PATH="$path" python3 - <<'PY'
from pathlib import Path
import os
import re

cfg = Path(os.environ["CONFIG_FILE"]).read_text().splitlines(True)
target = tuple(os.environ["CFG_PATH"].split("."))

stack = []
line_re = re.compile(r'^(\s*)([A-Za-z0-9_]+):(.*)$')

for line in cfg:
    m = line_re.match(line.rstrip("\n"))
    if not m:
        continue
    indent, key, rest = m.groups()
    indent_len = len(indent)
    while stack and indent_len <= stack[-1][0]:
        stack.pop()
    path = tuple(k for _, k in stack) + (key,)
    if path == target:
        value = rest.strip()
        if "#" in value:
            value = value.split("#", 1)[0].rstrip()
        value = value.strip()
        if len(value) >= 2 and value[0] == '"' and value[-1] == '"':
            value = value[1:-1]
        print(value)
        break
    if rest.strip() == "":
        stack.append((indent_len, key))
PY
}

WSS_URL="${1:-$(read_cfg_value "rollup.genlayerchainwebsocketurl")}"

echo "WSS URL: $WSS_URL"

python3 - "$WSS_URL" <<'PY'
from urllib.parse import urlparse
import socket
import sys

url = sys.argv[1]
u = urlparse(url)

if u.scheme not in ("ws", "wss"):
    print("FAIL: URL must start with ws:// or wss://")
    sys.exit(1)

host = u.hostname
port = u.port or (443 if u.scheme == "wss" else 80)
print(f"host={host}")
print(f"port={port}")

try:
    with socket.create_connection((host, port), timeout=5):
        print("TCP connect: OK")
except Exception as e:
    print(f"TCP connect: FAIL ({e})")
    sys.exit(1)
PY
EOF

FILE="checks/doctor_wrapper.sh"
cat > "$DIR/$FILE" <<'EOF'
#!/usr/bin/env bash
set -Eeuo pipefail

GENLAYER_WORKSPACE="${GENLAYER_WORKSPACE:-$HOME/genlayer}"
BIN="$GENLAYER_WORKSPACE/bin/genlayernode"

[[ -x "$BIN" ]] || { echo "ERROR: missing $BIN" >&2; exit 1; }

cd "$GENLAYER_WORKSPACE"
"$BIN" doctor
EOF

FILE="monitor/genlayer_health_monitor.sh"
cat > "$DIR/$FILE" <<'EOF'
#!/usr/bin/env bash
set -Eeuo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
GENLAYER_WORKSPACE="${GENLAYER_WORKSPACE:-$HOME/genlayer}"
WATCH="${WATCH:-0}"
INTERVAL="${INTERVAL:-30}"
STATE_FILE="${STATE_FILE:-/tmp/genlayer_health_monitor.state}"

one_check() {
  local output rc
  set +e
  output="$(GENLAYER_WORKSPACE="$GENLAYER_WORKSPACE" "$ROOT_DIR/checks/check_sync_health.sh" 2>&1)"
  rc=$?
  set -e

  printf '%s
' "$output"

  local state="OK"
  if [[ $rc -ne 0 ]]; then
    state="FAIL"
  elif printf '%s
' "$output" | grep -q "health: FAIL"; then
    state="FAIL"
  fi

  local prev=""
  [[ -f "$STATE_FILE" ]] && prev="$(cat "$STATE_FILE")"
  printf '%s' "$state" > "$STATE_FILE"

  if [[ "$state" != "$prev" ]]; then
    local msg="GenLayer health state changed: ${prev:-unknown} -> $state on $(hostname)"
    TELEGRAM_BOT_TOKEN="${TELEGRAM_BOT_TOKEN:-}" TELEGRAM_CHAT_ID="${TELEGRAM_CHAT_ID:-}"       "$ROOT_DIR/monitor/telegram_alerts.sh" "$msg" || true
  fi
}

if [[ "$WATCH" == "1" ]]; then
  while true; do
    date -Is
    one_check
    echo
    sleep "$INTERVAL"
  done
else
  one_check
fi
EOF

FILE="monitor/telegram_alerts.sh"
cat > "$DIR/$FILE" <<'EOF'
#!/usr/bin/env bash
set -Eeuo pipefail

TEST_MESSAGE="${TEST_MESSAGE:-}"
MESSAGE="${1:-${TEST_MESSAGE:-}}"

: "${TELEGRAM_BOT_TOKEN:=}"
: "${TELEGRAM_CHAT_ID:=}"

if [[ -z "$MESSAGE" ]]; then
  echo "usage: TELEGRAM_BOT_TOKEN=... TELEGRAM_CHAT_ID=... $0 "message"" >&2
  exit 1
fi

if [[ -z "$TELEGRAM_BOT_TOKEN" || -z "$TELEGRAM_CHAT_ID" ]]; then
  echo "WARN: TELEGRAM_BOT_TOKEN or TELEGRAM_CHAT_ID is empty" >&2
  exit 0
fi

curl -fsS "https://api.telegram.org/bot${TELEGRAM_BOT_TOKEN}/sendMessage"   -d "chat_id=${TELEGRAM_CHAT_ID}"   --data-urlencode "text=${MESSAGE}" >/dev/null

echo "telegram alert sent"
EOF

FILE="monitor/prometheus_README.md"
cat > "$DIR/$FILE" <<'EOF'
# Prometheus / Grafana notes

This toolkit does not generate a full Prometheus stack automatically.

Recommended sources:
- node ops endpoint: `http://127.0.0.1:9153/metrics`
- node health endpoint: `http://127.0.0.1:9153/health`

Suggested alerts:
- node is not synced
- restart loop
- health endpoint unavailable
- large remote/local block lag
- dropped events / subscriber backlog
EOF

FILE="recovery/safe_restart.sh"
cat > "$DIR/$FILE" <<'EOF'
#!/usr/bin/env bash
set -Eeuo pipefail

GENLAYER_WORKSPACE="${GENLAYER_WORKSPACE:-$HOME/genlayer}"

compose_cmd() {
  if docker compose version >/dev/null 2>&1; then
    docker compose "$@"
    return
  fi
  if command -v docker-compose >/dev/null 2>&1; then
    docker-compose "$@"
    return
  fi
  echo "ERROR: docker compose not found" >&2
  exit 1
}

cd "$GENLAYER_WORKSPACE"
compose_cmd restart genlayer-node
EOF

FILE="recovery/resync_node.sh"
cat > "$DIR/$FILE" <<'EOF'
#!/usr/bin/env bash
set -Eeuo pipefail

GENLAYER_WORKSPACE="${GENLAYER_WORKSPACE:-$HOME/genlayer}"
DATADIR="$GENLAYER_WORKSPACE/data/node"

compose_cmd() {
  if docker compose version >/dev/null 2>&1; then
    docker compose "$@"
    return
  fi
  if command -v docker-compose >/dev/null 2>&1; then
    docker-compose "$@"
    return
  fi
  echo "ERROR: docker compose not found" >&2
  exit 1
}

[[ -d "$DATADIR" ]] || { echo "ERROR: missing $DATADIR" >&2; exit 1; }

cd "$GENLAYER_WORKSPACE"
compose_cmd stop genlayer-node || true

BACKUP="${DATADIR}.backup.$(date +%Y%m%d%H%M%S)"
mv "$DATADIR" "$BACKUP"
mkdir -p "$DATADIR"

echo "Old data moved to: $BACKUP"
echo "Now start the node again and monitor sync lag."
EOF

FILE="recovery/diagnose_and_fix.sh"
cat > "$DIR/$FILE" <<'EOF'
#!/usr/bin/env bash
set -Eeuo pipefail

GENLAYER_WORKSPACE="${GENLAYER_WORKSPACE:-$HOME/genlayer}"

collect_logs() {
  if docker compose version >/dev/null 2>&1; then
    (cd "$GENLAYER_WORKSPACE" && docker compose logs --tail 300 genlayer-node 2>/dev/null) || true
    return
  fi
  if command -v docker-compose >/dev/null 2>&1; then
    (cd "$GENLAYER_WORKSPACE" && docker-compose logs --tail 300 genlayer-node 2>/dev/null) || true
    return
  fi
  return 0
}

logs="$(collect_logs)"

printf '%s
' "$logs" | grep -E   'password is required|no contract code at given address|get chain ID: Internal error|No LLM provider is configured|Subscriber channel full|node is not synced' || true

echo
echo "Runbook hints:"
cat <<'EOF2'
password is required
- verify NODE_PASSWORD in .env
- verify compose entrypoint / command

no contract code at given address
- verify consensusaddress
- verify remote RPC network

get chain ID: Internal error
- verify remote RPC health
- try another RPC / WSS

No LLM provider is configured
- verify LLM_PROVIDER_VAR in .env
- verify actual provider variable exists and is not empty

Subscriber channel full
- investigate lag / CPU / dropped events
- safe restart
- inspect remote RPC / WSS quality

node is not synced
- compare local vs remote eth_blockNumber
- check ops health endpoint
- safe restart or resync
EOF2
EOF

FILE="docs/troubleshooting.md"
cat > "$DIR/$FILE" <<'EOF'
# Troubleshooting

## password is required
- Check `NODE_PASSWORD` in `.env`
- Check compose command / entrypoint
- Restart node

## no contract code at given address
- Check `consensus.consensusaddress`
- Check remote RPC network
- Run `checks/check_rpc.sh`

## get chain ID: Internal error
- Replace unstable RPC / WSS
- Verify remote `eth_chainId`
- Verify endpoint availability

## No LLM provider is configured
- Check `.env`
- Check `LLM_PROVIDER_VAR`
- Check actual provider variable value

## Subscriber channel full
- Check node lag
- Check host resources
- Check dropped events in logs
- Safe restart

## node is not synced
- Run `checks/check_sync_health.sh`
- Compare local and remote block number
- Restart or resync
EOF

FILE="docs/architecture.md"
cat > "$DIR/$FILE" <<'EOF'
# Architecture

The toolkit is split by operational concern:

- `install/` — bootstrap workspace and patch existing config files
- `checks/` — run validations and RPC / WSS / health probes
- `monitor/` — health and alert helpers
- `recovery/` — restart, resync, diagnose
- `docs/` — human runbooks
- `examples/` — sample files

The main launcher `toolkit.sh` is intentionally only a menu/router.
EOF

FILE="docs/runbook.md"
cat > "$DIR/$FILE" <<'EOF'
# Runbook

## Full node
1. Install -> Install full node
2. Checks -> Preflight config
3. Start stack manually from workspace
4. Checks -> Check sync / health

## Validator
1. Install -> Install validator
2. Checks -> Preflight config
3. Verify validator wallet and operator address
4. Start stack
5. Monitor sync and health

## Recovery
- Recovery -> Safe restart
- Recovery -> Resync node
- Recovery -> Diagnose and fix
EOF

FILE="examples/env.example"
cat > "$DIR/$FILE" <<'EOF'
WEBDRIVER_PORT=4444
NODE_VERSION=v0.5.7
NODE_CONFIG_PATH=./configs/node/config.yaml
NODE_DATA_PATH=./data
NODE_RPC_PORT=9151
NODE_OPS_PORT=9153
NODE_PASSWORD=change-me
GENLAYERNODE_LOGGING_LEVEL=INFO
LLM_PROVIDER_VAR=OPENROUTERKEY
OPENROUTERKEY=change-me
EOF

FILE="examples/config.yaml"
cat > "$DIR/$FILE" <<'EOF'
rollup:
  genlayerchainrpcurl: "https://zksync-os-testnet-genlayer.zksync.dev"
  genlayerchainwebsocketurl: "wss://zksync-os-testnet-genlayer.zksync.dev/ws"

consensus:
  consensusaddress: "0xe66B434bc83805f380509642429eC8e43AE9874a"
  genesis: 17326

datadir: "./data/node"

logging:
  level: "INFO"

node:
  mode: "full"
  validatorWalletAddress: ""
  operatorAddress: ""
  admin:
    port: 9155
  rpc:
    port: 9151
  ops:
    port: 9153
    endpoints:
      health: true
      metrics: true
      balance: false

genvm:
  root_dir: ./third_party/genvm
  start_manager: true
  manager_url: http://127.0.0.1:3999
  permits: 8
EOF

FILE="examples/docker-compose.override.yaml"
cat > "$DIR/$FILE" <<'EOF'
services:
  genlayer-node:
    restart: unless-stopped
    env_file:
      - .env
    volumes:
      - ./configs/node/config.yaml:/app/configs/node/config.yaml:ro
      - ./data:/app/data
EOF

chmod +x \
  $DIR/toolkit.sh \
  $DIR/install/bootstrap_workspace.sh \
  $DIR/install/configure_existing_node.sh \
  $DIR/install/install_fullnode.sh \
  $DIR/install/install_validator.sh \
  $DIR/checks/check_config.py \
  $DIR/checks/check_rpc.sh \
  $DIR/checks/check_sync_health.sh \
  $DIR/checks/check_wss.sh \
  $DIR/checks/doctor_wrapper.sh \
  $DIR/monitor/genlayer_health_monitor.sh \
  $DIR/monitor/telegram_alerts.sh \
  $DIR/recovery/safe_restart.sh \
  $DIR/recovery/resync_node.sh \
  $DIR/recovery/diagnose_and_fix.sh

echo "Installed to: $DIR"
echo
if command -v tree >/dev/null 2>&1; then
  tree "$DIR"
else
  find "$DIR" -maxdepth 3 -type f | sort
fi
