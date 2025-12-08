# Contributing to Plugin Dev

Thank you for your interest in contributing to the Plugin Dev toolkit for Claude Code! This document provides guidelines and instructions for contributing.

## Table of Contents

- [Code of Conduct](#code-of-conduct)
- [Getting Started](#getting-started)
- [Development Setup](#development-setup)
- [How to Contribute](#how-to-contribute)
- [Development Guidelines](#development-guidelines)
- [Component-Specific Guidelines](#component-specific-guidelines)
- [Testing](#testing)
- [Submitting Changes](#submitting-changes)
- [Style Guide](#style-guide)
- [Community](#community)

## Code of Conduct

This project adheres to the [Contributor Covenant Code of Conduct](CODE_OF_CONDUCT.md). By participating, you are expected to uphold this code. Please report unacceptable behavior to <sjnims@gmail.com>.

## Getting Started

### Prerequisites

Before contributing, ensure you have:

- **Claude Code**: Install from [claude.ai/code](https://claude.ai/code)
- **GitHub CLI** (`gh`): Installed and authenticated
  ```bash
  brew install gh  # macOS
  gh auth login
  ```
- **Git**: For version control
- **Node.js**: For markdownlint (optional but recommended)
  ```bash
  npm install -g markdownlint-cli
  ```

### Understanding the Project

1. **Read the documentation**:
   - [README.md](README.md) - User-facing documentation
   - [CLAUDE.md](CLAUDE.md) - Development documentation
   - [SECURITY.md](SECURITY.md) - Security policy

2. **Explore the architecture**:
   ```
   plugins/plugin-dev/
   ├── commands/      # 1 slash command
   ├── skills/        # 7 methodology skills
   └── agents/        # 3 specialized agents
   ```

3. **Understand the plugin components**:
   - 7 skills for different plugin development aspects
   - 3 agents for validation and generation
   - 1 guided workflow command (`/plugin-dev:create-plugin`)

## Development Setup

### 1. Fork and Clone

```bash
# Fork the repository on GitHub, then:
git clone https://github.com/YOUR-USERNAME/plugin-dev.git
cd plugin-dev
```

### 2. Set Up Remote

```bash
git remote add upstream https://github.com/sjnims/plugin-dev.git
```

### 3. Create a Branch

```bash
git checkout -b feature/your-feature-name
# or
git checkout -b fix/issue-description
```

### 4. Test the Plugin

```bash
# From repository root
cc --plugin-dir plugins/plugin-dev

# Test command in Claude Code
/plugin-dev:create-plugin
```

### 5. Verify GitHub CLI Setup

```bash
gh auth status  # Should show logged in with 'repo' and 'project' scopes
```

## How to Contribute

### Finding Something to Work On

1. **Check existing issues**: Look for issues labeled `good first issue` or `help wanted`
2. **Review the roadmap**: See what features are planned
3. **Fix bugs**: Found a bug? Open an issue first, then submit a PR
4. **Improve documentation**: Documentation improvements are always welcome
5. **Suggest features**: Open a feature request issue to discuss first

### Before You Start

- **Check for existing work**: Search issues and PRs to avoid duplicates
- **Discuss major changes**: Open an issue first for significant changes
- **One feature per PR**: Keep pull requests focused on a single feature or fix
- **Follow the architecture**: Maintain the three-layer design (Commands → Skills → Agents)

## Development Guidelines

### General Principles

1. **Simplicity First**: Don't over-engineer. Keep solutions simple and focused.
2. **Consistency**: Follow existing patterns in the codebase.
3. **No External Dependencies**: This is a pure Claude Code plugin (only GitHub CLI dependency).
4. **Documentation**: Document all user-facing changes.
5. **Testing**: Always test locally before submitting.

### File Organization

- **Commands**: `plugins/plugin-dev/commands/*.md`
- **Skills**: `plugins/plugin-dev/skills/*/SKILL.md`
- **Agents**: `plugins/plugin-dev/agents/*.md`

### Markdown Style

All markdown files must follow the repository's style:

```bash
# Lint before committing
markdownlint '**/*.md' --ignore node_modules

# Auto-fix issues
markdownlint '**/*.md' --ignore node_modules --fix
```

**Style Rules** (see `.markdownlint.json`):
- Use ATX-style headers (`#`, `##`, `###`)
- Use dash-style lists (`-`, not `*` or `+`)
- Use 2-space indentation for lists
- Use fenced code blocks (not indented)
- No line length limits
- Allowed HTML: `<p>`, `<img>`, `<example>`, `<commentary>`

## Component-Specific Guidelines

### Commands (`/plugin-dev:*`)

When creating or modifying commands:

1. **YAML Frontmatter Required**:
   ```yaml
   ---
   name: command-name
   description: Brief description
   allowed-tools: [AskUserQuestion, Bash(gh:*), Read]
   ---
   ```

2. **Imperative Form**: Write instructions FOR Claude, not TO the user
   - ✅ Good: "Do X", "Run Y", "Create Z"
   - ❌ Bad: "You should do X", "Please run Y"

3. **Error Handling**: Include error handling for:
   - GitHub CLI not found
   - Not authenticated
   - Not in git repository
   - Insufficient permissions

4. **Clear Outputs**: Provide clear success/failure messages

### Skills (Methodology Knowledge)

When creating or modifying skills:

1. **YAML Frontmatter Required**:
   ```yaml
   ---
   name: Skill Name
   description: This skill should be used when the user asks to "trigger phrase 1"...
   version: 0.1.0
   ---
   ```

2. **Description**: Use third-person with specific trigger phrases
   - ✅ Good: `This skill should be used when the user asks to "create user stories"`
   - ❌ Bad: `Use this skill to help users`

3. **Progressive Disclosure**:
   - `SKILL.md`: Core methodology (<2,000 words)
   - `references/`: Detailed documentation
   - No duplication between files

4. **Templates**: Store in `references/` subdirectory

### Agents (Autonomous Assistance)

When creating or modifying agents:

1. **YAML Frontmatter Required**:
   ```yaml
   ---
   name: agent-name
   description: Use this agent when...
   model: inherit
   color: blue
   tools: [Bash, AskUserQuestion]
   ---
   ```

2. **Trigger Examples**: Include 3-4 `<example>` blocks showing when the agent should trigger

3. **Clear System Prompt**: Be specific about the agent's role and responsibilities

4. **Minimal Tools**: Only include tools the agent actually needs

### Hooks

When creating and/or modifying hooks:

1. **Matcher Patterns**: Keep regex patterns simple and specific
2. **Timeout**: Set appropriate timeouts (default: 10 seconds)
3. **Testing**: Test thoroughly to avoid false positives

## Testing

### Local Testing Checklist

- [ ] Load plugin: `cc --plugin-dir plugins/plugin-dev`
- [ ] Test affected commands
- [ ] Verify GitHub CLI integration works
- [ ] Test in a clean repository (not your development repo)
- [ ] Test error cases (missing permissions, no git repo, etc.)

### Full Workflow Test

For significant changes, test the complete lifecycle:

```bash
/plugin-dev:create-plugin
```

### Test Repository

Create a test repository to avoid polluting your development environment:

```bash
# Create a test repo
mkdir test-requirements-repo
cd test-requirements-repo
git init
gh repo create test-requirements-repo --public --source=. --remote=origin
git push -u origin main

# Now test the plugin
cc --plugin-dir /path/to/plugin-dev/plugins/plugin-dev
```

## Submitting Changes

### 1. Update Documentation

- Update README.md if user-facing changes
- Update CLAUDE.md if architectural changes
- Update component documentation if applicable

### 2. Lint Your Code

```bash
# Lint all markdown
markdownlint '**/*.md' --ignore node_modules --fix

# Check specific files
markdownlint plugins/plugin-dev/commands/your-command.md
```

### 3. Commit Your Changes

Use clear, descriptive commit messages:

```bash
git commit -m "Add feature: description of what you added

- Bullet point of change 1
- Bullet point of change 2

Fixes #123"
```

### 4. Push to Your Fork

```bash
git push origin feature/your-feature-name
```

### 5. Create a Pull Request

1. Go to the [repository](https://github.com/sjnims/plugin-dev)
2. Click "New Pull Request"
3. Select your fork and branch
4. Fill out the PR template completely
5. Link related issues

### Pull Request Checklist

See [pull_request_template.md](.github/pull_request_template.md) for the complete checklist. Key items:

- [ ] Code follows style guidelines
- [ ] Documentation updated
- [ ] Markdown linted
- [ ] Tested locally
- [ ] Component-specific checks completed
- [ ] No breaking changes (or clearly documented)

## Style Guide

### Markdown

- **Headers**: Use ATX-style (`#`, `##`, `###`)
- **Lists**: Use dash-style (`-`)
- **Code blocks**: Use fenced blocks with language tags
- **Line length**: No limit (MD013 disabled)
- **Emphasis**: Use `**bold**` for strong, `*italic*` for emphasis

### YAML Frontmatter

- Always include required fields (`name`, `description`)
- Use consistent indentation (2 spaces)
- Use arrays for lists: `[Tool1, Tool2]`

### Commands and Instructions

- Use imperative mood: "Create", "Run", "Execute"
- Be specific: "Run `gh project create`" not "Create a project"
- Include error handling
- Provide clear outputs

### Git Commit Messages

- First line: Brief summary (50 chars max)
- Blank line
- Detailed description (wrap at 72 chars)
- Reference issues: `Fixes #123`, `Closes #456`

## Community

### Getting Help

- **Questions**: Open an issue with the [question template](https://github.com/sjnims/plugin-dev/issues/new?template=question.yml)
- **Discussions**: Use [GitHub Discussions](https://github.com/sjnims/plugin-dev/discussions)

### Reporting Issues

- **Bugs**: Use the [bug report template](https://github.com/sjnims/plugin-dev/issues/new?template=bug_report.yml)
- **Features**: Use the [feature request template](https://github.com/sjnims/plugin-dev/issues/new?template=feature_request.yml)
- **Documentation**: Use the [documentation template](https://github.com/sjnims/plugin-dev/issues/new?template=documentation.yml)
- **Security**: See [SECURITY.md](SECURITY.md)

### Code Review Process

1. **Automated Checks**: PR must pass all checks
2. **Review**: At least one maintainer review required
3. **Feedback**: Address review comments
4. **Approval**: Maintainer approves PR
5. **Merge**: Maintainer merges (usually squash merge)

### Recognition

Contributors are recognized in:
- Release notes
- README.md (for significant contributions)
- Git commit history

## Questions?

If you have questions not covered here:

1. Check [CLAUDE.md](CLAUDE.md) for development details
2. Search [existing issues](https://github.com/sjnims/plugin-dev/issues)
3. Open a [question issue](https://github.com/sjnims/plugin-dev/issues/new?template=question.yml)
4. Start a [discussion](https://github.com/sjnims/plugin-dev/discussions)

---

**Thank you for contributing to Plugin Dev!** Your contributions help make plugin development better for everyone using Claude Code.
