# droplet-bootstrap

Infrastructure as code for DigitalOcean droplets: Terraform provisions, Ansible configures and hardens.

## Stack

- **Terraform** (>= 1.5.0) — provisions DigitalOcean Droplet (from image or snapshot) + Firewall + Project assignment, generates Ansible inventory
- **Ansible** (>= 2.14) — configures and hardens the droplet via playbooks/roles
- **DigitalOcean** — cloud provider
- **pre-commit** — linting and security checks (shellcheck, yamllint, ansible-lint, checkov, detect-secrets, terraform fmt/validate)

## Project structure

```
terraform/                # HCL configs (main, variables, outputs, provider)
terraform/templates/      # Ansible inventory template
ansible/playbooks/        # Ansible playbooks (setup.yml)
ansible/roles/base/       # Package management, auto security updates
ansible/roles/users/      # Deploy user creation, sudo, SSH key copy
ansible/roles/ssh/        # sshd hardening, banner, fail2ban
ansible/roles/firewall/   # UFW rules
ansible/roles/hardening/  # sysctl, core dumps, shared memory, history
ansible/requirements.yml  # Ansible Galaxy dependencies
scripts/deploy.sh         # Orchestration script (Terraform -> wait SSH -> Ansible)
scripts/destroy.sh        # Teardown script (Terraform destroy + cleanup)
.github/workflows/ci.yml  # CI pipeline running pre-commit checks
requirements.txt          # Python deps for CI
```

## Workflow

1. `export TF_VAR_do_token="..."`
2. `cp terraform/terraform.tfvars.example terraform/terraform.tfvars` and fill in values
3. `./scripts/deploy.sh` — runs terraform init/plan/apply as root, creates deploy user, hardens SSH, prints connection info for deploy@IP
4. `./scripts/destroy.sh` — destroys all resources and cleans up generated inventory

## Security model

- SSH-only access (password auth disabled, root login disabled)
- Non-root `deploy` user with sudo, SSH restricted to this user via `AllowUsers`
- fail2ban SSH jail (3 attempts, 1h ban)
- Kernel hardening via sysctl (SYN flood, IP spoofing, ICMP redirects)
- UFW firewall (deny incoming by default, allow 22/80/443)
- Automatic security updates via unattended-upgrades
- Shared memory hardened (noexec/nosuid/nodev), core dumps disabled
- Shell history ignores commands containing tokens/secrets/keys
- Terraform providers pinned to exact versions, .terraform.lock.hcl committed for SHA verification
- Optional `ssh_allowed_ips` to restrict SSH at the DO firewall level
- Optional `project_name` to assign the droplet to a DO project
- Optional `snapshot_id` to create the droplet from a snapshot instead of a base image
- detect-secrets pre-commit hook to prevent accidental secret commits

## Conventions

- Linting: yamllint (.yamllint), ansible-lint (.ansible-lint), markdownlint (.markdownlint.yaml), shellcheck, bashate
- Pre-commit hooks must pass before committing
- Terraform lock file (.terraform.lock.hcl) must be committed
