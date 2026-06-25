---
name: mirantis-services
description: Access Mirantis internal services — JIRA, Confluence, Jenkins, GitLab, Harbor, Okta, GitHub, Aikido. Use when interacting with any Mirantis service API or when the user asks to query, create, or update resources in those systems.
tags: [mirantis, jira, confluence, jenkins, gitlab, harbor, okta, github, aikido]
---

# Mirantis Services

All Mirantis service credentials are stored in an encrypted `pass` store at
`~/Documents/Mirantis/.password-store` (GPG key: `jnesbitt@mirantis.com`).
Wrapper scripts in `~/Documents/Mirantis/bin/` handle authentication
transparently — credentials never appear in command output or agent context.

Invoke wrappers by **full path**. No PATH setup or environment exports are needed;
`PASSWORD_STORE_DIR` is set inside the scripts automatically.

## Constraints

- **Never** construct raw `curl` calls with embedded credentials for Mirantis
  services. Always use the wrapper scripts below.
- **Never** read, echo, or inspect the contents of pass entries.
- If a wrapper exits with `pass entry "..." not found`, the credential has not
  been populated yet — tell the user which `pass insert` command to run
  (see [Managing Credentials](#managing-credentials)).

---

## Aikido

Multiple teams (one credential per GitHub org). Wrapper: `~/Documents/Mirantis/bin/mirantis-aikido`

Authentication is OAuth2 client credentials. The wrapper exchanges the stored
client_id + client_secret for a short-lived bearer token on every invocation.

Generate credentials at: https://app.aikido.dev/settings/integrations/api/aikido/rest
(requires workspace admin; select App Type = Private)

```bash
~/Documents/Mirantis/bin/mirantis-aikido <team> /api/PATH [curl-options...]
```

### List configured teams

```bash
PASSWORD_STORE_DIR=~/Documents/Mirantis/.password-store pass ls mirantis/aikido
```

### Common operations

```bash
# Export all issues
~/Documents/Mirantis/bin/mirantis-aikido <team> '/api/public/v1/issues/export'

# List open issue groups
~/Documents/Mirantis/bin/mirantis-aikido <team> '/api/public/v1/issues/groups'

# List code repositories
~/Documents/Mirantis/bin/mirantis-aikido <team> '/api/public/v1/repositories/code'

# Export SBOM for a code repository
~/Documents/Mirantis/bin/mirantis-aikido <team> '/api/public/v1/repositories/code/<repo_id>/sbom'

# List containers
~/Documents/Mirantis/bin/mirantis-aikido <team> '/api/public/v1/containers'

# Export SBOM for a container
~/Documents/Mirantis/bin/mirantis-aikido <team> '/api/public/v1/containers/<repo_id>/sbom'

# List cloud assets
~/Documents/Mirantis/bin/mirantis-aikido <team> '/api/public/v1/clouds/assets' \
  -X POST -d '{"filters":{}}'

# Export PDF report
~/Documents/Mirantis/bin/mirantis-aikido <team> '/api/public/v1/reports/export'

# List PR checks
~/Documents/Mirantis/bin/mirantis-aikido <team> '/api/public/v1/ci/scans'

# Get CVE details
~/Documents/Mirantis/bin/mirantis-aikido <team> '/api/public/v1/cves/<cve_id>'

# List users
~/Documents/Mirantis/bin/mirantis-aikido <team> '/api/public/v1/users'

# Get workspace info
~/Documents/Mirantis/bin/mirantis-aikido <team> '/api/public/v1/workspace'
```

---


## JIRA

Single instance. Wrapper: `~/Documents/Mirantis/bin/mirantis-jira`

```bash
~/Documents/Mirantis/bin/mirantis-jira /rest/api/3/PATH [curl-options...]
```

### Common operations

```bash
# Get an issue
~/Documents/Mirantis/bin/mirantis-jira /rest/api/3/issue/PROJ-123

# Search with JQL
~/Documents/Mirantis/bin/mirantis-jira /rest/api/3/search \
  -X POST \
  -d '{"jql":"project=FOO AND status=\"In Progress\"","maxResults":50}'

# Create an issue
~/Documents/Mirantis/bin/mirantis-jira /rest/api/3/issue \
  -X POST \
  -d '{"fields":{"project":{"key":"FOO"},"summary":"Title","issuetype":{"name":"Task"}}}'

# Update an issue field
~/Documents/Mirantis/bin/mirantis-jira /rest/api/3/issue/PROJ-123 \
  -X PUT \
  -d '{"fields":{"summary":"Updated title"}}'

# Add a comment
~/Documents/Mirantis/bin/mirantis-jira /rest/api/3/issue/PROJ-123/comment \
  -X POST \
  -d '{"body":{"type":"doc","version":1,"content":[{"type":"paragraph","content":[{"type":"text","text":"Comment text"}]}]}}'

# List projects
~/Documents/Mirantis/bin/mirantis-jira /rest/api/3/project

# Get issue transitions (for status changes)
~/Documents/Mirantis/bin/mirantis-jira /rest/api/3/issue/PROJ-123/transitions

# Transition an issue (e.g. close it)
~/Documents/Mirantis/bin/mirantis-jira /rest/api/3/issue/PROJ-123/transitions \
  -X POST \
  -d '{"transition":{"id":"31"}}'
```

---

## Confluence

Single instance. Wrapper: `~/Documents/Mirantis/bin/mirantis-confluence`

Credential: `mirantis/atlassian` (shared with JIRA).

```bash
~/Documents/Mirantis/bin/mirantis-confluence /wiki/rest/api/PATH [curl-options...]
```

### Default space

**Always use `PRODENG` as the default Confluence space** unless the user explicitly specifies otherwise.
- PRODENG space key: `PRODENG`
- PRODENG homepage ID: `1901003000`
- PRODENG space URL: `https://mirantis.jira.com/wiki/spaces/PRODENG`

When creating a page without an explicit parent, use the PRODENG homepage as the ancestor:
```json
{"ancestors": [{"id": "1901003000"}]}
```

### Known behaviours and constraints

- **The wrapper already sets `Content-Type: application/json`** — do NOT pass `-H 'Content-Type: ...'` as an extra argument; it conflicts and causes 400 errors.
- **For POST/PUT with a body**, always write the payload to a temp file and pass `--data-binary @/tmp/file.json`. Inline `-d '{...}'` with complex JSON is unreliable.
- **`text~` CQL search does not work** on this instance — use title-based or direct ID lookups instead.
- **Cannot move pages between spaces** without space admin rights — create in the correct space from the start.
- **Cannot delete pages** without space admin rights — if a page lands in the wrong place, update its title to `[DELETE] ...`, set the body to a redirect note pointing at the correct page, and ask the user to manually trash it.
- **Page creation response may return `space: null`** even on success — confirm by fetching the page by ID.
- **Version number for updates must be `current + 1`** — always fetch the current version before a PUT.
- **Special Unicode characters in titles** (em dashes, emoji) can cause 400 errors — use ASCII hyphens in page titles.

### Common operations

```bash
# Get a page by ID
~/Documents/Mirantis/bin/mirantis-confluence /wiki/rest/api/content/12345

# Get a page with body expanded
~/Documents/Mirantis/bin/mirantis-confluence '/wiki/rest/api/content/12345?expand=body.storage,version'

# List pages in a space
~/Documents/Mirantis/bin/mirantis-confluence '/wiki/rest/api/content?spaceKey=PRODENG&type=page&limit=25'

# Get space homepage ID
~/Documents/Mirantis/bin/mirantis-confluence '/wiki/rest/api/space/PRODENG?expand=homepage'

# Create a page (write payload to file — do NOT use inline -d for complex JSON)
cat > /tmp/page.json << 'EOF'
{
  "type": "page",
  "title": "New Page",
  "space": {"key": "PRODENG"},
  "ancestors": [{"id": "1901003000"}],
  "body": {"storage": {"value": "<p>Content here</p>", "representation": "storage"}}
}
EOF
~/Documents/Mirantis/bin/mirantis-confluence /wiki/rest/api/content -X POST --data-binary @/tmp/page.json

# Update a page (version number must be current+1)
cat > /tmp/update.json << 'EOF'
{
  "type": "page",
  "title": "Updated Title",
  "version": {"number": 3},
  "body": {"storage": {"value": "<p>Updated content</p>", "representation": "storage"}}
}
EOF
~/Documents/Mirantis/bin/mirantis-confluence /wiki/rest/api/content/12345 -X PUT --data-binary @/tmp/update.json
```
---

## Jenkins

Multiple masters. Wrapper: `~/Documents/Mirantis/bin/mirantis-jenkins <master>`

The `<master>` argument maps to a pass entry at `mirantis/jenkins/<master>`.
Jenkins CSRF crumbs are fetched and injected automatically for mutating requests.

```bash
~/Documents/Mirantis/bin/mirantis-jenkins <master> /API/PATH [curl-options...]
```

### List available masters

```bash
PASSWORD_STORE_DIR=~/Documents/Mirantis/.password-store pass ls mirantis/jenkins
```

### Common operations

```bash
# List all jobs on a master
~/Documents/Mirantis/bin/mirantis-jenkins tools /api/json?tree=jobs[name,url,color]

# Get job details
~/Documents/Mirantis/bin/mirantis-jenkins tools /job/my-pipeline/api/json

# Get last build info
~/Documents/Mirantis/bin/mirantis-jenkins tools /job/my-pipeline/lastBuild/api/json

# Trigger a build
~/Documents/Mirantis/bin/mirantis-jenkins tools /job/my-pipeline/build -X POST

# Trigger with parameters
~/Documents/Mirantis/bin/mirantis-jenkins tools /job/my-pipeline/buildWithParameters \
  -X POST \
  --data-urlencode 'BRANCH=main' \
  --data-urlencode 'ENV=staging'

# Get build log
~/Documents/Mirantis/bin/mirantis-jenkins tools /job/my-pipeline/42/consoleText

# Get queue status
~/Documents/Mirantis/bin/mirantis-jenkins tools /queue/api/json

# List nodes/agents
~/Documents/Mirantis/bin/mirantis-jenkins tools /computer/api/json
```

### Add a new Jenkins master

```bash
PASSWORD_STORE_DIR=~/Documents/Mirantis/.password-store pass insert --multiline mirantis/jenkins/<master-name>
```

Entry format (first line is the API token):
```
<api-token>
username: jnesbitt
url: https://jenkins-<master-name>.mirantis.com
```

---

## GitLab

Single instance. Wrapper: `~/Documents/Mirantis/bin/mirantis-gitlab`

```bash
~/Documents/Mirantis/bin/mirantis-gitlab /api/v4/PATH [curl-options...]
```

### Common operations

```bash
# List accessible projects
~/Documents/Mirantis/bin/mirantis-gitlab '/api/v4/projects?membership=true&per_page=50'

# Get a project
~/Documents/Mirantis/bin/mirantis-gitlab /api/v4/projects/123

# List merge requests
~/Documents/Mirantis/bin/mirantis-gitlab '/api/v4/projects/123/merge_requests?state=opened'

# Create a merge request
~/Documents/Mirantis/bin/mirantis-gitlab /api/v4/projects/123/merge_requests \
  -X POST \
  -d '{"source_branch":"feature/foo","target_branch":"main","title":"My MR"}'

# List issues
~/Documents/Mirantis/bin/mirantis-gitlab '/api/v4/projects/123/issues?state=opened'

# Get pipeline status
~/Documents/Mirantis/bin/mirantis-gitlab /api/v4/projects/123/pipelines/456

# List runners
~/Documents/Mirantis/bin/mirantis-gitlab /api/v4/runners
```

---

## Harbor

Multiple registries. Wrapper: `~/Documents/Mirantis/bin/mirantis-harbor <registry>`

The `<registry>` argument maps to a pass entry at `mirantis/harbor/<registry>`.
Authentication is HTTP Basic (username + CLI secret). The CLI secret is found in
Harbor UI → User Profile → CLI secret.

```bash
~/Documents/Mirantis/bin/mirantis-harbor <registry> /api/v2.0/PATH [curl-options...]
```

### List configured registries

```bash
PASSWORD_STORE_DIR=~/Documents/Mirantis/.password-store pass ls mirantis/harbor
```

### Common operations

```bash
# List all projects
~/Documents/Mirantis/bin/mirantis-harbor <registry> /api/v2.0/projects

# Get a project
~/Documents/Mirantis/bin/mirantis-harbor <registry> /api/v2.0/projects/myproject

# List repositories in a project
~/Documents/Mirantis/bin/mirantis-harbor <registry> '/api/v2.0/projects/myproject/repositories?page_size=50'

# List artifacts (tags) for a repository
~/Documents/Mirantis/bin/mirantis-harbor <registry> \
  '/api/v2.0/projects/myproject/repositories/myrepo/artifacts?with_tag=true&page_size=50'

# Get a specific artifact by digest or tag
~/Documents/Mirantis/bin/mirantis-harbor <registry> \
  '/api/v2.0/projects/myproject/repositories/myrepo/artifacts/sha256:abc123'

# Delete an artifact
~/Documents/Mirantis/bin/mirantis-harbor <registry> \
  '/api/v2.0/projects/myproject/repositories/myrepo/artifacts/sha256:abc123' -X DELETE

# List tags on an artifact
~/Documents/Mirantis/bin/mirantis-harbor <registry> \
  '/api/v2.0/projects/myproject/repositories/myrepo/artifacts/sha256:abc123/tags'

# Delete a tag
~/Documents/Mirantis/bin/mirantis-harbor <registry> \
  '/api/v2.0/projects/myproject/repositories/myrepo/artifacts/sha256:abc123/tags/v1.2.3' -X DELETE

# Search across all projects
~/Documents/Mirantis/bin/mirantis-harbor <registry> '/api/v2.0/search?q=myimage'

# Get system info
~/Documents/Mirantis/bin/mirantis-harbor <registry> /api/v2.0/systeminfo

# List replication rules
~/Documents/Mirantis/bin/mirantis-harbor <registry> /api/v2.0/replication/policies

# Trigger a replication execution
~/Documents/Mirantis/bin/mirantis-harbor <registry> /api/v2.0/replication/executions \
  -X POST -d '{"policy_id": 1}'
```

### Add a new registry

```bash
PASSWORD_STORE_DIR=~/Documents/Mirantis/.password-store pass insert --multiline mirantis/harbor/<registry-name>
```

Entry format (first line is the CLI secret):
```
<cli-secret>
username: jnesbitt
url: https://<registry-hostname>
```

---


## GitHub

Multiple organizations. Authentication is managed by the `gh` CLI, which
maintains its own credential store — no pass entry or wrapper needed.

```bash
# Always use gh CLI for GitHub operations
gh issue list --repo mirantis/<repo>
gh pr create --repo mirantis/<repo>
gh api /repos/mirantis/<repo>/releases
```

Use `gh auth status` to verify authentication state if a call fails.

---

## Okta / VPN

Wrapper: `~/Documents/Mirantis/bin/mirantis-okta`

```bash
# Connect to Mirantis VPN (interactive MFA prompt follows)
~/Documents/Mirantis/bin/mirantis-okta vpn
```

`openconnect` must be installed (`sudo dnf install -y openconnect`).
MFA push or TOTP is handled interactively by openconnect after the
password is injected from pass.

---

## Managing Credentials

Wrapper scripts set `PASSWORD_STORE_DIR` internally. For direct `pass` commands
(listing, editing, inserting), prefix with the store path:

```bash
PASSWORD_STORE_DIR=~/Documents/Mirantis/.password-store pass <subcommand>
```

### Populate a credential for the first time

```bash
PASSWORD_STORE_DIR=~/Documents/Mirantis/.password-store pass edit mirantis/jira
PASSWORD_STORE_DIR=~/Documents/Mirantis/.password-store pass edit mirantis/confluence
PASSWORD_STORE_DIR=~/Documents/Mirantis/.password-store pass edit mirantis/gitlab
PASSWORD_STORE_DIR=~/Documents/Mirantis/.password-store pass edit mirantis/okta
PASSWORD_STORE_DIR=~/Documents/Mirantis/.password-store pass edit mirantis/jenkins/tools
PASSWORD_STORE_DIR=~/Documents/Mirantis/.password-store pass edit mirantis/harbor/<registry-name>
PASSWORD_STORE_DIR=~/Documents/Mirantis/.password-store pass edit mirantis/aikido
```

### Add a new Jenkins master

```bash
PASSWORD_STORE_DIR=~/Documents/Mirantis/.password-store pass insert --multiline mirantis/jenkins/<master-name>
```

### Rotate a credential

```bash
PASSWORD_STORE_DIR=~/Documents/Mirantis/.password-store pass edit mirantis/<service>
```

### Standard entry format

All entries follow the same structure:
```
<api-token-or-password>
username: jnesbitt@mirantis.com
url: https://<service>.mirantis.com
```

Jenkins entries use `username: jnesbitt` (short form, no domain).
Okta entries use `vpn-host:` and optionally `vpn-authgroup:` instead of `url:`.

---

## Content Standards

These rules apply to **all content written on your behalf** to JIRA or GitHub — issue bodies, comments, PR titles, PR descriptions. Terse wins. Do not pad.

### General tone

- Engineering-internal audience. Skip pleasantries and motivation preamble.
- Factual, present or past tense for findings; imperative for required actions.
- Bullet lists over paragraphs whenever you have 3+ items.
- No filler: "As per the above", "Please note", "In order to", "It is worth mentioning".

---

### JIRA issue descriptions

Use Atlassian Document Format (ADF) for `/rest/api/3/` calls. Pick sections by issue type — do not include sections that don't apply.

| Issue type | Required sections | Per-section guidance |
|---|---|---|
| Bug | **Symptom**, **Repro Steps**, **Expected**, **Actual**, **Environment** | Symptom ≤ 2 sentences; repro steps numbered list; expected/actual ≤ 1 sentence each |
| Story / Feature | **Goal**, **Acceptance Criteria** | Goal = 1 sentence; AC = bullet list, each item testable |
| Task / Sub-task | **What** | 1–2 sentences; add **Why** only if non-obvious |
| Epic | **Goal**, **Scope**, **Out of Scope** | Goal = 1 sentence; scope + out-of-scope as bullet lists |

Minimum viable ADF skeleton for a Bug description:

```json
{
  "type": "doc", "version": 1,
  "content": [
    {"type": "heading", "attrs": {"level": 3}, "content": [{"type": "text", "text": "Symptom"}]},
    {"type": "paragraph", "content": [{"type": "text", "text": "<1–2 sentences>"}]},
    {"type": "heading", "attrs": {"level": 3}, "content": [{"type": "text", "text": "Repro Steps"}]},
    {"type": "orderedList", "content": [
      {"type": "listItem", "content": [{"type": "paragraph", "content": [{"type": "text", "text": "<step>"}]}]}
    ]},
    {"type": "heading", "attrs": {"level": 3}, "content": [{"type": "text", "text": "Expected"}]},
    {"type": "paragraph", "content": [{"type": "text", "text": "<expected behaviour>"}]},
    {"type": "heading", "attrs": {"level": 3}, "content": [{"type": "text", "text": "Actual"}]},
    {"type": "paragraph", "content": [{"type": "text", "text": "<actual behaviour>"}]}
  ]
}
```

**When updating an existing issue**: carry over all existing field values (labels, components, fix versions, assignee) unless the user explicitly asks to change them. Never reset a field to empty.

---

### JIRA comments

- One paragraph, 3 sentences max.
- State the action taken or the finding. Do not restate the issue title.
- No sign-offs or greetings.

Example comment body (ADF):

```json
{
  "body": {
    "type": "doc", "version": 1,
    "content": [
      {"type": "paragraph", "content": [{"type": "text", "text": "<finding or action in 1–3 sentences>"}]}
    ]
  }
}
```

---

### GitHub PR titles

Format: `[TICKET-ID] <imperative verb> <what changed>`

- Extract TICKET-ID from the branch name using pattern `[A-Z]+-[0-9]+` (e.g. branch `PRODENG-123-fix-auth` → `PRODENG-123`).
- If no ticket ID is found in the branch name, omit the bracket prefix entirely.
- Verb examples: Add, Fix, Remove, Refactor, Update, Bump, Wire, Extract.
- 72 characters max including the ticket prefix.

Examples:
- `[PRODENG-456] Fix null deref in auth token refresh`
- `[MKE-89] Remove deprecated provider bootstrap flags`
- `Add missing timeout to S3 client initialization`

---

### GitHub PR body

Use this template verbatim. Fill every section. Write "N/A" only when genuinely not applicable — do not write it to avoid writing something real.

```markdown
## What
<!-- One sentence: what does this PR do? -->

## Why
<!-- One sentence: why is this change needed? -->

## How
<!-- Bullet list of key implementation decisions; ≤5 bullets; skip obvious steps -->

## Testing
<!-- How was this verified? One line per method (e.g. "Unit tests added", "Manually verified on staging") -->

## Links
- JIRA: [TICKET-ID](https://mirantis.jira.com/browse/TICKET-ID)

## Checklist
- [ ] Tests added or updated
- [ ] Docs updated if user-visible behaviour changed
- [ ] No debug output or dead code left in
```

**Length constraints** (enforced — do not exceed):
- What + Why combined: ≤ 50 words
- How: ≤ 5 bullets, each ≤ 15 words
- Testing: ≤ 3 lines
- Total PR body: ≤ 250 words

If the JIRA ticket cannot be determined, set the Links line to `- JIRA: N/A` and ask the user if they want to associate one before opening the PR.

