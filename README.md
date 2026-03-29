# GenLayer Validator Toolkit

A practical operator toolkit for deployment, validation, monitoring, and recovery of GenLayer full nodes and validators.

## Overview

This toolkit provides a structured shell-based workflow for:

- installing a GenLayer workspace
- configuring a full node or validator
- validating config before launch
- checking RPC, WSS, sync, and health
- running basic monitoring and Telegram alerts
- performing recovery actions like safe restart and resync
- keeping docs and examples close to the operational scripts

The toolkit is menu-driven through `toolkit.sh`, while the actual logic is split into dedicated directories.

## Project structure

```text
genlayer-validator-toolkit/
├── toolkit.sh
├── toolkit_install.sh
├── install/
│   ├── bootstrap_workspace.sh
│   ├── configure_existing_node.sh
│   ├── install_fullnode.sh
│   └── install_validator.sh
├── checks/
│   ├── check_config.py
│   ├── check_rpc.sh
│   ├── check_sync_health.sh
│   ├── check_wss.sh
│   └── doctor_wrapper.sh
├── monitor/
│   ├── genlayer_health_monitor.sh
│   ├── telegram_alerts.sh
│   └── prometheus_README.md
├── recovery/
│   ├── diagnose_and_fix.sh
│   ├── resync_node.sh
│   └── safe_restart.sh
├── docs/
│   ├── architecture.md
│   ├── runbook.md
│   └── troubleshooting.md
└── examples/
    ├── config.yaml
    ├── docker-compose.override.yaml
    └── env.example
