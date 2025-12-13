# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [0.2.1] - 2025-12-13

### Security

- **Harden validation scripts against bypass attacks** - Improved input validation and escaping in hook validation scripts (#164)
- **Prevent command injection in test-hook.sh** - Fixed potential command injection vulnerability (#148)
- **Use jq for safe JSON output** - Replaced echo with jq for proper JSON escaping in example hooks (#149)
- **Document security scope and trust model** - Added comprehensive security documentation for workflow commands (#165)

### Fixed

- **Workflow reliability improvements** - Enhanced workflow security, reliability, and documentation
- **Remove deprecated mode parameter** - Fixed claude-pr-review workflow by removing deprecated mode parameter (#171)
- **Shellcheck SC1087 errors** - Resolved array expansion errors in validate-hook-schema.sh (#168)
- **Replace unofficial `cc` alias** - Updated to use official `claude` CLI command
- **Issue and PR template improvements** - Fixed UX issues, restored spacing, removed unsupported fields
- **Labels configuration** - Corrected labels.yml and LABELS.md issues
- **Dependabot configuration** - Improved grouping and accountability settings
- **Suppress grep stderr** - Fixed noisy output in test-agent-trigger.sh (#150)

### Changed

- **Use ERE instead of BRE** - Refactored grep patterns to use Extended Regular Expressions for clarity (#159)

### Documentation

- **Comprehensive documentation improvements** - Major updates across README, CLAUDE.md, and skill documentation
- **Discussion templates** - Improved UX with plugin-specific fields
- **Prerequisites section** - Added utility script dependency documentation (#157)
- **Shellcheck guidance** - Added linting instructions to CONTRIBUTING.md (#160)
- **Secure mktemp pattern** - Documented secure temporary file handling (#158)
- **[BANG] workaround** - Documented security workaround for Claude Code #12781 (#156)

### Dependencies

- Bump anthropics/claude-code-action (#170)
- Bump EndBug/label-sync (#169)
- Update GitHub Actions to latest versions
- Remove deprecated sync-labels.sh script

## [0.2.0] - 2025-12-12

### Added

- **`/plugin-dev:start` command** - New primary entry point that guides users to choose between creating a plugin or marketplace (#145)
  - Uses `disable-model-invocation: true` to route cleanly to specialized workflows
  - Recommends plugin creation for most users

### Fixed

- Enable router invocation of workflow commands - workflow commands can now be invoked by other commands (#145)
- Replace `!` with `[BANG]` placeholder in skill documentation to prevent shell interpretation issues (#142)

### Documentation

- Fix component counts and update documentation accuracy across README, CONTRIBUTING, CLAUDE.md, and marketplace.json

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

[Unreleased]: https://github.com/sjnims/plugin-dev/compare/v0.2.1...HEAD
[0.2.1]: https://github.com/sjnims/plugin-dev/compare/v0.2.0...v0.2.1
[0.2.0]: https://github.com/sjnims/plugin-dev/compare/v0.1.0...v0.2.0
[0.1.0]: https://github.com/sjnims/plugin-dev/releases/tag/v0.1.0
