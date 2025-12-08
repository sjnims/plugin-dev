#!/bin/bash
# Command File Validator
# Validates command file structure and syntax

set -euo pipefail

# Usage
if [ $# -eq 0 ]; then
  echo "Usage: $0 <path/to/command.md> [command2.md ...]"
  echo ""
  echo "Validates command file for:"
  echo "  - File exists with .md extension"
  echo "  - YAML frontmatter syntax (if present)"
  echo "  - Non-empty content"
  echo "  - Correct location (warning only)"
  echo ""
  echo "Examples:"
  echo "  $0 .claude/commands/review.md"
  echo "  $0 commands/*.md"
  exit 1
fi

total_errors=0
total_warnings=0

validate_command() {
  local COMMAND_FILE="$1"
  local error_count=0
  local warning_count=0

  echo "🔍 Validating command: $COMMAND_FILE"
  echo ""

  # Check 1: File exists
  if [ ! -f "$COMMAND_FILE" ]; then
    echo "❌ Error: File not found: $COMMAND_FILE"
    return 1
  fi
  echo "✅ File exists"

  # Check 2: .md extension
  if [[ ! "$COMMAND_FILE" =~ \.md$ ]]; then
    echo "❌ Error: File must have .md extension"
    ((error_count++))
  else
    echo "✅ Has .md extension"
  fi

  # Check 3: Non-empty file
  if [ ! -s "$COMMAND_FILE" ]; then
    echo "❌ Error: File is empty"
    ((error_count++))
  else
    echo "✅ File is not empty"
  fi

  # Check 4: YAML frontmatter syntax (if present)
  if head -n 1 "$COMMAND_FILE" | grep -q "^---"; then
    echo ""
    echo "Checking YAML frontmatter..."

    # Count frontmatter markers in first 50 lines
    MARKERS=$(head -n 50 "$COMMAND_FILE" | grep -c "^---" || true)
    if [ "$MARKERS" -lt 2 ]; then
      echo "❌ Error: Invalid YAML frontmatter (need exactly 2 '---' markers, found $MARKERS)"
      ((error_count++))
    elif [ "$MARKERS" -gt 2 ]; then
      echo "⚠️  Warning: Multiple frontmatter markers detected ($MARKERS). Only first pair is used."
      ((warning_count++))
    else
      echo "✅ YAML frontmatter delimiters valid"
    fi

    # Check for malformed YAML (basic check)
    # Extract frontmatter - only between first and second --- markers
    local frontmatter
    frontmatter=$(awk '
      /^---$/ { count++; if (count == 2) exit; next }
      count == 1 { print }
    ' "$COMMAND_FILE")

    if [ -n "$frontmatter" ]; then
      # Check for tabs (YAML prefers spaces)
      if echo "$frontmatter" | grep -q $'\t'; then
        echo "⚠️  Warning: Frontmatter contains tabs (YAML prefers spaces)"
        ((warning_count++))
      fi

      # Check for common YAML errors - key without value
      if echo "$frontmatter" | grep -qE "^[a-z-]+:$"; then
        echo "⚠️  Warning: Frontmatter has keys without values"
        ((warning_count++))
      fi
    fi
  else
    echo ""
    echo "ℹ️  No YAML frontmatter (optional)"
  fi

  # Check 5: Location warning
  echo ""
  echo "Checking location..."
  if [[ "$COMMAND_FILE" == *".claude/commands/"* ]] || [[ "$COMMAND_FILE" == *"/commands/"* ]]; then
    echo "✅ File in expected commands directory"
  else
    echo "⚠️  Warning: File not in .claude/commands/ or plugin commands/ directory"
    ((warning_count++))
  fi

  # Check 6: Filename conventions
  echo ""
  echo "Checking filename..."
  local filename
  filename=$(basename "$COMMAND_FILE" .md)

  if [[ "$filename" =~ [A-Z] ]]; then
    echo "⚠️  Warning: Filename contains uppercase letters (recommend lowercase)"
    ((warning_count++))
  elif [[ "$filename" =~ [[:space:]] ]]; then
    echo "⚠️  Warning: Filename contains spaces (use hyphens instead)"
    ((warning_count++))
  else
    echo "✅ Filename follows conventions"
  fi

  # Summary
  echo ""
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  if [ $error_count -eq 0 ] && [ $warning_count -eq 0 ]; then
    echo "✅ $COMMAND_FILE: All checks passed!"
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
  validate_command "$file" || true
done

# Final summary for multiple files
if [ $# -gt 1 ]; then
  echo "═══════════════════════════════════════"
  echo "Total: $# files validated"
  echo "Errors: $total_errors"
  echo "Warnings: $total_warnings"
fi

if [ $total_errors -gt 0 ]; then
  exit 1
fi
exit 0
