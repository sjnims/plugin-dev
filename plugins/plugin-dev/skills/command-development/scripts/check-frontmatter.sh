#!/bin/bash
# Command Frontmatter Validator
# Validates YAML frontmatter fields in command files

set -euo pipefail

# Usage
if [ $# -eq 0 ]; then
  echo "Usage: $0 <path/to/command.md> [command2.md ...]"
  echo ""
  echo "Validates frontmatter fields for:"
  echo "  - 'model' field (sonnet, opus, haiku, or full model ID)"
  echo "  - 'description' length (warns if > 60 chars)"
  echo "  - 'allowed-tools' format"
  echo "  - 'argument-hint' format"
  echo "  - 'disable-model-invocation' boolean"
  echo "  - Unknown fields (warning)"
  echo ""
  echo "Examples:"
  echo "  $0 .claude/commands/review.md"
  echo "  $0 commands/*.md"
  exit 1
fi

# Known frontmatter fields for commands
KNOWN_FIELDS="description model allowed-tools argument-hint disable-model-invocation"

total_errors=0
total_warnings=0

check_frontmatter() {
  local COMMAND_FILE="$1"
  local error_count=0
  local warning_count=0

  echo "🔍 Checking frontmatter: $COMMAND_FILE"
  echo ""

  # Check file exists
  if [ ! -f "$COMMAND_FILE" ]; then
    echo "❌ Error: File not found: $COMMAND_FILE"
    return 1
  fi

  # Check for frontmatter
  if ! head -n 1 "$COMMAND_FILE" | grep -q "^---"; then
    echo "ℹ️  No frontmatter found (frontmatter is optional)"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "✅ $COMMAND_FILE: No frontmatter to validate"
    echo ""
    return 0
  fi

  # Extract frontmatter - only the first block between lines 1 and the second ---
  # Use awk to get content between first and second --- markers only
  local frontmatter
  frontmatter=$(awk '
    /^---$/ { count++; if (count == 2) exit; next }
    count == 1 { print }
  ' "$COMMAND_FILE")

  if [ -z "$frontmatter" ]; then
    echo "⚠️  Warning: Empty frontmatter block"
    ((warning_count++))
    total_warnings=$((total_warnings + warning_count))
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "⚠️  $COMMAND_FILE: Passed with $warning_count warning(s)"
    echo ""
    return 0
  fi

  echo "Frontmatter found. Validating fields..."
  echo ""

  # Check 'model' field
  if echo "$frontmatter" | grep -q "^model:"; then
    local model
    model=$(echo "$frontmatter" | grep "^model:" | cut -d: -f2 | tr -d ' ')

    # Valid values: sonnet, opus, haiku, or full model ID (claude-*)
    if [[ "$model" =~ ^(sonnet|opus|haiku)$ ]]; then
      echo "✅ model: $model (shorthand)"
    elif [[ "$model" =~ ^claude- ]]; then
      echo "✅ model: $model (full model ID)"
    else
      echo "❌ Error: Invalid model '$model'"
      echo "   Valid: sonnet, opus, haiku, or full model ID (e.g., claude-sonnet-4-5-20250929)"
      ((error_count++))
    fi
  fi

  # Check 'description' field
  if echo "$frontmatter" | grep -q "^description:"; then
    local desc
    desc=$(echo "$frontmatter" | grep "^description:" | cut -d: -f2- | sed 's/^ *//')
    local length=${#desc}

    if [ "$length" -eq 0 ]; then
      echo "⚠️  Warning: Empty description"
      ((warning_count++))
    elif [ "$length" -gt 80 ]; then
      echo "⚠️  Warning: Description too long ($length chars, recommend < 60)"
      ((warning_count++))
    elif [ "$length" -gt 60 ]; then
      echo "⚠️  Warning: Description length $length (recommend < 60 chars)"
      ((warning_count++))
    else
      echo "✅ description: $length chars"
    fi
  fi

  # Check 'allowed-tools' field
  if echo "$frontmatter" | grep -q "^allowed-tools:"; then
    local tools
    tools=$(echo "$frontmatter" | grep "^allowed-tools:" | cut -d: -f2- | sed 's/^ *//')

    if [ -z "$tools" ]; then
      echo "⚠️  Warning: Empty allowed-tools field"
      ((warning_count++))
    else
      # Check for common patterns
      if [[ "$tools" == "*" ]]; then
        echo "⚠️  Warning: allowed-tools: * grants all tools (consider restricting)"
        ((warning_count++))
      elif [[ "$tools" =~ Bash\(\*\) ]]; then
        echo "⚠️  Warning: Bash(*) is very permissive (consider Bash(git:*) or similar)"
        ((warning_count++))
      else
        echo "✅ allowed-tools: $tools"
      fi
    fi
  fi

  # Check 'argument-hint' field
  if echo "$frontmatter" | grep -q "^argument-hint:"; then
    local hint
    hint=$(echo "$frontmatter" | grep "^argument-hint:" | cut -d: -f2- | sed 's/^ *//')

    if [ -z "$hint" ]; then
      echo "⚠️  Warning: Empty argument-hint field"
      ((warning_count++))
    else
      # Check for bracket convention
      if [[ ! "$hint" =~ \[.*\] ]]; then
        echo "⚠️  Warning: argument-hint missing bracket convention (e.g., [arg-name])"
        ((warning_count++))
      else
        echo "✅ argument-hint: $hint"
      fi
    fi
  fi

  # Check 'disable-model-invocation' field
  if echo "$frontmatter" | grep -q "^disable-model-invocation:"; then
    local value
    value=$(echo "$frontmatter" | grep "^disable-model-invocation:" | cut -d: -f2 | tr -d ' ')

    if [[ "$value" =~ ^(true|false)$ ]]; then
      echo "✅ disable-model-invocation: $value"
    else
      echo "❌ Error: disable-model-invocation must be true or false (got '$value')"
      ((error_count++))
    fi
  fi

  # Check for unknown fields
  echo ""
  echo "Checking for unknown fields..."
  local unknown_found=false

  while IFS= read -r line; do
    # Skip empty lines
    [ -z "$line" ] && continue

    # Extract field name (everything before the colon)
    local field
    field=$(echo "$line" | grep -oE "^[a-z-]+" || true)

    if [ -n "$field" ]; then
      local known=false
      for known_field in $KNOWN_FIELDS; do
        if [ "$field" = "$known_field" ]; then
          known=true
          break
        fi
      done

      if [ "$known" = false ]; then
        echo "⚠️  Warning: Unknown field '$field'"
        ((warning_count++))
        unknown_found=true
      fi
    fi
  done <<< "$frontmatter"

  if [ "$unknown_found" = false ]; then
    echo "✅ No unknown fields"
  fi

  # Summary
  echo ""
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  if [ $error_count -eq 0 ] && [ $warning_count -eq 0 ]; then
    echo "✅ $COMMAND_FILE: All frontmatter checks passed!"
  elif [ $error_count -eq 0 ]; then
    echo "⚠️  $COMMAND_FILE: Passed with $warning_count warning(s)"
  else
    echo "❌ $COMMAND_FILE: Failed with $error_count error(s) and $warning_count warning(s)"
  fi
  echo ""

  total_errors=$((total_errors + error_count))
  total_warnings=$((total_warnings + warning_count))

  return $error_count
}

# Process all provided files
for file in "$@"; do
  check_frontmatter "$file" || true
done

# Final summary for multiple files
if [ $# -gt 1 ]; then
  echo "═══════════════════════════════════════"
  echo "Total: $# files checked"
  echo "Errors: $total_errors"
  echo "Warnings: $total_warnings"
fi

if [ $total_errors -gt 0 ]; then
  exit 1
fi
exit 0
