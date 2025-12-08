# Minimal Skill Example

A bare-bones skill with just a SKILL.md file.

## Directory Structure

```text
git-conventions/
└── SKILL.md
```

## File Contents

### SKILL.md

```markdown
---
name: git-conventions
description: This skill should be used when the user asks about "git commit message format", "conventional commits", "commit conventions", "branch naming", or needs guidance on git workflow standards.
---

# Git Conventions

This skill provides guidance on git commit messages and branch naming conventions.

## Commit Message Format

Follow the Conventional Commits specification:

```text
<type>(<scope>): <description>

[optional body]

[optional footer(s)]
```

### Types

- **feat**: New feature
- **fix**: Bug fix
- **docs**: Documentation changes
- **style**: Code style changes (formatting, semicolons)
- **refactor**: Code refactoring without behavior change
- **test**: Adding or updating tests
- **chore**: Maintenance tasks

### Examples

```text
feat(auth): add OAuth2 login support

fix(api): handle null response from external service

docs(readme): update installation instructions
```

## Branch Naming

Use descriptive prefixes:

- `feature/` - New features
- `fix/` - Bug fixes
- `docs/` - Documentation updates
- `chore/` - Maintenance tasks

### Examples

```text
feature/user-authentication
fix/null-pointer-exception
docs/api-reference
```
```

## Usage

After installing the plugin containing this skill:

```text
$ claude
> What format should I use for commit messages?

[Skill loads and provides Conventional Commits guidance]
```

## Key Points

1. **Single file**: Only SKILL.md required
2. **Strong triggers**: Description includes specific phrases users would say
3. **Third-person description**: "This skill should be used when..."
4. **Imperative body**: Instructions use "Follow...", "Use...", not "You should..."
5. **Focused content**: ~300 words, no external resources needed

## When to Use This Pattern

- Simple domain knowledge
- Quick reference guides
- Team conventions and standards
- Single-topic utilities
- Learning skill development

## Extending This Skill

To add more functionality:

1. **Add references**: Create `references/` for detailed documentation
2. **Add examples**: Create `examples/` for working code samples
3. **Add scripts**: Create `scripts/` for automation utilities
