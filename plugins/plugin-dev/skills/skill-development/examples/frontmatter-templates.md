# Frontmatter Templates

Copy-paste ready YAML frontmatter templates for common skill patterns.

## Basic Skill

The minimal required frontmatter:

```yaml
---
name: skill-name
description: This skill should be used when the user asks to "do X", "perform Y", or needs guidance on Z.
---
```

**Requirements:**

- `name`: kebab-case, matches directory name
- `description`: Third-person, starts with "This skill should be used when..."

## Skill with Strong Triggers

Multiple specific trigger phrases for better activation:

```yaml
---
name: database-migrations
description: This skill should be used when the user asks to "create a migration", "run migrations", "rollback migration", "migration status", "schema changes", "alter table", "add column", "database versioning", or needs guidance on database migration patterns, schema evolution, or migration best practices.
---
```

**Best practices:**

- Include 5-10 specific trigger phrases
- Use phrases users actually say (quoted)
- Cover variations ("create a migration", "write migration", "new migration")
- Include related concepts ("schema changes", "alter table")

## Read-Only Skill

Restrict to read-only tools for safe exploration:

```yaml
---
name: codebase-analyzer
description: This skill should be used when the user asks to "analyze codebase", "find patterns", "code quality report", "architecture overview", "dependency analysis", or needs guidance on understanding existing code structure.
allowed-tools: Read, Grep, Glob, Task
---
```

**Use cases:**

- Code analysis and exploration
- Documentation generation
- Security audits
- Dependency reviews

## Multi-Domain Skill

Skill covering related sub-topics:

```yaml
---
name: aws-infrastructure
description: This skill should be used when the user asks to "deploy to AWS", "configure S3", "set up Lambda", "create EC2 instance", "configure IAM", "CloudFormation template", "AWS CDK", "Terraform for AWS", or needs guidance on AWS services, infrastructure as code, or cloud deployment patterns.
---
```

**Organization tip:** Use references/ subdirectories for sub-topics:

```text
references/
├── compute/
│   ├── ec2.md
│   └── lambda.md
├── storage/
│   └── s3.md
└── iam/
    └── policies.md
```

## Security-Focused Skill

Restricted tools for sensitive operations:

```yaml
---
name: secrets-manager
description: This skill should be used when the user asks to "manage secrets", "rotate credentials", "environment variables", "secure configuration", "vault integration", or needs guidance on secrets management patterns.
allowed-tools: Read, Grep, AskUserQuestion
---
```

**Security considerations:**

- Exclude Write, Edit, Bash to prevent accidental exposure
- Include AskUserQuestion for confirmation flows
- Document why restrictions exist in SKILL.md

## Plugin-Specific Skill

Skill designed for a specific plugin context:

```yaml
---
name: plugin-testing
description: This skill should be used when the user asks to "test plugin", "validate plugin", "plugin integration tests", "test commands", "test hooks", "test agents", or needs guidance on testing Claude Code plugin components.
---
```

**Plugin context:**

- Reference plugin-specific paths with `${CLAUDE_PLUGIN_ROOT}`
- Assume plugin structure exists
- Cross-reference other plugin skills

## Frontmatter Field Reference

| Field | Required | Type | Description |
|-------|----------|------|-------------|
| `name` | Yes | string | Skill identifier (kebab-case) |
| `description` | Yes | string | When to use (third-person) |
| `allowed-tools` | No | string | Comma-separated tool names |

## Common Mistakes

### Wrong: Second-person description

```yaml
# DON'T
description: Use this skill when you want to create migrations.
```

### Right: Third-person description

```yaml
# DO
description: This skill should be used when the user asks to "create migrations"...
```

### Wrong: Vague triggers

```yaml
# DON'T
description: This skill should be used for database stuff.
```

### Right: Specific triggers

```yaml
# DO
description: This skill should be used when the user asks to "create a migration", "run migrations", "rollback migration"...
```

### Wrong: Missing quotes around phrases

```yaml
# DON'T
description: This skill should be used when the user asks to create a migration...
```

### Right: Quoted trigger phrases

```yaml
# DO
description: This skill should be used when the user asks to "create a migration"...
```
