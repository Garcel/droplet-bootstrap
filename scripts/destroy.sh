#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TF_DIR="$SCRIPT_DIR/../terraform"
ANSIBLE_DIR="$SCRIPT_DIR/../ansible"

# ── Colors ────────────────────────────────────────────────────────────────────
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

log()  { echo -e "${GREEN}[destroy]${NC} $*"; }
warn() { echo -e "${YELLOW}[warn]${NC}   $*"; }
die()  { echo -e "${RED}[error]${NC}  $*" >&2; exit 1; }

# ── Pre-flight checks ────────────────────────────────────────────────────────
command -v terraform >/dev/null 2>&1 || die "terraform not found"

[[ -z "${TF_VAR_do_token:-}" ]] && die "TF_VAR_do_token is not set. Export your DigitalOcean token."

# ── Confirmation ──────────────────────────────────────────────────────────────
warn "This will destroy ALL resources managed by Terraform (droplet, firewall, project assignment)."
read -rp "Are you sure? (yes/no): " confirm
[[ "$confirm" == "yes" ]] || { log "Aborted."; exit 0; }

# ── Terraform destroy ─────────────────────────────────────────────────────────
log "Initializing Terraform..."
terraform -chdir="$TF_DIR" init -upgrade

log "Destroying infrastructure..."
terraform -chdir="$TF_DIR" destroy -auto-approve

# ── Clean up generated files ──────────────────────────────────────────────────
INVENTORY="$ANSIBLE_DIR/inventory/hosts.ini"
if [[ -f "$INVENTORY" ]]; then
  rm "$INVENTORY"
  log "Removed generated inventory ($INVENTORY)"
fi

log "All resources destroyed."
