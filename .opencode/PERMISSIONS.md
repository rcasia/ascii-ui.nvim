# Permission Configuration Guide

**Source of Truth**: The official schema at https://opencode.ai/config.json

Always refer to the schema for the most up-to-date permission syntax and available options.

## Overview

Permissions control what tools and actions each agent can perform. The schema defines:

- **PermissionActionConfig**: `"ask"`, `"allow"`, `"deny"`
- **PermissionObjectConfig**: Object mapping patterns to actions
- **PermissionRuleConfig**: Either a simple action or an object with patterns

## Permission Types

The following tools/actions can be configured:

| Permission | Description |
|------------|-------------|
| `read` | File reading operations |
| `edit` | File editing operations (Write, Edit, MultiEdit) |
| `glob` | File pattern matching |
| `grep` | Content searching |
| `list` | Directory listing |
| `bash` | Shell command execution |
| `task` | Task tool (delegation) |
| `external_directory` | Access to directories outside workspace |
| `todowrite` | Todo list management |
| `question` | Question tool |
| `webfetch` | Web content fetching |
| `websearch` | Web search |
| `lsp` | Language Server Protocol operations |
| `doom_loop` | Doom loop detection |
| `skill` | Skill loading |

## Syntax

### Simple Action (All or Nothing)

```json
"permission": {
  "edit": "deny",
  "bash": "allow"
}
```

### Object with Patterns

```json
"permission": {
  "edit": {
    ".opencode/*": "deny",
    "*": "allow"
  },
  "bash": {
    "gh *": "allow",
    "make check": "allow",
    "*": "deny"
  }
}
```

### Mixed Approach

```json
"permission": {
  "read": "allow",
  "edit": {
    "src/*": "allow",
    "*": "deny"
  },
  "bash": {
    "git *": "allow",
    "npm *": "allow",
    "*": "deny"
  }
}
```

## Pattern Matching

For `PermissionObjectConfig`, keys are patterns that match against:

- **File paths** (for `read`, `edit`, `glob`, `grep`, `list`)
- **Command strings** (for `bash`)

### Pattern Rules

1. **Exact match**: `"make check"` matches only `make check`
2. **Wildcard**: `"gh *"` matches `gh` with any arguments
3. **Path patterns**: `".opencode/*"` matches all files under `.opencode/`
4. **Order matters**: More specific patterns should come before general ones
5. **Last match wins**: If multiple patterns match, the last one takes precedence

### Examples

**File path patterns:**
```json
"edit": {
  "src/components/*": "allow",
  "src/**/*.test.ts": "allow",
  ".env": "deny",
  "*": "deny"
}
```

**Command patterns:**
```json
"bash": {
  "git status": "allow",
  "git diff *": "allow",
  "git commit *": "deny",
  "make *": "allow",
  "*": "deny"
}
```

## Agent Permission Matrix

Current configuration for this project:

| Agent | Edit | Bash | Purpose |
|-------|------|------|---------|
| task-scheduler | ❌ deny | `gh *` only | Read GitHub, delegate work |
| ascii-ui-dev | ✅ all except `.opencode/*` | ✅ allow | Implementation |
| nvim-docs-researcher | ❌ deny | ❌ deny | Read-only research |
| convention-reviewer | ❌ deny | Verification commands only | Code review |
| agent-teacher | ✅ `.opencode/*` | ✅ allow | Agent improvement |

## Common Patterns

### Read-Only Agent

```json
"permission": {
  "read": "allow",
  "edit": "deny",
  "bash": "deny"
}
```

### Implementation Agent

```json
"permission": {
  "read": "allow",
  "edit": "allow",
  "bash": "allow"
}
```

### Restricted Bash (Verification Only)

```json
"bash": {
  "make check": "allow",
  "make test": "allow",
  "git status": "allow",
  "git diff": "allow",
  "*": "deny"
}
```

### Protected Directories

```json
"edit": {
  ".opencode/*": "deny",
  ".env*": "deny",
  "node_modules/*": "deny",
  "*": "allow"
}
```

## Validation

To validate your permission configuration:

1. **Check schema**: Ensure JSON is valid against https://opencode.ai/config.json
2. **Test permissions**: Try operations that should be allowed/denied
3. **Review logs**: Check for permission denied errors

## Schema Reference

The complete permission schema:

```json
{
  "PermissionActionConfig": {
    "type": "string",
    "enum": ["ask", "allow", "deny"]
  },
  "PermissionObjectConfig": {
    "type": "object",
    "additionalProperties": {
      "$ref": "#/$defs/PermissionActionConfig"
    }
  },
  "PermissionRuleConfig": {
    "anyOf": [
      { "$ref": "#/$defs/PermissionActionConfig" },
      { "$ref": "#/$defs/PermissionObjectConfig" }
    ]
  },
  "PermissionConfig": {
    "anyOf": [
      { "$ref": "#/$defs/PermissionActionConfig" },
      {
        "type": "object",
        "properties": {
          "read": { "$ref": "#/$defs/PermissionRuleConfig" },
          "edit": { "$ref": "#/$defs/PermissionRuleConfig" },
          "glob": { "$ref": "#/$defs/PermissionRuleConfig" },
          "grep": { "$ref": "#/$defs/PermissionRuleConfig" },
          "list": { "$ref": "#/$defs/PermissionRuleConfig" },
          "bash": { "$ref": "#/$defs/PermissionRuleConfig" },
          "task": { "$ref": "#/$defs/PermissionRuleConfig" },
          "external_directory": { "$ref": "#/$defs/PermissionRuleConfig" },
          "todowrite": { "$ref": "#/$defs/PermissionActionConfig" },
          "question": { "$ref": "#/$defs/PermissionActionConfig" },
          "webfetch": { "$ref": "#/$defs/PermissionActionConfig" },
          "websearch": { "$ref": "#/$defs/PermissionActionConfig" },
          "lsp": { "$ref": "#/$defs/PermissionRuleConfig" },
          "doom_loop": { "$ref": "#/$defs/PermissionActionConfig" },
          "skill": { "$ref": "#/$defs/PermissionRuleConfig" }
        }
      }
    ]
  }
}
```

## Best Practices

1. **Start restrictive**: Use `"*": "deny"` as baseline, then allow specific patterns
2. **Be explicit**: Document why certain permissions are granted/denied
3. **Test thoroughly**: Verify agents can complete tasks with configured permissions
4. **Review regularly**: Update permissions as agent needs change
5. **Use schema**: Always validate against the official schema

## Troubleshooting

### Agent can't access needed files
- Check `read` and `edit` permissions
- Verify path patterns match actual file paths
- Test with exact file path

### Agent can't run commands
- Check `bash` permissions
- Verify command pattern matches (including arguments)
- Remember `"command"` only matches exact command, `"command *"` matches with args

### Agent accessing protected resources
- Add explicit `"deny"` rules for sensitive paths/commands
- Use `external_directory: "deny"` to prevent workspace escape
- Review and tighten permission patterns

## Changelog

- 2026-02-08: Updated to reference official schema as source of truth
- 2026-02-08: Added complete list of permission types from schema
- 2026-02-08: Initial permission documentation created
