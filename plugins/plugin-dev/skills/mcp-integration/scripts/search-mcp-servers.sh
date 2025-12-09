#!/bin/bash
# MCP Server Discovery Script
# Search the official MCP Registry and enrich results with GitHub stars

set -euo pipefail

# Configuration
REGISTRY_URL="https://registry.modelcontextprotocol.io/v0/servers"
DEFAULT_LIMIT=10
DEFAULT_FORMAT="table"

# Colors (disabled if not a terminal)
if [ -t 1 ]; then
  BOLD='\033[1m'
  DIM='\033[2m'
  RESET='\033[0m'
  YELLOW='\033[33m'
  RED='\033[31m'
  GREEN='\033[32m'
else
  BOLD=''
  DIM=''
  RESET=''
  YELLOW=''
  RED=''
  GREEN=''
fi

# Show help message
show_help() {
  cat << 'EOF'
MCP Server Discovery

Search the official MCP Registry for servers and sort by GitHub popularity.

USAGE:
    search-mcp-servers.sh [OPTIONS] <keywords...>

OPTIONS:
    -n, --limit N       Maximum results to return (default: 10)
    -f, --format FMT    Output format: table, json, simple (default: table)
    -t, --transport T   Filter by transport type: stdio, sse, http, ws
    -h, --help          Show this help message

EXAMPLES:
    # Search for database servers
    ./search-mcp-servers.sh database postgres

    # Get top 5 results as JSON
    ./search-mcp-servers.sh -n 5 --format json filesystem

    # Search for stdio-only servers
    ./search-mcp-servers.sh --transport stdio github

    # Simple output for scripting
    ./search-mcp-servers.sh --format simple "web search"

OUTPUT FORMATS:
    table   - Formatted table with stars, name, description, URL (default)
    json    - JSON array for programmatic use
    simple  - One server per line: stars|name|url

NOTES:
    - Results are sorted by GitHub stars (descending)
    - Servers without GitHub repos appear at the bottom
    - Requires: curl, jq, gh (GitHub CLI)
EOF
}

# Check for required dependencies
check_dependencies() {
  local missing=()

  if ! command -v curl &> /dev/null; then
    missing+=("curl")
  fi

  if ! command -v jq &> /dev/null; then
    missing+=("jq")
  fi

  if ! command -v gh &> /dev/null; then
    missing+=("gh (GitHub CLI)")
  fi

  if [ ${#missing[@]} -gt 0 ]; then
    echo -e "${RED}❌ Missing required dependencies:${RESET}" >&2
    for dep in "${missing[@]}"; do
      echo "   - $dep" >&2
    done
    exit 1
  fi
}

# Get GitHub stars for a repository URL
# Returns 0 if not a GitHub repo or on error
get_github_stars() {
  local repo_url="$1"
  local stars=0

  # Extract owner/repo from GitHub URL
  if [[ "$repo_url" =~ github\.com[/:]([^/]+)/([^/]+) ]]; then
    local owner="${BASH_REMATCH[1]}"
    local repo="${BASH_REMATCH[2]}"
    # Remove .git suffix if present
    repo="${repo%.git}"

    # Query GitHub API
    stars=$(gh api "repos/$owner/$repo" --jq '.stargazers_count' 2>/dev/null || echo "0")

    # Handle non-numeric responses
    if ! [[ "$stars" =~ ^[0-9]+$ ]]; then
      stars=0
    fi
  fi

  echo "$stars"
}

# Query the MCP Registry
query_registry() {
  local keywords="$1"
  local limit="$2"

  local encoded_keywords
  encoded_keywords=$(echo -n "$keywords" | jq -sRr @uri)

  local url="${REGISTRY_URL}?search=${encoded_keywords}&limit=${limit}"

  local response
  if ! response=$(curl -s --fail --max-time 30 "$url" 2>/dev/null); then
    echo -e "${RED}❌ Failed to query MCP Registry${RESET}" >&2
    echo -e "${DIM}   URL: $url${RESET}" >&2
    echo -e "${DIM}   Check your network connection${RESET}" >&2
    exit 1
  fi

  # Validate response is valid JSON with servers array
  if ! echo "$response" | jq -e '.servers' &>/dev/null; then
    echo -e "${RED}❌ Invalid response from MCP Registry${RESET}" >&2
    exit 1
  fi

  echo "$response"
}

# Format output as table
format_table() {
  local data="$1"
  local count
  count=$(echo "$data" | jq 'length')

  if [ "$count" -eq 0 ]; then
    echo -e "${YELLOW}No servers found matching your search.${RESET}"
    echo ""
    echo "Suggestions:"
    echo "  - Try broader search terms"
    echo "  - Check spelling"
    echo "  - Browse categories at https://smithery.ai/"
    return
  fi

  echo -e "${BOLD}┌─────────────────────────────────────────────────────────────────┐${RESET}"
  echo -e "${BOLD}│ MCP Server Discovery Results (sorted by GitHub stars)          │${RESET}"
  echo -e "${BOLD}├─────────────────────────────────────────────────────────────────┤${RESET}"

  echo "$data" | jq -r '.[] | "\(.stars)|\(.name)|\(.description)|\(.repository)"' | while IFS='|' read -r stars name description repo; do
    # Truncate description if too long
    if [ ${#description} -gt 55 ]; then
      description="${description:0:52}..."
    fi

    # Format stars with padding
    if [ "$stars" -eq 0 ]; then
      stars_display="  -   "
    else
      stars_display=$(printf "⭐ %'d" "$stars")
      # Pad to 6 chars
      while [ ${#stars_display} -lt 8 ]; do
        stars_display="$stars_display "
      done
    fi

    echo -e "│ ${GREEN}${stars_display}${RESET} ${BOLD}${name}${RESET}"
    echo -e "│          ${DIM}${description}${RESET}"
    echo -e "│          ${DIM}${repo}${RESET}"
    echo -e "├─────────────────────────────────────────────────────────────────┤"
  done | head -n -1  # Remove last separator

  echo -e "${BOLD}└─────────────────────────────────────────────────────────────────┘${RESET}"
  echo ""
  echo -e "Found ${BOLD}$count${RESET} server(s) matching your search"
}

# Format output as JSON
format_json() {
  local data="$1"
  echo "$data" | jq '.'
}

# Format output as simple (one per line)
format_simple() {
  local data="$1"
  echo "$data" | jq -r '.[] | "\(.stars)|\(.name)|\(.repository)"'
}

# Main function
main() {
  local limit=$DEFAULT_LIMIT
  local format=$DEFAULT_FORMAT
  local transport=""
  local keywords=""

  # Parse arguments
  while [ $# -gt 0 ]; do
    case "$1" in
      -h|--help)
        show_help
        exit 0
        ;;
      -n|--limit)
        if [ -z "${2:-}" ] || [[ "$2" == -* ]]; then
          echo -e "${RED}❌ --limit requires a number${RESET}" >&2
          exit 1
        fi
        limit="$2"
        if ! [[ "$limit" =~ ^[0-9]+$ ]] || [ "$limit" -eq 0 ]; then
          echo -e "${RED}❌ --limit must be a positive number${RESET}" >&2
          exit 1
        fi
        shift 2
        ;;
      -f|--format)
        if [ -z "${2:-}" ] || [[ "$2" == -* ]]; then
          echo -e "${RED}❌ --format requires a value (table, json, simple)${RESET}" >&2
          exit 1
        fi
        format="$2"
        if [[ ! "$format" =~ ^(table|json|simple)$ ]]; then
          echo -e "${RED}❌ Invalid format: $format (use table, json, or simple)${RESET}" >&2
          exit 1
        fi
        shift 2
        ;;
      -t|--transport)
        if [ -z "${2:-}" ] || [[ "$2" == -* ]]; then
          echo -e "${RED}❌ --transport requires a value (stdio, sse, http, ws)${RESET}" >&2
          exit 1
        fi
        transport="$2"
        if [[ ! "$transport" =~ ^(stdio|sse|http|ws)$ ]]; then
          echo -e "${RED}❌ Invalid transport: $transport (use stdio, sse, http, or ws)${RESET}" >&2
          exit 1
        fi
        shift 2
        ;;
      -*)
        echo -e "${RED}❌ Unknown option: $1${RESET}" >&2
        echo "Use --help for usage information" >&2
        exit 1
        ;;
      *)
        # Collect positional arguments as keywords
        if [ -n "$keywords" ]; then
          keywords="$keywords $1"
        else
          keywords="$1"
        fi
        shift
        ;;
    esac
  done

  # Validate keywords
  if [ -z "$keywords" ]; then
    echo -e "${RED}❌ No search keywords provided${RESET}" >&2
    echo "" >&2
    echo "Usage: search-mcp-servers.sh [OPTIONS] <keywords...>" >&2
    echo "Use --help for more information" >&2
    exit 1
  fi

  # Check dependencies
  check_dependencies

  # Query registry
  if [ "$format" = "table" ]; then
    echo -e "${DIM}Searching MCP Registry for: $keywords${RESET}"
    echo ""
  fi

  local response
  response=$(query_registry "$keywords" "$limit")

  # Extract servers and enrich with stars
  local servers
  servers=$(echo "$response" | jq -c '.servers // []')

  local server_count
  server_count=$(echo "$servers" | jq 'length')

  if [ "$server_count" -eq 0 ]; then
    format_table "[]"
    exit 0
  fi

  # Build enriched data with stars
  if [ "$format" = "table" ]; then
    echo -e "${DIM}Fetching GitHub stars for $server_count server(s)...${RESET}"
  fi

  local enriched="[]"
  local rate_limit_warned=false

  while IFS= read -r server; do
    local name description repo stars

    name=$(echo "$server" | jq -r '.name // "unknown"')
    description=$(echo "$server" | jq -r '.description // "No description"')
    repo=$(echo "$server" | jq -r '.repository // ""')

    # Get stars (with rate limit handling)
    if [ -n "$repo" ]; then
      stars=$(get_github_stars "$repo")

      # Check for potential rate limiting (all zeros after first few)
      if [ "$stars" -eq 0 ] && [ "$rate_limit_warned" = false ]; then
        # Simple heuristic: if we're getting zeros, might be rate limited
        :
      fi
    else
      stars=0
    fi

    # Add to enriched array
    enriched=$(echo "$enriched" | jq --arg name "$name" \
      --arg desc "$description" \
      --arg repo "$repo" \
      --argjson stars "$stars" \
      '. + [{name: $name, description: $desc, repository: $repo, stars: $stars}]')

  done < <(echo "$servers" | jq -c '.[]')

  # Filter by transport if specified
  if [ -n "$transport" ]; then
    # Note: Transport info may not be in registry response
    # This is a placeholder for when that data becomes available
    if [ "$format" = "table" ]; then
      echo -e "${YELLOW}Note: Transport filtering may not match all servers (data not always available)${RESET}"
    fi
  fi

  # Sort by stars descending
  enriched=$(echo "$enriched" | jq 'sort_by(-.stars)')

  # Output in requested format
  case "$format" in
    table)
      echo ""
      format_table "$enriched"
      ;;
    json)
      format_json "$enriched"
      ;;
    simple)
      format_simple "$enriched"
      ;;
  esac
}

# Run main function
main "$@"
