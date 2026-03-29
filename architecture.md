##Main components
###Install

Scripts in install/ prepare the workspace and patch existing config files.

bootstrap_workspace.sh
Downloads the GenLayer node archive and GenVM executor, extracts them into the target workspace, and prepares .env.
configure_existing_node.sh
Interactive gum-based configuration wizard for RPC/WSS, mode, validator settings, and LLM provider variables.
install_fullnode.sh
Bootstrap + configure in full node mode.
install_validator.sh
Bootstrap + configure in validator mode.

###Checks

Scripts in checks/ validate configuration and runtime connectivity.

check_config.py
Preflight validator for required fields and common mistakes.
doctor_wrapper.sh
Wrapper around genlayernode doctor.
check_rpc.sh
Runs JSON-RPC checks like eth_chainId and eth_getCode.
check_wss.sh
Validates WSS/WS URL format and basic TCP connectivity.
check_sync_health.sh
Compares local and remote block numbers and checks local health endpoint.

###Monitor

Scripts in monitor/ provide lightweight monitoring helpers.

genlayer_health_monitor.sh
One-shot or watch-loop health checker.
telegram_alerts.sh
Sends Telegram messages if bot token and chat ID are configured.
Recovery

Scripts in recovery/ automate common recovery actions.

safe_restart.sh
resync_node.sh
diagnose_and_fix.sh
Docs

Human-readable runbooks and troubleshooting notes live in docs/.

Requirements
System packages

Recommended system packages:

bash
curl
jq
python3
rsync
tar
xz-utils
gum
docker / docker compose
Python

The current toolkit uses only Python standard library modules.
No third-party Python packages are required.

Environment

By default the toolkit uses:

GENLAYER_WORKSPACE="$HOME/genlayer"

You can override it:

GENLAYER_WORKSPACE=/path/to/genlayer ./toolkit.sh
