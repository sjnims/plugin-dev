# Team Marketplace Example

An internal company marketplace with team settings integration.

## Use Case

- Distribute approved plugins across engineering team
- Auto-install required plugins for projects
- Mix of internal and curated external plugins

## Directory Structure

```text
company-plugins/
├── .claude-plugin/
│   └── marketplace.json
├── plugins/
│   ├── code-standards/
│   │   ├── .claude-plugin/
│   │   │   └── plugin.json
│   │   ├── commands/
│   │   └── hooks/
│   └── security-scanner/
│       ├── .claude-plugin/
│       │   └── plugin.json
│       └── agents/
└── README.md
```

## marketplace.json

```json
{
  "name": "company-plugins",
  "owner": {
    "name": "Platform Team",
    "email": "platform@company.com",
    "url": "https://github.com/company"
  },
  "metadata": {
    "description": "Official plugins for Company engineering teams",
    "version": "2.0.0",
    "pluginRoot": "./plugins"
  },
  "plugins": [
    {
      "name": "code-standards",
      "source": "./code-standards",
      "description": "Enforces company coding standards",
      "version": "1.5.0",
      "category": "quality"
    },
    {
      "name": "security-scanner",
      "source": "./security-scanner",
      "description": "Security vulnerability detection",
      "version": "2.1.0",
      "category": "security"
    },
    {
      "name": "approved-formatter",
      "source": {
        "source": "github",
        "repo": "company/code-formatter"
      },
      "description": "Company-approved code formatter",
      "version": "3.0.0"
    }
  ]
}
```

## Team Settings Integration

Add to project's `.claude/settings.json`:

```json
{
  "extraKnownMarketplaces": {
    "company-plugins": {
      "source": {
        "source": "github",
        "repo": "company/claude-plugins"
      }
    }
  },
  "enabledPlugins": [
    "code-standards@company-plugins",
    "security-scanner@company-plugins"
  ]
}
```

## Project-Specific Settings

For projects requiring specific plugins, commit `.claude/settings.json`:

```json
{
  "extraKnownMarketplaces": {
    "company-plugins": {
      "source": {
        "source": "github",
        "repo": "company/claude-plugins"
      }
    }
  },
  "enabledPlugins": [
    "code-standards@company-plugins"
  ]
}
```

When developers trust the project folder, these plugins install automatically.

## Adding New Plugins to the Marketplace

1. Create plugin in `plugins/` directory
2. Add entry to `marketplace.json`
3. Bump marketplace `metadata.version`
4. Create PR for review
5. After merge, team can run `/plugin marketplace update company-plugins`

## Installation for New Team Members

```bash
# One-time marketplace setup
/plugin marketplace add company/claude-plugins

# Install all required plugins
/plugin install code-standards@company-plugins
/plugin install security-scanner@company-plugins
```

Or let project settings auto-install by trusting the project folder.
