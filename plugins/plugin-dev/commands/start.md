---
description: Start plugin development - choose your path
argument-hint: [description]
allowed-tools: AskUserQuestion, SlashCommand, TodoWrite
model: sonnet
disable-model-invocation: true
---

# Plugin Development Entry Point

Welcome the user and help them choose the right path for their plugin development journey.

## Your Task

Present the user with a clear choice between two development paths, explain when each is appropriate, then route them to the correct workflow.

## Step 1: Handle Arguments

If the user provided arguments ($ARGUMENTS is not empty):

- Analyze the arguments to see if intent is already clear
- If arguments clearly indicate a plugin (e.g., "database migration tool"), suggest plugin path
- If arguments clearly indicate a marketplace (e.g., "team collection", "distribute our plugins"), suggest marketplace path
- Still ask for confirmation before routing

**Initial request:** $ARGUMENTS

## Step 2: Provide Context

Before presenting the question, briefly explain:

```text
Welcome to the Plugin Development Toolkit!

I'll help you get started. First, let me explain your options:

**Plugin** → A self-contained extension that adds functionality to Claude Code
- Contains skills (knowledge), commands (actions), agents (automation), hooks (events), or MCP servers (integrations)
- Example: "A plugin for managing database migrations"
- This is what most developers want to create

**Marketplace** → A collection that organizes and distributes multiple plugins
- Contains references to one or more plugins (local or remote)
- Example: "A marketplace for our team's internal tools"
- Choose this if you already have plugins to organize, or want to plan a collection upfront
```

## Step 3: Ask User Question

Use the AskUserQuestion tool with these parameters:

- **header**: "Create"
- **question**: "What would you like to create?"
- **multiSelect**: false
- **options**: (defined below)

**Options**:

Option 1:

- label: "A plugin (Recommended)"
- description: "Create a single plugin with skills, commands, agents, hooks, or MCP integrations. Best for: building something new, adding functionality to Claude Code, or learning plugin development."

Option 2:

- label: "A marketplace"
- description: "Create a collection to organize and distribute multiple plugins. Best for: teams sharing internal tools, publishing a curated set of plugins, or organizing existing plugins."

## Step 4: Route Based on Choice

After the user selects an option:

**If they chose "A plugin"**:

- Acknowledge their choice
- Use the SlashCommand tool to invoke `/plugin-dev:create-plugin`
- Pass through any context from $ARGUMENTS if provided

**If they chose "A marketplace"**:

- Acknowledge their choice
- Use the SlashCommand tool to invoke `/plugin-dev:create-marketplace`
- Pass through any context from $ARGUMENTS if provided

---

## Example Interactions

### Example 1: No arguments provided

```text
User: /plugin-dev:start

Claude: Welcome to the Plugin Development Toolkit!

I'll help you get started. First, let me explain your options:

**Plugin** → A self-contained extension that adds functionality to Claude Code
- Contains skills (knowledge), commands (actions), agents (automation), hooks (events), or MCP servers (integrations)
- Example: "A plugin for managing database migrations"
- This is what most developers want to create

**Marketplace** → A collection that organizes and distributes multiple plugins
- Contains references to one or more plugins (local or remote)
- Example: "A marketplace for our team's internal tools"
- Choose this if you already have plugins to organize, or want to plan a collection upfront

[Uses AskUserQuestion to present the choice]
```

### Example 2: Arguments suggest a plugin

```text
User: /plugin-dev:start a code review assistant

Claude: Welcome to the Plugin Development Toolkit!

Based on your description "a code review assistant", it sounds like you want to create a **plugin** - a self-contained extension that adds code review functionality to Claude Code.

[Uses AskUserQuestion to confirm: "Does creating a plugin sound right for your needs?"]

User: Yes

Claude: Great! Let me start the plugin creation workflow...
[Invokes /plugin-dev:create-plugin a code review assistant]
```

### Example 3: Arguments suggest a marketplace

```text
User: /plugin-dev:start organize our team's internal tools

Claude: Welcome to the Plugin Development Toolkit!

Based on your description "organize our team's internal tools", it sounds like you want to create a **marketplace** - a collection to distribute plugins to your team.

[Uses AskUserQuestion to confirm: "Does creating a marketplace sound right for your needs?"]

User: Yes

Claude: Great! Let me start the marketplace creation workflow...
[Invokes /plugin-dev:create-marketplace organize our team's internal tools]
```

---

## Important Notes

- Always present both options clearly before asking
- If arguments are provided, analyze them but still confirm before routing
- Use a friendly, welcoming tone - this is the user's first interaction
- The goal is to help users quickly get to the right workflow, not to slow them down
- If users ask questions instead of choosing, answer briefly and guide them back to the choice

---

Begin by presenting the welcome message and using AskUserQuestion to help the user choose their path.
