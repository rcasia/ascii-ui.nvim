# opencode.json Configuration Guide

**Source of Truth**: The official schema at https://opencode.ai/config.json

Always refer to the schema for the most up-to-date configuration options and syntax.

## Overview

`opencode.json` configures the opencode agent system for your project. This guide covers the main configuration sections:

- **agent**: Define custom agents with specific roles and permissions
- **permission**: Control tool access globally or per-agent
- **model**: Configure AI models and providers
- **mcp**: Set up Model Context Protocol servers
- **layout**: Define UI layout configuration
- **server**: Configure server settings
- **skills**: Configure skill system

## Basic Structure

```json
{
  "$schema": "https://opencode.ai/config.json",
  "default_agent": "agent-name",
  "agent": { ... },
  "model": { ... },
  "permission": { ... },
  "mcp": { ... },
  "layout": { ... },
  "server": { ... }
}
```

## Agent Configuration

Define custom agents with specific roles, models, and permissions.

### Agent Properties

```json
{
  "agent": {
    "my-agent": {
      "model": "provider/model-name",
      "temperature": 0.7,
      "top_p": 0.9,
      "prompt": "Custom system prompt for this agent",
      "description": "What this agent does (shown in UI)",
      "mode": "primary" | "subagent" | "all",
      "permission": { ... },
      "tools": { ... },
      "disable": false
    }
  }
}
```

### Agent Modes

- **primary**: Can be the default agent, handles direct user interaction
- **subagent**: Can only be invoked by other agents
- **all**: Can act as both primary and subagent

### Example: Multi-Agent Setup

```json
{
  "agent": {
    "coordinator": {
      "model": "anthropic/claude-3.5-sonnet",
      "mode": "primary",
      "description": "Coordinates work between specialized agents",
      "permission": {
        "bash": {
          "git *": "allow",
          "*": "deny"
        }
      }
    },
    "developer": {
      "model": "anthropic/claude-3.5-sonnet",
      "mode": "subagent",
      "description": "Implements features and fixes bugs",
      "permission": {
        "edit": "allow",
        "bash": "allow"
      }
    },
    "reviewer": {
      "model": "anthropic/claude-3.5-sonnet",
      "mode": "subagent",
      "description": "Reviews code for quality",
      "permission": {
        "read": "allow",
        "edit": "deny",
        "bash": "deny"
      }
    }
  },
  "default_agent": "coordinator"
}
```

## Permission Configuration

Control which tools and actions agents can perform.

### Permission Types

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

### Permission Syntax

**Simple Action (All or Nothing)**
```json
"permission": {
  "edit": "deny",
  "bash": "allow"
}
```

**Object with Patterns**
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

### Pattern Matching

For `PermissionObjectConfig`, keys are patterns that match against:
- **File paths** (for `read`, `edit`, `glob`, `grep`, `list`)
- **Command strings** (for `bash`)

**Pattern Rules**
1. **Exact match**: `"make check"` matches only `make check`
2. **Wildcard**: `"gh *"` matches `gh` with any arguments
3. **Path patterns**: `".opencode/*"` matches all files under `.opencode/`
4. **Order matters**: More specific patterns should come before general ones
5. **Last match wins**: If multiple patterns match, the last one takes precedence

### Permission Actions

- **allow**: Permit the action
- **deny**: Block the action
- **ask**: Prompt user for permission each time

### Example: Permission Matrix

```json
{
  "agent": {
    "task-scheduler": {
      "permission": {
        "edit": "deny",
        "bash": {
          "gh *": "allow",
          "*": "deny"
        }
      }
    },
    "developer": {
      "permission": {
        "edit": {
          ".opencode/*": "deny",
          "*": "allow"
        },
        "bash": "allow"
      }
    },
    "researcher": {
      "permission": {
        "read": "allow",
        "edit": "deny",
        "bash": "deny",
        "webfetch": "allow"
      }
    }
  }
}
```

## Model Configuration

Configure AI models and providers.

### Model Properties

```json
{
  "model": "provider/model-name",
  "small_model": "provider/model-name",
  "provider": {
    "provider-name": {
      "api_key": "sk-...",
      "base_url": "https://api.provider.com/v1"
    }
  },
  "disabled_providers": ["provider1", "provider2"],
  "enabled_providers": ["provider3"]
}
```

### Example: Multi-Provider Setup

```json
{
  "model": "anthropic/claude-3.5-sonnet",
  "small_model": "anthropic/claude-3-haiku",
  "provider": {
    "anthropic": {
      "api_key": "${ANTHROPIC_API_KEY}"
    },
    "openai": {
      "api_key": "${OPENAI_API_KEY}"
    }
  }
}
```

## MCP (Model Context Protocol) Configuration

Set up MCP servers for extended capabilities.

### MCP Server Types

**Local Server**
```json
{
  "mcp": {
    "my-server": {
      "type": "local",
      "command": "node",
      "args": ["server.js"],
      "env": {
        "API_KEY": "${MY_API_KEY}"
      }
    }
  }
}
```

**Remote Server**
```json
{
  "mcp": {
    "remote-server": {
      "type": "remote",
      "url": "https://mcp.example.com",
      "headers": {
        "Authorization": "Bearer ${TOKEN}"
      }
    }
  }
}
```

### Example: Multiple MCP Servers

```json
{
  "mcp": {
    "filesystem": {
      "type": "local",
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-filesystem", "/path"]
    },
    "github": {
      "type": "local",
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-github"],
      "env": {
        "GITHUB_TOKEN": "${GITHUB_TOKEN}"
      }
    }
  }
}
```

## Layout Configuration

Define UI layout for the opencode interface.

```json
{
  "layout": {
    "height": 40,
    "width": 120
  }
}
```

## Server Configuration

Configure server settings for opencode.

```json
{
  "server": {
    "port": 3000,
    "hostname": "localhost",
    "mdns": true,
    "mdnsDomain": "opencode.local",
    "cors": ["http://localhost:8080"]
  }
}
```

## Other Configuration Options

### Shell Configuration

```json
{
  "shell": "/bin/zsh"
}
```

### Log Level

```json
{
  "logLevel": "INFO"  // DEBUG, INFO, WARN, ERROR
}
```

### Instructions

Add custom instructions for all agents:

```json
{
  "instructions": "Always use TypeScript for new files. Follow the project's coding standards."
}
```

### Tools Configuration

Enable/disable specific tools:

```json
{
  "tools": {
    "bash": true,
    "edit": true,
    "read": true,
    "webfetch": false
  }
}
```

### Skills Configuration

Configure the skill system:

```json
{
  "skills": {
    "enabled": true,
    "paths": ["./skills"]
  }
}
```

### Watcher Configuration

Configure file watching:

```json
{
  "watcher": {
    "enabled": true,
    "ignore": ["node_modules", ".git"]
  }
}
```

## Complete Example

```json
{
  "$schema": "https://opencode.ai/config.json",
  "default_agent": "coordinator",
  "model": "anthropic/claude-3.5-sonnet",
  "small_model": "anthropic/claude-3-haiku",
  "instructions": "Follow TypeScript best practices. Write tests for all new features.",
  "agent": {
    "coordinator": {
      "mode": "primary",
      "description": "Coordinates development workflow",
      "permission": {
        "edit": "deny",
        "bash": {
          "git *": "allow",
          "npm *": "allow",
          "*": "deny"
        }
      }
    },
    "developer": {
      "mode": "subagent",
      "description": "Implements features",
      "permission": {
        "edit": {
          ".opencode/*": "deny",
          "*": "allow"
        },
        "bash": "allow"
      }
    }
  },
  "mcp": {
    "filesystem": {
      "type": "local",
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-filesystem"]
    }
  },
  "server": {
    "port": 3000,
    "hostname": "localhost"
  },
  "layout": {
    "height": 40,
    "width": 120
  },
  "logLevel": "INFO"
}
```

## Validation

To validate your configuration:

1. **Check schema**: Ensure JSON is valid against https://opencode.ai/config.json
2. **Test permissions**: Try operations that should be allowed/denied
3. **Review logs**: Check for configuration errors in opencode logs

## Schema Reference

The complete schema includes these top-level properties:

- `$schema`: JSON schema reference
- `agent`: Agent configurations
- `attachment`: File attachment settings
- `autoshare`: Auto-sharing configuration
- `autoupdate`: Auto-update settings
- `command`: Custom commands
- `compaction`: Context compaction settings
- `default_agent`: Default agent name
- `disabled_providers`: List of disabled providers
- `enabled_providers`: List of enabled providers
- `enterprise`: Enterprise features
- `experimental`: Experimental features
- `formatter`: Code formatter settings
- `instructions`: Global instructions
- `layout`: UI layout
- `logLevel`: Logging level
- `lsp`: LSP configuration
- `mcp`: MCP server configurations
- `mode`: Operation mode
- `model`: Primary model
- `permission`: Global permissions
- `plugin`: Plugin configurations
- `provider`: Provider configurations
- `reference`: Reference configurations
- `references`: Reference list
- `server`: Server settings
- `share`: Sharing settings
- `shell`: Shell configuration
- `skills`: Skill system settings
- `small_model`: Smaller/faster model
- `snapshot`: Snapshot settings
- `subagent_depth`: Subagent recursion depth
- `tool_output`: Tool output settings
- `tools`: Tool enable/disable
- `username`: Username
- `watcher`: File watcher settings

## Best Practices

1. **Start simple**: Begin with minimal configuration, add complexity as needed
2. **Use schema**: Always validate against the official schema
3. **Test permissions**: Verify agents can complete tasks with configured permissions
4. **Document choices**: Comment why specific configurations were chosen
5. **Version control**: Track configuration changes in git
6. **Environment variables**: Use `${VAR}` syntax for sensitive values
7. **Test thoroughly**: Verify configuration works before deploying

## Troubleshooting

### Agent can't access needed files
- Check `read` and `edit` permissions
- Verify path patterns match actual file paths
- Test with exact file path

### Agent can't run commands
- Check `bash` permissions
- Verify command pattern matches (including arguments)
- Remember `"command"` only matches exact command, `"command *"` matches with args

### Configuration not loading
- Validate JSON syntax
- Check `$schema` reference is correct
- Review opencode logs for errors

### MCP server not connecting
- Verify command and args are correct
- Check environment variables are set
- Test MCP server manually

## Changelog

- 2026-02-08: Expanded from PERMISSIONS.md to comprehensive CONFIG.md
- 2026-02-08: Added all major configuration sections from schema
- 2026-02-08: Initial permission documentation created
