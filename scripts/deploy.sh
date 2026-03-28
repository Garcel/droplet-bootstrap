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

log()  { echo -e "${GREEN}[deploy]${NC} $*"; }
warn() { echo -e "${YELLOW}[warn]${NC}  $*"; }
die()  { echo -e "${RED}[error]${NC} $*" >&2; exit 1; }

# ── Pre-flight checks ────────────────────────────────────────────────────────
command -v terraform     >/dev/null 2>&1 || die "terraform not found"
command -v ansible-playbook >/dev/null 2>&1 || die "ansible-playbook not found"

[[ -z "${TF_VAR_do_token:-}" ]] && die "TF_VAR_do_token is not set. Export your DigitalOcean token."
[[ -f "$TF_DIR/terraform.tfvars" ]] || warn "terraform.tfvars not found, default values will be used."

# ── Terraform ─────────────────────────────────────────────────────────────────
log "Initializing Terraform..."
terraform -chdir="$TF_DIR" init -upgrade

log "Planning..."
terraform -chdir="$TF_DIR" plan -out=tfplan

log "Applying..."
terraform -chdir="$TF_DIR" apply tfplan

DROPLET_IP=$(terraform -chdir="$TF_DIR" output -raw droplet_ip)
SSH_KEY=$(terraform -chdir="$TF_DIR" output -raw ssh_private_key_path)
log "Droplet is up — IP: $DROPLET_IP"

# ── Wait for SSH ──────────────────────────────────────────────────────────────
log "Waiting for SSH to become available..."
for i in {1..30}; do
  ssh -o StrictHostKeyChecking=no -o ConnectTimeout=5 \
      -i "$SSH_KEY" \
      root@"$DROPLET_IP" "exit" 2>/dev/null && break
  warn "Attempt $i/30 — retrying in 5s..."
  sleep 5
done

# ── Ansible (initial run as root to create deploy user and harden SSH) ────────
INVENTORY="$ANSIBLE_DIR/inventory/hosts.ini"
[[ -f "$INVENTORY" ]] || die "Inventory not found at $INVENTORY"

log "Running Ansible (initial setup as root)..."
ANSIBLE_CONFIG="$ANSIBLE_DIR/ansible.cfg" ansible-playbook \
  -i "$INVENTORY" \
  "$ANSIBLE_DIR/playbooks/setup.yml" \
  -e "ansible_user=root" \
  --private-key "$SSH_KEY" \
  "${@}"

log "All done. Connect with:"
echo "  ssh -i $SSH_KEY deploy@$DROPLET_IP"
