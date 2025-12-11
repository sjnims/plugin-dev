# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [0.1.0] - 2025-12-11

### Added

- **Initial release** of Plugin Development Toolkit for Claude Code

#### Core Plugin Features

- **8 specialized skills** with progressive disclosure architecture:
  - `hook-development` - Event-driven automation with prompt-based hooks
  - `mcp-integration` - Model Context Protocol server configuration
  - `plugin-structure` - Directory layout and manifest configuration
  - `plugin-settings` - Configuration via .claude/plugin-name.local.md files
  - `command-development` - Slash commands with frontmatter
  - `agent-development` - Autonomous agents with AI-assisted generation
  - `skill-development` - Creating skills with progressive disclosure
  - `marketplace-structure` - Plugin marketplace creation and distribution

- **3 validation agents** for automated quality assurance:
  - `plugin-validator` - Validates entire plugin structure and marketplace.json
  - `skill-reviewer` - Reviews skill quality, triggering reliability, and best practices
  - `agent-creator` - Generates new agents from natural language descriptions

- **2 guided workflow commands**:
  - `/plugin-dev:create-plugin` - 8-phase guided workflow for plugin creation
  - `/plugin-dev:create-marketplace` - 8-phase guided workflow for marketplace creation

#### Utility Scripts

- **Agent development scripts**:
  - `create-agent-skeleton.sh` - Create new agent skeleton files
  - `validate-agent.sh` - Validate agent frontmatter and structure
  - `test-agent-trigger.sh` - Test agent trigger phrase matching

- **Command development scripts**:
  - `validate-command.sh` - Validate command structure
  - `check-frontmatter.sh` - Check frontmatter field validity

- **Hook development scripts**:
  - `validate-hook-schema.sh` - Validate hooks.json schema
  - `test-hook.sh` - Test hooks with sample input
  - `hook-linter.sh` - Lint hook shell scripts

- **Plugin settings scripts**:
  - `validate-settings.sh` - Validate settings file structure
  - `parse-frontmatter.sh` - Parse YAML frontmatter from settings

#### CI/CD Workflows

- **PR validation workflows** (6 workflows):
  - `markdownlint.yml` - Markdown style enforcement
  - `links.yml` - Link validation with lychee
  - `component-validation.yml` - Plugin component validation
  - `version-check.yml` - Version consistency across manifests
  - `validate-workflows.yml` - GitHub Actions workflow validation
  - `claude-pr-review.yml` - AI-powered code review

- **Automation workflows** (8 workflows):
  - `claude.yml` - Main Claude Code workflow
  - `stale.yml` - Stale issue/PR management
  - `semantic-labeler.yml` - Automatic PR/issue labeling
  - `ci-failure-analysis.yml` - CI failure analysis
  - `weekly-maintenance.yml` - Scheduled maintenance tasks
  - `dependabot-auto-merge.yml` - Dependabot PR auto-merge
  - `sync-labels.yml` - Repository label synchronization
  - `greet.yml` - New contributor welcome messages

#### Documentation

- **User documentation**:
  - `README.md` - Comprehensive user guide with installation, usage examples, and best practices
  - `CONTRIBUTING.md` - Contributor guidelines and development setup
  - `SECURITY.md` - Security policy and vulnerability reporting
  - `CODE_OF_CONDUCT.md` - Community standards and expectations

- **Developer documentation**:
  - `CLAUDE.md` - Architecture, patterns, and development guide
  - Skill-specific references and examples in each skill directory

#### Repository Infrastructure

- **Issue templates** (4 types):
  - Bug report with reproduction steps
  - Feature request with use cases
  - Documentation improvements
  - Questions and discussions

- **Pull request template** with component-specific checklists

- **Label system** with categories:
  - Component labels (agent, command, skill, hook, docs)
  - Priority labels (critical, high, medium, low)
  - Status labels (blocked, in-progress, needs-review)
  - Effort labels (small, medium, large)

- **Dependabot** configured for GitHub Actions updates

#### Attribution

- Based on original plugin by Daisy Hollman at Anthropic
- Expanded with enhanced skills, additional utilities, and CI/CD infrastructure

[Unreleased]: https://github.com/sjnims/plugin-dev/compare/v0.1.0...HEAD
[0.1.0]: https://github.com/sjnims/plugin-dev/releases/tag/v0.1.0
