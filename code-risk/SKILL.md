---
name: code-risk
description: 'Conduct a read-only cybersecurity review of application code and configuration. Use when: performing a security audit, checking for OWASP Top 10 vulnerabilities, reviewing authentication or authorization logic, identifying injection risks, finding exposed secrets or misconfigured CSP headers, auditing third-party dependencies, or assessing input validation and output encoding. Produces a findings report.'
argument-hint: 'Optional: scope (e.g., "auth module", "API layer", "all files")'
---

# Cybersecurity Review


## Purpose

Audit code, configuration, and dependencies for security vulnerabilities and produce a structured findings report. Agents should treat this skill as **read-only**.

## When to Use

- Security audit before a release or deployment
- Reviewing authentication, session management, or authorization code
- Checking CSP headers, CORS policy, or other HTTP security controls
- Identifying injection risks (SQL, XSS, command injection, etc.)
- Auditing third-party dependencies for known CVEs
- Scanning for hardcoded secrets or credentials in source code
- Assessing input validation and output encoding

______________________________________________________________________

## Procedure

### 1. Determine Scope

If the user specified a scope (e.g., a module or file path), limit the review to that area. Otherwise, review the full workspace. Identify:

- Entry points (HTTP handlers, CLI args, form inputs, file uploads)
- Trust boundaries (client/server, user/admin, external APIs)
- Data flows involving sensitive information

### 2. Gather Context (Read-Only)

Use search and file-reading tools to collect:

- Source files
- Configuration files
- Dependency manifests
- Build/deploy scripts

You may run `npm audit --json` for informational output.

### 3. Evaluate Against Security Categories

Check each applicable category below and record any findings.

#### A01 — Broken Access Control

- Are authorization checks present on all protected routes/resources?
- Can users access resources belonging to other users (IDOR)?
- Is the principle of least privilege applied?

#### A02 — Cryptographic Failures

- Is sensitive data (PII, tokens, passwords) transmitted or stored in plaintext?
- Are weak or deprecated algorithms in use (MD5, SHA1, DES)?
- Are TLS/HTTPS enforced for all external connections?

#### A03 — Injection

- Are user inputs sanitized or parameterized before use in queries, shell commands, or template engines?
- Is `innerHTML`, `dangerouslySetInnerHTML`, `eval()`, or `document.write()` used with user-controlled data?
- Are SQL/NoSQL queries built with string concatenation?

#### A04 — Insecure Design

- Are there missing rate limits on authentication or sensitive endpoints?
- Is business logic enforced server-side, or only client-side?

#### A05 — Security Misconfiguration

- Are default credentials or example configs present?
- Are debug modes, verbose error messages, or stack traces exposed in production?
- Are unnecessary features, ports, or services enabled?
- Are HTTP security headers present and correctly configured (CSP, HSTS, X-Frame-Options, X-Content-Type-Options, Referrer-Policy)?

#### A06 — Vulnerable and Outdated Components

- Do dependency manifests include packages with known CVEs?
- Are dependencies pinned to specific versions?
- Are dev dependencies accidentally included in production builds?

#### A07 — Identification and Authentication Failures

- Are session tokens sufficiently random and rotated after login?
- Are there protections against brute force (lockouts, CAPTCHA, rate limiting)?
- Are passwords hashed with a modern algorithm (bcrypt, argon2, scrypt)?

#### A08 — Software and Data Integrity Failures

- Are third-party scripts loaded from CDNs with Subresource Integrity (SRI) hashes?
- Is CI/CD pipeline configuration reviewed for unauthorized modification risks?

#### A09 — Security Logging and Monitoring Failures

- Are security-relevant events (login failures, access denials) logged?
- Are logs free of sensitive data (passwords, tokens, PII)?

#### A10 — Server-Side Request Forgery (SSRF)

- Does the application make HTTP requests to URLs supplied by the user?
- Are allow-lists used to restrict permissible destinations?

#### Additional Checks

- **Secrets in source**: Look for hardcoded API keys, tokens, passwords, or private keys in source files and git history hints.
- **Cookie security**: Are `HttpOnly`, `Secure`, and `SameSite` attributes set on sensitive cookies?
- **Content Security Policy**: Is a CSP defined? Does it avoid `unsafe-inline` or `unsafe-eval`?
- **Dependency confusion**: Are internal package names squattable on public registries?
- **Supply chain**: Are `package-lock.json` or equivalent dependency files omitted from source control?

### 4. Compile the Findings Report

Structure the report as follows. Omit sections with no findings.

Use the report text below verbatim replacing placeholders with actual values. If a finding requires further investigation beyond available tools, note it as "Needs manual review".

## Findings Report

**Reviewed:** `<scope or "Full workspace">`
**Date:** `<today>`

The purpose of this document is to help DevOps staff associated with the University of Illinois fulfill their [responsibility](https://cam.illinois.edu/policies/fo-36) to comply with Illinois Cybersecurity standards, including[IT05](https://go.illinois.edu/secstd-IT05), [IT07](https://go.illinois.edu/secstd-IT07), [IT08](https://go.illinois.edu/secstd-IT08), and [IT13](https://go.illinois.edu/secstd-IT13).

This skill is a DRAFT. Rather than share this DRAFT, please encourage colleagues to contact securitysupport@illinois.edu for the latest version.

This document is [TLP:AMBER](https://www.cisa.gov/news-events/news/traffic-light-protocol-tlp-definitions-and-usage), as it may contain information about potential vulnerabilities in a live campus service. This document should be shared only within the impacted team and the Privacy and Cybersecurity teams, and with their leadership, as needed, but otherwise kept confidential.

Faculty and staff of the the University of Illinois may contact securitysupport@illinois.edu for assistance with understanding these results.

### Summary

| OWASP Category | Count |
|-----------------------------------------------------|-------|
| A01 — Broken Access Control | N |
| A02 — Cryptographic Failures | N |
| A03 — Injection | N |
| A04 — Insecure Design | N |
| A05 — Security Misconfiguration | N |
| A06 — Vulnerable and Outdated Components | N |
| A07 — Identification and Authentication Failures | N |
| A08 — Software and Data Integrity Failures | N |
| A09 — Security Logging and Monitoring Failures | N |
| A10 — Server-Side Request Forgery (SSRF) | N |
| Other Findings | N |

______________________________________________________________________

### Findings

For each finding, use this format:

#### Title — Category

**File/Location:** `path/to/file.ts:line`
**Description:** What the vulnerability is and why it matters.
**Evidence:** Relevant code snippet or configuration value (quote directly from source).
**Recommendation:** What should be done to remediate (description only).
**Reference:** OWASP link and CVE if applicable.

______________________________________________________________________

## Constraints

- This skill is meant to produce findings only.
- If a finding requires further investigation beyond available tools, note it as "Needs manual review" rather than speculating.
