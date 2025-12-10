# Distribution Patterns

Strategies for hosting, distributing, and managing plugin marketplaces.

## Hosting Options

### GitHub Hosting (Recommended)

The simplest distribution method with built-in version control:

```text
my-marketplace/
├── .claude-plugin/
│   └── marketplace.json
├── plugins/
│   └── ... (optional local plugins)
└── README.md
```

**Installation:**

```bash
/plugin marketplace add owner/repo
```

**Benefits:**

- Free hosting for public repositories
- Built-in issue tracking and collaboration
- Automatic version history
- Pull request workflow for plugin additions
- GitHub Actions for validation

### GitLab / Other Git Services

Any git hosting service works:

```bash
/plugin marketplace add https://gitlab.com/company/plugins.git
```

**Use when:**

- Organization uses GitLab, Bitbucket, or self-hosted git
- Need private repository hosting
- Integration with existing CI/CD pipelines

### Local Development

Test marketplaces locally before publishing:

```bash
# Add local directory
/plugin marketplace add ./my-marketplace

# Add direct path to marketplace.json
/plugin marketplace add ./path/to/marketplace.json
```

## Team Distribution Patterns

### Pattern 1: Shared Repository Settings

Configure team marketplaces in `.claude/settings.json` (project or organization level):

```json
{
  "extraKnownMarketplaces": {
    "team-tools": {
      "source": {
        "source": "github",
        "repo": "company/claude-plugins"
      }
    },
    "project-plugins": {
      "source": {
        "source": "git",
        "url": "https://git.company.com/project-plugins.git"
      }
    }
  }
}
```

When team members trust the repository folder, Claude Code automatically installs these marketplaces.

### Pattern 2: Enabled Plugins List

Pre-configure required plugins for a project:

```json
{
  "extraKnownMarketplaces": {
    "team-tools": {
      "source": {
        "source": "github",
        "repo": "company/plugins"
      }
    }
  },
  "enabledPlugins": [
    "security-scanner@team-tools",
    "code-formatter@team-tools"
  ]
}
```

### Pattern 3: Monorepo Marketplace

For organizations with many plugins in one repository:

```text
org-plugins/
├── .claude-plugin/
│   └── marketplace.json
└── plugins/
    ├── security-scanner/
    ├── code-formatter/
    ├── test-runner/
    └── deployment-tools/
```

```json
{
  "name": "org-plugins",
  "metadata": {
    "pluginRoot": "./plugins"
  },
  "plugins": [
    { "name": "security-scanner", "source": "./security-scanner" },
    { "name": "code-formatter", "source": "./code-formatter" },
    { "name": "test-runner", "source": "./test-runner" },
    { "name": "deployment-tools", "source": "./deployment-tools" }
  ]
}
```

### Pattern 4: Curated External Plugins

Marketplace that curates plugins from various sources:

```json
{
  "name": "curated-tools",
  "plugins": [
    {
      "name": "plugin-a",
      "source": { "source": "github", "repo": "author1/plugin-a" }
    },
    {
      "name": "plugin-b",
      "source": { "source": "github", "repo": "author2/plugin-b" }
    },
    {
      "name": "internal-tool",
      "source": "./plugins/internal-tool"
    }
  ]
}
```

## Version Management

### Marketplace Versioning

Track marketplace changes with semantic versioning:

```json
{
  "metadata": {
    "version": "2.1.0"
  }
}
```

| Change Type | Version Bump | Examples |
|-------------|--------------|----------|
| Breaking | Major (X.0.0) | Remove plugins, major restructuring |
| Feature | Minor (X.Y.0) | Add new plugins, new categories |
| Fix | Patch (X.Y.Z) | Update versions, fix metadata |

### Plugin Version Tracking

Always include version in plugin entries:

```json
{
  "name": "my-plugin",
  "version": "1.2.3",
  "source": "./plugins/my-plugin"
}
```

### Update Workflow

```bash
# Refresh marketplace metadata
/plugin marketplace update marketplace-name

# Check for plugin updates
/plugin marketplace list
```

## Multi-Environment Distribution

### Development vs. Production

Maintain separate marketplaces for environments:

```text
plugins-repo/
├── .claude-plugin/
│   └── marketplace.json           # Stable plugins
├── staging/
│   └── .claude-plugin/
│       └── marketplace.json       # Pre-release testing
└── plugins/
```

### Feature Branches

Use git branches for experimental plugins:

```bash
# Add marketplace from specific branch
/plugin marketplace add owner/repo#feature-branch
```

## Security Considerations

### Access Control

- **Public marketplaces**: Anyone can install plugins
- **Private repositories**: Only authorized users can access
- **Team settings**: Control which marketplaces are auto-installed

### Plugin Verification

Before adding external plugins to your marketplace:

1. Review source code for security issues
2. Check for hardcoded credentials
3. Verify hook commands are safe
4. Test in isolated environment

### Secure Distribution Checklist

- [ ] Use HTTPS for all git URLs
- [ ] MCP servers use HTTPS/WSS, not HTTP/WS
- [ ] No credentials in marketplace.json
- [ ] External plugins reviewed before curation
- [ ] Private repositories for sensitive tools

## Marketplace Management Commands

### List Marketplaces

```bash
/plugin marketplace list
```

### Update Marketplace

```bash
/plugin marketplace update marketplace-name
```

### Remove Marketplace

```bash
/plugin marketplace remove marketplace-name
```

**Note:** Removing a marketplace uninstalls all plugins from it.

### Install Plugins

```bash
# Install from specific marketplace
/plugin install plugin-name@marketplace-name

# Browse available plugins
/plugin
```

## Troubleshooting

### Marketplace Not Loading

1. Verify URL/path is accessible
2. Check `.claude-plugin/marketplace.json` exists at correct path
3. Validate JSON syntax
4. Confirm access permissions (for private repos)

### Plugin Installation Fails

1. Verify plugin source URL is accessible
2. Check plugin directory contains required files
3. For GitHub sources, ensure repository is public or access is available
4. Test plugin sources manually by cloning

### Validation Commands

```bash
# Validate JSON syntax
jq . .claude-plugin/marketplace.json

# Check required fields
jq 'has("name") and has("owner") and has("plugins")' \
  .claude-plugin/marketplace.json

# Validate in Claude Code
claude plugin validate .
```

## Migration Patterns

### From Single Plugin to Marketplace

1. Create `.claude-plugin/marketplace.json`
2. Move plugin to `plugins/` subdirectory
3. Add plugin entry with relative source
4. Update installation instructions

### Consolidating Multiple Plugins

1. Create new marketplace repository
2. Add each plugin as entry (relative or external source)
3. Test installation of all plugins
4. Migrate users to marketplace-based installation
