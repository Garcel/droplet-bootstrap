# 🛡️ Security Policy

## Supported Versions

Only the latest version of this repository is actively maintained and eligible for security fixes.

| Version | Supported          |
| ------- | ------------------ |
| latest  | ✅                 |
| older   | ❌                 |

---

## 🔐 Reporting a Vulnerability

**Please do not report security vulnerabilities through public GitHub Issues.**

If you discover a security vulnerability in this project, please report it responsibly by using one of the following methods:

- **GitHub Private Vulnerability Reporting** *(preferred)*:
  Use the [Security Advisories](../../security/advisories/new) feature in this repository.
- **Email**: If you prefer, reach out directly via email.
  You can find contact details in the repository owner's GitHub profile.

### What to include in your report

To help us triage and resolve the issue as quickly as possible, please include:

- A clear description of the vulnerability
- Steps to reproduce the issue
- Potential impact and affected components
- Any suggested miigation or fix (optional but appreciated)

---

## ⏱️ Response Timeline

| Stage                        | Target time     |
| ---------------------------- | --------------- |
| Acknowledgement of report    | Within 48 hours |
| Initial assessment           | Within 5 days   |
| Fix or mitigation published  | Within 30 days  |

We will keep you informed throughout the process. If we need more information,
we will reach out via the same channel you used to report.

---

## ⚠️ Scope

This repository manages **infrastructure and configuration code**. The following are considered in-scope for security reports:

- Hardcoded secrets, tokens, or credentials accidentally committed
- Insecure default configurations (firewall rules, open ports, weak permissions)
- Privilege escalation risks in Ansible playbooks or Terraform resources
- Supply chain issues with third-party providers or modules

The following are **out of scope**:

- Vulnerabilities in upstream tools (Terraform, Ansible, DigitalOcean) — please report those to their respective projects
- Issues in test or example files clearly marked as non-production

---

## 🔒 Security Best Practices for Contributors

When contributing to this repository, please follow these guidelines:

- **Never commit secrets**: API tokens, SSH private keys, and passwords must never be committed.
  Use environment variables or a secrets manager.
- **Use `.gitignore`**: Ensure sensitive files like `terraform.tfvars` and `*.pem` are listed in `.gitignore`.
- **Least privilege**: Firewall rules and IAM policies should follow the principle of least privilege.
- **Pin versions**: Always pin provider and module versions to avoid unexpected updates pulling in vulnerable code.
- **Rotate credentials**: If you suspect a secret has been exposed, rotate it immediately and report it.

---

## 🪪 License

This security policy is provided under the same [Apache License 2.0](LICENSE) as the rest of the repository.
