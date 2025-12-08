# SlashCommand Tool Reference

How Claude programmatically invokes slash commands during conversations.

## Overview

The SlashCommand tool enables Claude to programmatically execute slash commands without user typing. This allows Claude to autonomously invoke commands as part of complex workflows, chain commands together, or use commands in response to user requests.

**Key concepts:**

- Claude can invoke commands via the SlashCommand tool
- Commands need `description` frontmatter to be visible
- Permission rules control which commands Claude can invoke
- Character budget limits how many commands Claude "sees"
- `disable-model-invocation` prevents programmatic invocation

## How the SlashCommand Tool Works

### What It Does

When Claude determines a slash command would help accomplish a task, it uses the SlashCommand tool to invoke that command. The tool:

1. Identifies available commands based on permission rules
2. Selects appropriate command for the task
3. Executes the command with any arguments
4. Processes the command output

### When Claude Uses It

Claude uses the SlashCommand tool when:

- A command directly addresses the user's request
- Multiple steps require command chaining
- Automated workflows need command execution
- User asks Claude to "run /command" or similar

**Example:** If a user says "review my code changes," Claude might use the SlashCommand tool to invoke `/review` if such a command exists and is available.

## Visibility Requirements

### description Field Required

Commands **must** have a `description` frontmatter field to be visible to the SlashCommand tool.

**Visible to SlashCommand tool:**

```yaml
---
description: Review code for security issues
---
```

**NOT visible to SlashCommand tool:**

```markdown
# No frontmatter - command only available via manual invocation

Review this code for security vulnerabilities...
```

**Why this requirement:**

- Claude uses descriptions to understand what commands do
- Descriptions help Claude select the right command
- Forces documentation of command purpose
- Prevents accidental programmatic invocation of undocumented commands

### Best Practices for Descriptions

Write descriptions that help Claude understand when to use the command:

**Good descriptions:**

```yaml
description: Review PR for code quality and security  # Clear purpose
description: Deploy application to staging environment  # Specific action
description: Run test suite and report failures  # Expected outcome
```

**Poor descriptions:**

```yaml
description: Review  # Too vague - Claude can't determine when to use
description: Does stuff  # Unhelpful - doesn't describe purpose
description: A command  # Obvious - provides no information
```

## Character Budget

### Default Budget

The SlashCommand tool has a character budget limiting how many command descriptions Claude receives. The default budget is **15,000 characters**.

### How Budget Works

1. Commands are sorted by priority (project, then user, then plugin)
2. Command descriptions are added until budget exhausted
3. Commands exceeding budget are not visible to Claude
4. More concise descriptions = more commands visible

### Configuring Budget

Set the `SLASH_COMMAND_TOOL_CHAR_BUDGET` environment variable to adjust:

```bash
# Increase budget to show more commands
export SLASH_COMMAND_TOOL_CHAR_BUDGET=30000

# Decrease budget for faster processing
export SLASH_COMMAND_TOOL_CHAR_BUDGET=8000
```

### Budget Optimization

**Keep descriptions concise:**

```yaml
# Good - concise (35 chars)
description: Review PR for security issues

# Bad - verbose (89 chars)
description: This command reviews pull requests for potential security vulnerabilities and issues
```

**Prioritize important commands:**

- Project commands appear before user commands
- Keep critical commands in project scope
- Move rarely-used commands to user scope

## Permission Rules

### Overview

Permission rules control which commands Claude can invoke via the SlashCommand tool. Rules are configured in Claude Code settings.

### Rule Patterns

**Exact match:**

```
SlashCommand:/commit  # Only /commit command
SlashCommand:/deploy  # Only /deploy command
```

**Prefix match (wildcards):**

```
SlashCommand:/review-pr:*  # All commands starting with /review-pr
SlashCommand:/git:*        # All commands starting with /git
SlashCommand:/plugin-name:*  # All commands from specific plugin
```

**Deny all:**

Add `SlashCommand` to deny rules to prevent all programmatic command invocation.

### Configuration Examples

**Allow specific commands:**

```json
{
  "allow": [
    "SlashCommand:/review",
    "SlashCommand:/test:*"
  ]
}
```

**Deny dangerous commands:**

```json
{
  "deny": [
    "SlashCommand:/deploy-prod",
    "SlashCommand:/delete:*"
  ]
}
```

**Deny all programmatic invocation:**

```json
{
  "deny": ["SlashCommand"]
}
```

### Permission Precedence

1. Explicit deny rules take precedence
2. Explicit allow rules override defaults
3. Default behavior allows programmatic invocation
4. `disable-model-invocation` in command frontmatter always blocks

## disable-model-invocation Field

### Purpose

The `disable-model-invocation` frontmatter field prevents Claude from programmatically invoking a command, regardless of permission rules.

```yaml
---
description: Approve production deployment
disable-model-invocation: true
---
```

### When to Use

**Manual-only commands:**

```yaml
---
description: Approve production deployment
disable-model-invocation: true
---

# Production Deployment Approval

This deployment requires human judgment and sign-off.
Verify all checks have passed before approving.
```

**Destructive operations:**

```yaml
---
description: Delete all test data
disable-model-invocation: true
---

# Test Data Deletion

WARNING: This permanently deletes all test data.
This operation cannot be undone.
```

**Interactive workflows:**

```yaml
---
description: Setup wizard for new project
disable-model-invocation: true
---

# Project Setup Wizard

This wizard requires interactive user input at each step.
```

### How It Differs from Permission Rules

| Aspect | disable-model-invocation | Permission Rules |
|--------|-------------------------|------------------|
| Scope | Single command | Global/pattern-based |
| Location | Command frontmatter | Settings file |
| Override | Cannot be overridden | Can be adjusted |
| Use case | Command-specific restriction | Policy enforcement |

**Use `disable-model-invocation` when:**

- Command should NEVER be programmatically invoked
- Restriction is inherent to command purpose
- Decision made by command author

**Use permission rules when:**

- Organization policy restricts certain patterns
- User wants to control Claude's autonomy
- Temporary or adjustable restrictions needed

## Integration Patterns

### Commands Designed for Programmatic Use

Some commands work well when invoked by Claude:

```yaml
---
description: Get current git status summary
allowed-tools: Bash(git:*)
---

# Git Status

Branch: `git branch --show-current`
Status: `git status --short`
Recent: `git log -3 --oneline`
```

This command:

- Has clear, specific description
- Produces useful output for Claude
- No destructive operations
- Quick execution

### Commands for Manual-Only Use

Some commands should remain manual:

```yaml
---
description: Force push to protected branch (DANGEROUS)
disable-model-invocation: true
allowed-tools: Bash(git:*)
---

# Force Push

WARNING: This will overwrite remote history.

Are you absolutely sure? Type the branch name to confirm: $1
```

This command:

- Uses `disable-model-invocation: true`
- Has clear warning in description
- Requires explicit confirmation
- Documents danger level

### Workflow Commands

Commands that chain others should consider visibility:

```yaml
---
description: Complete release workflow
---

# Release Workflow

Execute the following steps:
1. Run tests via /test
2. Update version via /version-bump $1
3. Create changelog via /changelog
4. Tag release via /tag-release $1

Verify each step before proceeding.
```

If sub-commands have `disable-model-invocation: true`, this workflow command will need user interaction at those steps.

## Troubleshooting

### Command Not Available to Claude

**Check description field:**

```yaml
---
description: Must have description  # Required for visibility
---
```

**Check character budget:**

- Too many commands may exceed budget
- Shorten descriptions or increase budget
- Check if command appears with `SLASH_COMMAND_TOOL_CHAR_BUDGET=100000`

**Check permission rules:**

- Verify no deny rules match the command
- Check if allow rules are too restrictive

### Claude Won't Invoke Command

**Check disable-model-invocation:**

```yaml
disable-model-invocation: true  # Blocks programmatic invocation
```

**Check permission rules:**

- Look for deny patterns matching command
- Verify SlashCommand not in global deny list

### Too Many Commands Visible

**Reduce character budget:**

```bash
export SLASH_COMMAND_TOOL_CHAR_BUDGET=8000
```

**Shorten descriptions:**

- Keep under 60 characters
- Remove redundant words
- Focus on key purpose

**Use disable-model-invocation:**

- Add to commands that shouldn't be auto-invoked
- Keep only essential commands visible

## Best Practices

### For Command Authors

1. **Always include description** - Required for visibility
2. **Keep descriptions concise** - Respect character budget
3. **Use `disable-model-invocation` thoughtfully** - Only when truly needed
4. **Document dangerous commands** - Make risks clear in description
5. **Design for both uses** - Commands should work manually and programmatically

### For Users/Organizations

1. **Set appropriate permission rules** - Balance autonomy and safety
2. **Adjust character budget** - Based on command volume
3. **Review command descriptions** - Ensure Claude can understand them
4. **Test programmatic invocation** - Verify commands work as expected
5. **Monitor command usage** - Track which commands Claude invokes
