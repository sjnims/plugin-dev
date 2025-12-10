# Community Marketplace Example

A public multi-plugin marketplace curating plugins from various authors.

## Use Case

- Curate best-of-breed plugins for a domain
- Community-driven plugin discovery
- Mix of local and external plugin sources

## Directory Structure

```text
awesome-claude-plugins/
├── .claude-plugin/
│   └── marketplace.json
├── plugins/
│   └── featured-plugin/          # Locally maintained plugin
│       └── .claude-plugin/
│           └── plugin.json
├── CONTRIBUTING.md
├── README.md
└── .github/
    └── workflows/
        └── validate.yml          # CI validation
```

## marketplace.json

```json
{
  "name": "awesome-claude-plugins",
  "owner": {
    "name": "Community Maintainers",
    "url": "https://github.com/awesome-claude-plugins"
  },
  "metadata": {
    "description": "Curated collection of high-quality Claude Code plugins",
    "version": "1.3.0"
  },
  "plugins": [
    {
      "name": "code-reviewer",
      "source": {
        "source": "github",
        "repo": "author1/code-reviewer-plugin"
      },
      "description": "AI-powered code review assistant",
      "version": "2.0.0",
      "category": "development",
      "tags": ["review", "quality"],
      "author": {
        "name": "Author One",
        "url": "https://github.com/author1"
      }
    },
    {
      "name": "test-generator",
      "source": {
        "source": "github",
        "repo": "author2/test-generator"
      },
      "description": "Automatic test case generation",
      "version": "1.5.0",
      "category": "testing",
      "tags": ["testing", "automation"],
      "author": {
        "name": "Author Two"
      }
    },
    {
      "name": "doc-writer",
      "source": {
        "source": "github",
        "repo": "docs-team/doc-writer"
      },
      "description": "Documentation generation and maintenance",
      "version": "3.1.0",
      "category": "documentation",
      "tags": ["docs", "markdown"]
    },
    {
      "name": "featured-plugin",
      "source": "./plugins/featured-plugin",
      "description": "Marketplace's featured community plugin",
      "version": "1.0.0",
      "category": "productivity"
    },
    {
      "name": "legacy-tool",
      "source": {
        "source": "github",
        "repo": "legacy/tool-plugin"
      },
      "description": "Legacy tool without plugin.json",
      "version": "0.9.0",
      "category": "utilities",
      "strict": false,
      "commands": "./commands/"
    }
  ]
}
```

## README.md Template

```markdown
# Awesome Claude Plugins

A curated collection of high-quality Claude Code plugins.

## Installation

```bash
/plugin marketplace add awesome-claude-plugins/awesome-claude-plugins
```

## Available Plugins

| Plugin | Description | Category |
|--------|-------------|----------|
| code-reviewer | AI-powered code review | Development |
| test-generator | Automatic test generation | Testing |
| doc-writer | Documentation generation | Documentation |
| featured-plugin | Community featured plugin | Productivity |

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) for submission guidelines.

## License

MIT
```

## CONTRIBUTING.md Template

```markdown
# Contributing

## Submitting a Plugin

1. Fork this repository
2. Add your plugin entry to `marketplace.json`
3. Ensure your plugin:
   - Has a valid `plugin.json` (or use `strict: false`)
   - Includes description and version
   - Is publicly accessible
4. Submit a PR with:
   - Plugin entry in `marketplace.json`
   - Brief description of what the plugin does

## Plugin Requirements

- [ ] Public GitHub repository
- [ ] Valid plugin structure
- [ ] No security vulnerabilities
- [ ] Clear documentation

## Review Process

1. Automated validation runs on PR
2. Maintainer reviews plugin quality
3. Community feedback period (1 week)
4. Merge and marketplace update
```

## CI Validation Workflow

`.github/workflows/validate.yml`:

```yaml
name: Validate Marketplace

on:
  pull_request:
    paths:
      - '.claude-plugin/marketplace.json'

jobs:
  validate:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Validate JSON syntax
        run: jq . .claude-plugin/marketplace.json

      - name: Check required fields
        run: |
          jq -e 'has("name") and has("owner") and has("plugins")' \
            .claude-plugin/marketplace.json

      - name: Check no duplicate plugin names
        run: |
          DUPES=$(jq '[.plugins[].name] | group_by(.) | map(select(length > 1)) | length' \
            .claude-plugin/marketplace.json)
          if [ "$DUPES" -gt 0 ]; then
            echo "Duplicate plugin names found"
            exit 1
          fi
```

## Installation

```bash
# Add marketplace
/plugin marketplace add awesome-claude-plugins/awesome-claude-plugins

# Browse available plugins
/plugin

# Install specific plugin
/plugin install code-reviewer@awesome-claude-plugins
```
