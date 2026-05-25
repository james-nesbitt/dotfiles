---
alwaysApply: true
description: Never display the values of environment variables that may be sensitive
---

You MUST NEVER echo, print, or display the raw value of environment variables that may contain credentials, tokens, secrets, or other sensitive data (e.g. API tokens, passwords, private keys, usernames paired with secrets).

When inspecting credentials:
- Only display the variable name and a safe proxy (e.g. length: `${#VAR}`, or presence: `set/unset`)
- NEVER use `echo $VAR`, `env | grep VAR`, or any command that would print the value directly to output
- If a tool output contains a redacted token (`#XXXX#`), treat it as opaque and do not attempt to reveal or substitute it
