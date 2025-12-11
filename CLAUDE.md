# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

This repository is a **plugin marketplace** containing the **plugin-dev** plugin - a comprehensive toolkit for developing Claude Code plugins. It provides 8 specialized skills, 3 agents, and 2 guided workflow commands for building high-quality plugins and marketplaces.

## Quick Reference

**Current Version**: v0.1.0 (see [CHANGELOG.md](CHANGELOG.md) for release history)

## Repository Structure

```
plugin-dev/                      # Marketplace root
├── .claude-plugin/
│   └── marketplace.json         # Marketplace manifest
├── plugins/
│   └── plugin-dev/              # The actual plugin
│       ├── .claude-plugin/
│       │   └── plugin.json      # Plugin manifest
│       ├── commands/            # Slash commands
│       ├── agents/              # Autonomous agents
│       └── skills/              # 8 specialized skills
└── .github/workflows/           # CI/CD workflows
```

## Architecture Note

This repo has two levels of `.claude-plugin/`:

- **Root level**: `/.claude-plugin/marketplace.json` - Marketplace manifest listing available plugins
- **Plugin level**: `/plugins/plugin-dev/.claude-plugin/plugin.json` - Individual plugin manifest

When testing locally, point to the plugin directory, not the root.

## Key Conventions

### Skill Structure

Each skill follows progressive disclosure:

- `SKILL.md` - Core content (1,500-2,000 words, lean)
- `references/` - Detailed documentation loaded into context as needed
- `examples/` - Complete working examples and templates for copy-paste
- `scripts/` - Utility scripts (executable without loading into context)

**The 8 Skills:**

1. `hook-development` - Event-driven automation with prompt-based hooks
2. `mcp-integration` - Model Context Protocol server configuration
3. `plugin-structure` - Directory layout and manifest configuration
4. `plugin-settings` - Configuration via .claude/plugin-name.local.md files
5. `command-development` - Slash commands with frontmatter
6. `agent-development` - Autonomous agents with AI-assisted generation
7. `skill-development` - Creating skills with progressive disclosure
8. `marketplace-structure` - Plugin marketplace creation and distribution

**Note:** `mcp-integration`, `plugin-structure`, `skill-development`, and `marketplace-structure` have no utility scripts—they provide documentation and examples only.

### Writing Style

- **Skill descriptions**: Third-person ("This skill should be used when...")
- **Skill body**: Imperative/infinitive form ("To create X, do Y")
- **Trigger phrases**: Include specific user queries in descriptions

### Path References

Always use `${CLAUDE_PLUGIN_ROOT}` for portable paths in hooks, MCP configs, and scripts.

### Plugin hooks.json Format

Plugin hooks use wrapper format with `hooks` field:

```json
{
  "hooks": {
    "PreToolUse": [...],
    "Stop": [...]
  }
}
```

## Testing

Test the plugin locally:

```bash
# From repository root
cc --plugin-dir plugins/plugin-dev
```

Utility scripts (paths relative to `plugins/plugin-dev/`):

```bash
# Agent development
./skills/agent-development/scripts/create-agent-skeleton.sh <name> [dir]
./skills/agent-development/scripts/validate-agent.sh agents/agent-name.md
./skills/agent-development/scripts/test-agent-trigger.sh agents/agent-name.md

# Command development
./skills/command-development/scripts/validate-command.sh .claude/commands/my-command.md
./skills/command-development/scripts/check-frontmatter.sh .claude/commands/my-command.md

# Hook development
./skills/hook-development/scripts/validate-hook-schema.sh hooks/hooks.json
./skills/hook-development/scripts/test-hook.sh hooks/my-hook.sh input.json
./skills/hook-development/scripts/hook-linter.sh hooks/my-hook.sh

# Plugin settings
./skills/plugin-settings/scripts/validate-settings.sh .claude/plugin.local.md
./skills/plugin-settings/scripts/parse-frontmatter.sh .claude/plugin.local.md
```

## Linting

```bash
# Lint all markdown files
markdownlint '**/*.md' --ignore node_modules

# Auto-fix markdown issues
markdownlint '**/*.md' --ignore node_modules --fix

# Lint shell scripts
shellcheck plugins/plugin-dev/skills/*/scripts/*.sh
```

## Component Patterns

### Agents

Agents require YAML frontmatter with:

- `name`: kebab-case identifier (3-50 chars)
- `description`: Starts with "Use this agent when...", includes `<example>` blocks
- `model`: inherit/sonnet/opus/haiku
- `color`: blue/cyan/green/yellow/magenta/red
- `tools`: Comma-separated list of allowed tools (optional)
- `skills`: Comma-separated list of skills the agent can load (optional)

### Skills

Skills require:

- Directory in `skills/skill-name/`
- `SKILL.md` with YAML frontmatter (`name`, `description`)
- Strong trigger phrases in description
- Progressive disclosure (detailed content in `references/`)

### Commands

Commands are markdown files with frontmatter:

- `description`: Brief explanation (required)
- `argument-hint`: Optional argument placeholder text
- `allowed-tools`: Comma-separated list of permitted tools (restricts tool access)
- `model`: Model to use for command execution (inherit/sonnet/opus/haiku)
- `disable-model-invocation`: Set to `true` to prevent model invocation in subagents (for workflow commands that delegate to specialized agents)

### Skills/Agents Optional Frontmatter

Both skills and agents support `allowed-tools` to restrict tool access:

```yaml
allowed-tools: Read, Grep, Glob  # Read-only skill
```

Use for read-only workflows, security-sensitive tasks, or limited-scope operations.

### Hooks

Hooks defined in `hooks/hooks.json`:

- Events: PreToolUse, PermissionRequest, PostToolUse, Stop, SubagentStop, SessionStart, SessionEnd, UserPromptSubmit, PreCompact, Notification
- Types: `prompt` (LLM-driven) or `command` (bash scripts)
- Use matchers for tool filtering (e.g., "Write|Edit", "*")

## Workflow

### `/plugin-dev:create-plugin`

An 8-phase guided workflow for plugin creation:

1. Discovery - Understand requirements
2. Component Planning - Determine needed components
3. Detailed Design - Specify each component
4. Structure Creation - Create directories and manifest
5. Component Implementation - Build each component
6. Validation - Run validators
7. Testing - Verify in Claude Code
8. Documentation - Finalize README and marketplace publishing

### `/plugin-dev:create-marketplace`

An 8-phase guided workflow for marketplace creation:

1. Discovery - Understand marketplace purpose
2. Plugin Planning - Determine plugins to include
3. Metadata Design - Configure marketplace metadata
4. Structure Creation - Create directory and manifest
5. Plugin Entry Configuration - Configure each plugin entry
6. Distribution Setup - Configure team settings or community guidelines
7. Validation - Run marketplace validators
8. Testing & Finalization - Test installation and finalize

## Validation Agents

Use these agents proactively after creating components:

- **plugin-validator**: Validates entire plugin structure and marketplace.json
- **skill-reviewer**: Reviews skill quality and triggering
- **agent-creator**: Generates new agents from descriptions

## CI/CD

### PR Workflows

| Workflow | Trigger | Purpose |
|----------|---------|---------|
| `markdownlint.yml` | `**.md` changed | Lint markdown files |
| `links.yml` | `**.md` changed | Check for broken links |
| `component-validation.yml` | Plugin components changed | Validate plugin components |
| `version-check.yml` | Version files changed | Ensure version consistency |
| `validate-workflows.yml` | `.github/workflows/**` changed | Lint GitHub Actions |
| `claude-pr-review.yml` | All PRs (non-draft) | AI-powered code review |

### Other Workflows

- `claude.yml` - Main Claude Code workflow
- `stale.yml` - Manages stale issues/PRs (Mon/Wed/Fri)
- `semantic-labeler.yml` - Auto-labels issues/PRs
- `ci-failure-analysis.yml` - Analyzes CI failures
- `weekly-maintenance.yml` - Scheduled maintenance tasks
- `dependabot-auto-merge.yml` - Auto-merges dependabot PRs
- `sync-labels.yml` - Synchronizes repository labels
- `greet.yml` - Greets new contributors

## Publishing & Version Management

### Version Files

Version must be synchronized across these files on release:

- `plugins/plugin-dev/.claude-plugin/plugin.json` (source of truth)
- `.claude-plugin/marketplace.json` (metadata.version AND plugins[0].version)
- `CLAUDE.md` (Quick Reference section)

```bash
# Verify version consistency
rg '"version"' plugins/plugin-dev/.claude-plugin/plugin.json .claude-plugin/marketplace.json
rg 'Current Version.*v[0-9]' CLAUDE.md
```

### Version Release Procedure

When releasing a new version (e.g., v0.x.x), follow this procedure:

#### 1. Create Release Branch

```bash
# Ensure main is up to date
git checkout main
git pull origin main

# Create release branch
git checkout -b release/v0.x.x
```

#### 2. Update Version Numbers

Update version in **all version files** (must match):

- `plugins/plugin-dev/.claude-plugin/plugin.json` (source of truth)
- `.claude-plugin/marketplace.json` (metadata.version AND plugins[0].version)
- `CLAUDE.md` (Quick Reference section)

```bash
# Find current version to replace
rg '"version"' plugins/plugin-dev/.claude-plugin/plugin.json

# Update all version files, then verify
rg '"version"' plugins/plugin-dev/.claude-plugin/plugin.json .claude-plugin/marketplace.json
rg 'Current Version.*v[0-9]' CLAUDE.md
```

#### 3. Update Documentation

- `CHANGELOG.md` - Add release notes following Keep a Changelog format:
  1. Review commits since last release: `git log v0.x.x..HEAD --oneline`
  2. Organize into sections: Added, Changed, Fixed, Security, Performance, Documentation
  3. Group related changes and reference PR numbers
  4. Add version comparison links at bottom of file
- `README.md` - Update version references if applicable
- Any other relevant documentation

#### 4. Test and Validate

```bash
# Lint markdown files
markdownlint '**/*.md' --ignore node_modules

# Verify version consistency
rg '"version"' plugins/plugin-dev/.claude-plugin/plugin.json .claude-plugin/marketplace.json
rg 'Current Version.*v[0-9]' CLAUDE.md

# Load plugin locally and test
cc --plugin-dir plugins/plugin-dev

# Test skills load correctly by asking trigger questions
# Test workflow commands: /plugin-dev:create-plugin, /plugin-dev:create-marketplace
# Test agents trigger appropriately
```

#### 5. Commit and Create PR

```bash
# Commit version bump and documentation updates
git add .
git commit -m "chore: prepare release v0.x.x"

# Push release branch
git push origin release/v0.x.x

# Create pull request
gh pr create --title "chore: prepare release v0.x.x" \
  --body "Version bump to v0.x.x

## Changes
- [List major changes]
- [List bug fixes]
- [List documentation updates]

## Checklist
- [x] Version updated in plugin.json, marketplace.json, CLAUDE.md
- [x] CHANGELOG.md updated with release notes
- [x] Markdownlint passes
- [x] Plugin tested locally
"
```

#### 6. Merge and Create Release

After PR review and approval:

```bash
# Merge PR via GitHub UI or:
gh pr merge --squash  # or --merge or --rebase based on preference

# Create GitHub Release (this also creates the tag atomically)
gh release create v0.x.x \
  --target main \
  --title "v0.x.x" \
  --notes-file - <<'EOF'
## Summary

Brief description of the release focus.

## What's Changed

[Copy relevant sections from CHANGELOG.md]

**Full Changelog**: https://github.com/sjnims/plugin-dev/compare/v0.x-1.x...v0.x.x
EOF
```

**Note**: Main branch is protected and requires PRs. All version bumps must go through the release branch workflow. The `--target main` flag ensures the tag is created on the correct commit.

**Publishing**: The entire repository acts as a marketplace. The `plugins/plugin-dev/` directory is the distributable plugin unit.
