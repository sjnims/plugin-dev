# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

This repository is a **plugin marketplace** containing the **plugin-dev** plugin - a comprehensive toolkit for developing Claude Code plugins. It provides 8 specialized skills, 3 agents, and 2 guided workflow commands for building high-quality plugins and marketplaces.

## Quick Reference

**Current Version**: v0.1.0 (synced in `plugin.json`, `marketplace.json`, and this file)

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
- `tools`: Array of allowed tools (optional)

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
- `allowed-tools`: Optional array of permitted tools (restricts tool access)

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
