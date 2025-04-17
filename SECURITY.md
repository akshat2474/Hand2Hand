# Security Policy

##  Supported Versions

The Hand2Hand team actively maintains and monitors the following versions:

| Version | Supported          |
|---------|--------------------|
| `main`  | ✅ Always supported |
| Release branches (`v1.x`) | ✅ Supported until EOL notice |
| Legacy versions | ❌ Not supported |

---

##  Reporting a Vulnerability

We take the security of Hand2Hand and our users seriously. If you discover a security vulnerability, please follow the steps below **privately and responsibly**.

###  How to Report

Please **DO NOT** open a public GitHub issue for security vulnerabilities.

Instead, contact us directly:

- 📧 Email: **akshatsingh2474@gmail.com**

In your report, please include:

- A clear and concise description of the vulnerability
- Steps to reproduce (code snippets, payloads, screenshots if applicable)
- The impact of the vulnerability (e.g., user data access, denial of service)
- Any potential mitigations you suggest

We will acknowledge receipt of your report within **48 hours** and provide a response within **5 business days**.

---

## ⚙️ Security Process

Once we receive a valid report:

1. **Investigation**  
   We confirm the vulnerability and evaluate its severity.

2. **Mitigation & Fix**  
   We work on a fix and develop test coverage to ensure the issue is fully addressed.

3. **Verification**  
   We verify the fix does not introduce regressions or new vulnerabilities.

4. **Disclosure (if applicable)**  
   Once a patch is released, we may publish a summary of the vulnerability and credit you (if desired).

---

## Responsible Disclosure

We encourage responsible disclosure and do **not support or condone** the exploitation of security vulnerabilities for malicious purposes.

If you follow the above process in good faith, we will not take legal action against you.

---

## Security Best Practices

For contributors and integrators:

- Sanitize and validate all input (especially user data).
- Use secure authentication and encryption standards.
- Avoid hardcoding API keys or secrets—use `.env` files or secret managers.
- Follow the [OWASP Top 10](https://owasp.org/www-project-top-ten/) guidelines.

---

> Thank you for helping us make Hand2Hand a safer platform for everyone. 💙
