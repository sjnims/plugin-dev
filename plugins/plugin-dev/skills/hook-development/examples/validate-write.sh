#!/bin/bash
# Example PreToolUse hook for validating Write/Edit operations
# This script demonstrates file write validation patterns

set -euo pipefail

# Read input from stdin
input=$(cat)

# Extract file path and content
file_path=$(echo "$input" | jq -r '.tool_input.file_path // empty')

# Validate path exists
if [ -z "$file_path" ]; then
  echo '{"continue": true}' # No path to validate
  exit 0
fi

# Check for path traversal
# NOTE: This basic check catches literal ".." but has limitations:
# - Does not detect URL-encoded traversal (%2e%2e)
# - Cannot detect symlink-based traversal where resolved path escapes bounds
# - Shell expansion could bypass in some contexts
# For production hooks, consider using:
#   resolved=$(realpath -m "$file_path" 2>/dev/null || echo "$file_path")
# and comparing against an allowed directory prefix
if [[ "$file_path" == *".."* ]]; then
  jq -n --arg path "$file_path" \
    '{"hookSpecificOutput": {"permissionDecision": "deny"}, "systemMessage": "Path traversal detected in: \($path)"}' >&2
  exit 2
fi

# Check for system directories
if [[ "$file_path" == /etc/* ]] || [[ "$file_path" == /sys/* ]] || [[ "$file_path" == /usr/* ]]; then
  jq -n --arg path "$file_path" \
    '{"hookSpecificOutput": {"permissionDecision": "deny"}, "systemMessage": "Cannot write to system directory: \($path)"}' >&2
  exit 2
fi

# Check for sensitive files
if [[ "$file_path" == *.env ]] || [[ "$file_path" == *secret* ]] || [[ "$file_path" == *credentials* ]]; then
  jq -n --arg path "$file_path" \
    '{"hookSpecificOutput": {"permissionDecision": "ask"}, "systemMessage": "Writing to potentially sensitive file: \($path)"}' >&2
  exit 2
fi

# Approve the operation
exit 0
