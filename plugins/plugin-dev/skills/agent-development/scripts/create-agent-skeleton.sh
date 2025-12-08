#!/bin/bash
# Agent Skeleton Generator
# Creates a new agent file with correct structure

set -euo pipefail

# Usage
if [ $# -eq 0 ]; then
  echo "Usage: $0 <agent-name> [output-dir]"
  echo ""
  echo "Creates a skeleton agent file with:"
  echo "  - Valid YAML frontmatter"
  echo "  - Placeholder description with example block"
  echo "  - Basic system prompt structure"
  echo ""
  echo "Arguments:"
  echo "  agent-name   Agent identifier (lowercase, numbers, hyphens)"
  echo "  output-dir   Directory to create file in (default: current directory)"
  echo ""
  echo "Examples:"
  echo "  $0 code-reviewer agents/"
  echo "  $0 test-generator"
  echo ""
  echo "After creation:"
  echo "  1. Edit the file to fill in placeholders"
  echo "  2. Add 2-4 triggering examples"
  echo "  3. Write detailed system prompt"
  echo "  4. Validate: ./scripts/validate-agent.sh <output-file>"
  echo "  5. Test triggers: ./scripts/test-agent-trigger.sh <output-file>"
  exit 1
fi

AGENT_NAME="$1"
OUTPUT_DIR="${2:-.}"
OUTPUT_FILE="$OUTPUT_DIR/$AGENT_NAME.md"

echo "🔍 Creating agent skeleton: $AGENT_NAME"
echo ""

# Validate name format (lowercase alphanumeric + hyphens, 3-50 chars)
if ! [[ "$AGENT_NAME" =~ ^[a-z0-9][a-z0-9-]*[a-z0-9]$ ]]; then
  echo "❌ Invalid name: $AGENT_NAME"
  echo ""
  echo "Agent names must:"
  echo "  - Start with a lowercase letter or number"
  echo "  - End with a lowercase letter or number"
  echo "  - Contain only lowercase letters, numbers, and hyphens"
  echo "  - Be at least 3 characters long"
  echo ""
  echo "Valid examples: code-reviewer, test-gen, my-agent-123"
  echo "Invalid examples: Code-Reviewer, -agent, agent-, a"
  exit 1
fi
echo "✅ Name format valid"

# Validate name length
name_length=${#AGENT_NAME}
if [ "$name_length" -lt 3 ]; then
  echo "❌ Name too short: $name_length characters (minimum 3)"
  exit 1
fi
if [ "$name_length" -gt 50 ]; then
  echo "❌ Name too long: $name_length characters (maximum 50)"
  exit 1
fi
echo "✅ Name length valid ($name_length characters)"

# Check output directory exists
if [ ! -d "$OUTPUT_DIR" ]; then
  echo "❌ Directory does not exist: $OUTPUT_DIR"
  echo ""
  echo "Create it first with: mkdir -p $OUTPUT_DIR"
  exit 1
fi
echo "✅ Output directory exists"

# Check file doesn't already exist
if [ -f "$OUTPUT_FILE" ]; then
  echo "❌ File already exists: $OUTPUT_FILE"
  echo ""
  echo "Options:"
  echo "  - Choose a different name"
  echo "  - Delete the existing file: rm $OUTPUT_FILE"
  echo "  - Edit the existing file directly"
  exit 1
fi
echo "✅ Output path available"

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📝 Creating agent file..."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Create the agent skeleton file
cat > "$OUTPUT_FILE" << EOF
---
name: $AGENT_NAME
description: Use this agent when [describe triggering conditions]. Examples:

<example>
Context: [Describe the situation]
user: "[What the user says]"
assistant: "[How Claude responds before triggering]"
<commentary>
[Why this agent should trigger]
</commentary>
assistant: "I'll use the $AGENT_NAME agent to [action]."
</example>

<example>
Context: [Second example situation]
user: "[Another user request]"
assistant: "[Claude's response]"
<commentary>
[Explanation of why this triggers the agent]
</commentary>
</example>

model: inherit
color: blue
---

You are [describe the agent's role and expertise].

**Your Core Responsibilities:**

1. [Primary responsibility]
2. [Secondary responsibility]
3. [Additional responsibility]

**Process:**

1. [First step]
2. [Second step]
3. [Third step]

**Quality Standards:**

- [Standard 1]
- [Standard 2]
- [Standard 3]

**Output Format:**

Provide results as:

- [What to include]
- [How to structure]
EOF

echo "✅ Created agent skeleton: $OUTPUT_FILE"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📋 Next Steps"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "1. Edit the file to fill in placeholders:"
echo "   - Replace [bracketed text] with actual content"
echo "   - Update description to explain when agent triggers"
echo "   - Write 2-4 triggering examples"
echo "   - Develop detailed system prompt"
echo ""
echo "2. Choose appropriate settings:"
echo "   - model: inherit (default), sonnet, opus, or haiku"
echo "   - color: blue (default), cyan, green, yellow, magenta, or red"
echo "   - tools: Add array if restricting tools (optional)"
echo ""
echo "3. Validate the agent:"
echo "   ./scripts/validate-agent.sh $OUTPUT_FILE"
echo ""
echo "4. Test triggering:"
echo "   ./scripts/test-agent-trigger.sh $OUTPUT_FILE"
echo ""
echo "5. Load in Claude Code:"
echo "   cc --plugin-dir /path/to/plugin"
