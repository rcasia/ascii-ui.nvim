# Permission Configuration Guide

This document explains the permission syntax used in `opencode.json`.

## Edit Permissions

Controls which files an agent can modify using file editing tools (Write, Edit, MultiEdit).

### Syntax

```json
"edit": {
  "<pattern>": "allow" | "deny",
  "*": "allow" | "deny"
}
```

### Patterns

- `*` — Matches all files (wildcard)
- `.opencode/*` — Matches all files under `.opencode/` directory
- `opencode.json` — Matches specific file
- `lua/ascii-ui/*` — Matches all files under `lua/ascii-ui/`

### Examples

**Allow everything except `.opencode/`:**
```json
"edit": {
  ".opencode/*": "deny",
  "*": "allow"
}
```

**Allow only specific directories:**
```json
"edit": {
  ".opencode/agents/*": "allow",
  ".opencode/skills/*": "allow",
  "opencode.json": "allow",
  "*": "deny"
}
```

**Deny all edits (read-only):**
```json
"edit": "deny"
```

## Bash Permissions

Controls which bash commands an agent can execute.

### Syntax

```json
"bash": {
  "<command_pattern>": "allow" | "deny",
  "*": "allow" | "deny"
}
```

### Command Patterns

- `*` — Matches all commands
- `gh *` — Matches `gh` command with any arguments
- `make check` — Matches exact command `make check`
- `make test *` — Matches `make test` with any arguments
- `git status` — Matches exact command `git status`
- `git diff` — Matches exact command `git diff`

### Pattern Matching Rules

1. **Exact match**: `make check` matches only `make check`
2. **Wildcard**: `gh *` matches `gh issue list`, `gh pr view`, etc.
3. **Order matters**: More specific patterns should come before `*`
4. **Last match wins**: If multiple patterns match, the last one in the list takes precedence

### Examples

**Allow only GitHub CLI commands:**
```json
"bash": {
  "gh *": "allow",
  "*": "deny"
}
```

**Allow verification commands only:**
```json
"bash": {
  "make check": "allow",
  "make test": "allow",
  "make test *": "allow",
  "git status": "allow",
  "git diff": "allow",
  "*": "deny"
}
```

**Allow all bash commands:**
```json
"bash": "allow"
```

**Deny all bash commands:**
```json
"bash": "deny"
```

## Permission Matrix

| Agent | Edit Scope | Bash Scope | Purpose |
|-------|-----------|-----------|---------|
| task-scheduler | ❌ None | `gh *` only | Read GitHub issues/PRs, delegate work |
| ascii-ui-dev | ✅ All except `.opencode/` | ✅ All | Implement features, fix bugs, commit code |
| nvim-docs-researcher | ❌ None | ❌ None | Read-only research |
| convention-reviewer | ❌ None | `make check/test`, `git status/diff` | Verify conventions |
| agent-teacher | ✅ `.opencode/agents/*`, `.opencode/skills/*`, `opencode.json` | ✅ All | Update agent instructions, create skills |

## Common Mistakes

### ❌ Wrong: Wildcard before specific patterns

```json
"bash": {
  "*": "deny",
  "gh *": "allow"  // This won't work - * matches first
}
```

### ✅ Correct: Specific patterns first

```json
"bash": {
  "gh *": "allow",
  "*": "deny"
}
```

### ❌ Wrong: Missing wildcard for arguments

```json
"bash": {
  "gh": "allow"  // Only matches "gh" with no arguments
}
```

### ✅ Correct: Include wildcard for arguments

```json
"bash": {
  "gh *": "allow"  // Matches "gh" with any arguments
}
```

## Testing Permissions

To verify permissions work as expected:

1. **Edit permissions**: Try editing a file outside allowed scope → should fail
2. **Bash permissions**: Try running a disallowed command → should fail
3. **Check logs**: Look for permission denied errors in agent output

## Updating Permissions

When adding new permissions:

1. **Start restrictive**: Use `"*": "deny"` as baseline
2. **Add specific allows**: List only needed commands/patterns
3. **Test thoroughly**: Verify agent can complete tasks
4. **Document changes**: Update this file if adding new patterns

## Changelog

- 2026-08-08: Initial permission documentation created
