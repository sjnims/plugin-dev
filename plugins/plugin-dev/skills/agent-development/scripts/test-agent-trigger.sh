#!/bin/bash
# Agent Trigger Test Helper
# Extracts triggering examples and validates example block formatting

set -euo pipefail

# Usage
if [ $# -eq 0 ]; then
  echo "Usage: $0 <path/to/agent.md>"
  echo ""
  echo "This script helps test agent triggering by:"
  echo "  - Extracting <example> blocks from description"
  echo "  - Parsing user phrases that should trigger the agent"
  echo "  - Validating example block formatting"
  echo "  - Providing manual testing guidance"
  exit 1
fi

AGENT_FILE="$1"

echo "🔍 Analyzing agent triggers: $AGENT_FILE"
echo ""

# Check file exists
if [ ! -f "$AGENT_FILE" ]; then
  echo "❌ File not found: $AGENT_FILE"
  exit 1
fi

# Check frontmatter exists
FIRST_LINE=$(head -1 "$AGENT_FILE")
if [ "$FIRST_LINE" != "---" ]; then
  echo "❌ File must start with YAML frontmatter (---)"
  exit 1
fi

# Extract agent name
NAME=$(sed -n '/^---$/,/^---$/p' "$AGENT_FILE" | grep '^name:' | sed 's/name: *//' | sed 's/^"\(.*\)"$/\1/' | head -1)

if [ -z "$NAME" ]; then
  echo "❌ Could not extract agent name"
  exit 1
fi

echo "📋 Agent: $NAME"
echo ""

# Extract full frontmatter section
FRONTMATTER=$(awk '
  /^---$/ { count++; next }
  count == 1 { print }
' "$AGENT_FILE")

# Extract description - handles multi-line YAML
# Description ends when we hit another top-level field (model:, color:, tools:, etc.)
DESCRIPTION=$(echo "$FRONTMATTER" | awk '
  /^description:/ {
    in_desc = 1
    sub(/^description: */, "")
    if ($0 != "") print
    next
  }
  in_desc && /^(model|color|tools|name):/ { exit }
  in_desc { print }
')

if [ -z "$DESCRIPTION" ]; then
  echo "❌ Could not extract description"
  exit 1
fi

# Count example blocks
EXAMPLE_COUNT=$(echo "$DESCRIPTION" | grep -c '<example>' || echo 0)

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📊 EXAMPLE ANALYSIS"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

if [ "$EXAMPLE_COUNT" -eq 0 ]; then
  echo "⚠️  No <example> blocks found in description"
  echo ""
  echo "Agent descriptions should include 2-4 example blocks showing"
  echo "when the agent should be triggered."
  echo ""
  echo "Example format:"
  echo "  <example>"
  echo "  Context: [Scenario description]"
  echo '  user: "[User request]"'
  echo '  assistant: "[How Claude responds]"'
  echo "  <commentary>"
  echo "  [Why this triggers the agent]"
  echo "  </commentary>"
  echo "  </example>"
  exit 1
fi

echo "Found $EXAMPLE_COUNT example block(s)"
echo ""

# Extract and display each example
# Use awk to extract example blocks
echo "$DESCRIPTION" | awk '
  /<example>/ { in_example=1; example=""; next }
  /<\/example>/ {
    in_example=0
    example_num++
    print "───────────────────────────────────────"
    print "Example " example_num ":"
    print "───────────────────────────────────────"
    print example
    print ""
    next
  }
  in_example { example = example $0 "\n" }
' | while IFS= read -r line; do
  echo "$line"
done

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🎯 TRIGGER PHRASES"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Initialize warning counter early (used across sections)
warning_count=0

# Extract user phrases from examples
USER_PHRASES=$(echo "$DESCRIPTION" | grep -oE 'user: *"[^"]*"' | sed 's/user: *"//' | sed 's/"$//' || true)

if [ -z "$USER_PHRASES" ]; then
  echo "⚠️  Could not extract user phrases from examples"
  echo ""
  echo "Make sure examples include 'user: \"phrase\"' format"
  ((warning_count++))
else
  echo "Use these phrases to test agent triggering:"
  echo ""
  echo "$USER_PHRASES" | while IFS= read -r phrase; do
    echo "  → $phrase"
  done
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✅ VALIDATION"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Check for "Use this agent when" pattern
if ! echo "$DESCRIPTION" | grep -qi 'use this agent when'; then
  echo "⚠️  Description should start with 'Use this agent when...'"
  ((warning_count++))
else
  echo "✅ Has 'Use this agent when' pattern"
fi

# Check example count
if [ "$EXAMPLE_COUNT" -lt 2 ]; then
  echo "⚠️  Only $EXAMPLE_COUNT example(s) - recommend 2-4 examples"
  ((warning_count++))
elif [ "$EXAMPLE_COUNT" -gt 4 ]; then
  echo "⚠️  $EXAMPLE_COUNT examples - consider trimming to 2-4"
  ((warning_count++))
else
  echo "✅ Good number of examples ($EXAMPLE_COUNT)"
fi

# Check for commentary in examples
COMMENTARY_COUNT=$(echo "$DESCRIPTION" | grep -c '<commentary>' 2>/dev/null || echo 0)
COMMENTARY_COUNT=$(echo "$COMMENTARY_COUNT" | tr -d '[:space:]')
if [ "$COMMENTARY_COUNT" -lt "$EXAMPLE_COUNT" ]; then
  echo "⚠️  Some examples missing <commentary> blocks"
  ((warning_count++))
else
  echo "✅ All examples have commentary"
fi

# Check for Context in examples
CONTEXT_COUNT=$(echo "$DESCRIPTION" | grep -ci 'context:' 2>/dev/null || echo 0)
CONTEXT_COUNT=$(echo "$CONTEXT_COUNT" | tr -d '[:space:]')
if [ "$CONTEXT_COUNT" -lt "$EXAMPLE_COUNT" ]; then
  echo "⚠️  Some examples missing Context: lines"
  ((warning_count++))
else
  echo "✅ All examples have context"
fi

# Check for assistant responses
ASSISTANT_COUNT=$(echo "$DESCRIPTION" | grep -c 'assistant:' 2>/dev/null || echo 0)
ASSISTANT_COUNT=$(echo "$ASSISTANT_COUNT" | tr -d '[:space:]')
if [ "$ASSISTANT_COUNT" -lt "$EXAMPLE_COUNT" ]; then
  echo "⚠️  Some examples missing assistant: responses"
  ((warning_count++))
else
  echo "✅ All examples have assistant responses"
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📖 MANUAL TESTING GUIDE"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "To test agent triggering:"
echo ""
echo "1. Load your plugin in Claude Code:"
echo "   cc --plugin-dir /path/to/plugin"
echo ""
echo "2. Try the trigger phrases listed above"
echo ""
echo "3. Verify Claude loads the agent (look for agent indicator)"
echo ""
echo "4. Test variations of the phrases to ensure robust triggering"
echo ""
echo "5. Test negative cases - phrases that should NOT trigger"
echo ""

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

if [ "$warning_count" -eq 0 ]; then
  echo "✅ All validations passed!"
  exit 0
else
  echo "⚠️  Completed with $warning_count warning(s)"
  exit 0
fi
