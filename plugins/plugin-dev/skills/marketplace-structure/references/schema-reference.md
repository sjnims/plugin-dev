# Marketplace Schema Reference

Complete field reference for `marketplace.json` and plugin entries.

## Marketplace Root Fields

### Required Fields

| Field | Type | Constraints | Description |
|-------|------|-------------|-------------|
| `name` | string | kebab-case, 3-50 chars | Unique marketplace identifier |
| `owner` | object | See Owner Object | Marketplace maintainer information |
| `plugins` | array | At least 1 entry | List of available plugins |

### Optional Metadata Object

```json
{
  "metadata": {
    "description": "string",
    "version": "string",
    "pluginRoot": "string"
  }
}
```

| Field | Type | Description |
|-------|------|-------------|
| `description` | string | Brief marketplace description (1-200 chars) |
| `version` | string | Marketplace version (semver X.Y.Z recommended) |
| `pluginRoot` | string | Base path for relative plugin sources |

## Owner Object

### Required Owner Fields

| Field | Type | Description |
|-------|------|-------------|
| `name` | string | Maintainer name (person or organization) |

### Optional Owner Fields

| Field | Type | Description |
|-------|------|-------------|
| `email` | string | Contact email address |
| `url` | string | Maintainer homepage or profile URL |

### Example

```json
{
  "owner": {
    "name": "DevTools Team",
    "email": "devtools@company.com",
    "url": "https://github.com/company"
  }
}
```

## Plugin Entry Fields

### Required Plugin Fields

| Field | Type | Description |
|-------|------|-------------|
| `name` | string | Plugin identifier (kebab-case, unique within marketplace) |
| `source` | string or object | Where to fetch the plugin (see Source Types) |

### Optional Standard Metadata

| Field | Type | Description |
|-------|------|-------------|
| `description` | string | Brief plugin description |
| `version` | string | Plugin version (semver X.Y.Z) |
| `author` | object | Plugin author (same format as owner) |
| `homepage` | string | Plugin documentation URL |
| `repository` | string | Source code repository URL |
| `license` | string | SPDX license identifier (MIT, Apache-2.0, etc.) |
| `keywords` | array | String tags for discovery |
| `category` | string | Plugin category (productivity, security, etc.) |
| `tags` | array | Additional searchability tags |

### Marketplace-Specific Fields

| Field | Type | Default | Description |
|-------|------|---------|-------------|
| `strict` | boolean | `true` | Require `plugin.json` in plugin folder |

### Component Configuration Fields

These fields override or supplement plugin component paths:

| Field | Type | Description |
|-------|------|-------------|
| `commands` | string or array | Custom paths to command files or directories |
| `agents` | string or array | Custom paths to agent files |
| `hooks` | string or object | Hooks configuration or path to hooks file |
| `mcpServers` | string or object | MCP server configurations or path |

## Source Types

### Relative Path (String)

For plugins in the same repository:

```json
{
  "source": "./plugins/my-plugin"
}
```

Paths are relative to:

1. `metadata.pluginRoot` if specified
2. Repository root otherwise

### GitHub Repository (Object)

```json
{
  "source": {
    "source": "github",
    "repo": "owner/repo-name"
  }
}
```

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `source` | string | Yes | Must be `"github"` |
| `repo` | string | Yes | GitHub repository in `owner/repo` format |

### Git URL (Object)

For GitLab, Bitbucket, or self-hosted git repositories:

```json
{
  "source": {
    "source": "url",
    "url": "https://gitlab.com/team/plugin.git"
  }
}
```

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `source` | string | Yes | Must be `"url"` |
| `url` | string | Yes | Full git clone URL |

## Complete Plugin Entry Example

Advanced plugin entry with all optional fields:

```json
{
  "name": "enterprise-tools",
  "source": {
    "source": "github",
    "repo": "company/enterprise-plugin"
  },
  "description": "Enterprise workflow automation tools",
  "version": "2.1.0",
  "author": {
    "name": "Enterprise Team",
    "email": "enterprise@company.com"
  },
  "homepage": "https://docs.company.com/plugins/enterprise-tools",
  "repository": "https://github.com/company/enterprise-plugin",
  "license": "MIT",
  "keywords": ["enterprise", "workflow", "automation"],
  "category": "productivity",
  "tags": ["enterprise", "automation"],
  "commands": [
    "./commands/core/",
    "./commands/enterprise/"
  ],
  "agents": [
    "./agents/security-reviewer.md",
    "./agents/compliance-checker.md"
  ],
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Write|Edit",
        "hooks": [
          {
            "type": "command",
            "command": "${CLAUDE_PLUGIN_ROOT}/scripts/validate.sh"
          }
        ]
      }
    ]
  },
  "mcpServers": {
    "enterprise-db": {
      "command": "${CLAUDE_PLUGIN_ROOT}/servers/db-server",
      "args": ["--config", "${CLAUDE_PLUGIN_ROOT}/config.json"]
    }
  },
  "strict": false
}
```

## Strict Mode Details

### strict: true (Default)

- Plugin directory must contain `.claude-plugin/plugin.json`
- Marketplace entry fields supplement plugin manifest values
- Plugin manifest takes precedence for conflicting fields

### strict: false

- `plugin.json` is optional in plugin directory
- Marketplace entry serves as complete plugin manifest if no `plugin.json` exists
- Useful for curating external plugins or lightweight plugin directories

### When to Use strict: false

| Scenario | Reasoning |
|----------|-----------|
| External plugins | Cannot modify external source to add plugin.json |
| Minimal plugins | Plugin has only commands/agents without needing manifest |
| Complete metadata in entry | All plugin info provided in marketplace entry |
| Legacy plugins | Older plugins without manifest file |

## Validation Rules

### Marketplace Level

- `name` must be kebab-case (lowercase letters, numbers, hyphens)
- `name` must be 3-50 characters
- `owner.name` is required
- `plugins` array must have at least one entry
- No duplicate plugin names in `plugins` array

### Plugin Entry Level

- `name` must be kebab-case
- `name` must be unique within the marketplace
- `source` must be valid (string path or recognized source object)
- `version` should follow semver if provided
- `license` should be valid SPDX identifier if provided

### Source Validation

- Relative paths: Must start with `./` or `../`
- GitHub sources: `repo` must be `owner/repo` format
- URL sources: Must be valid git URL

## Schema Relationship

Plugin entries build on the plugin manifest schema:

```text
plugin.json schema (all fields optional in marketplace entry)
    + marketplace-specific fields (source, strict, category, tags)
    = marketplace plugin entry
```

This means any field valid in `plugin.json` can also be used in a marketplace entry.
