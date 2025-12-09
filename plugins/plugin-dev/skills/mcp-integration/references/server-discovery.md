# MCP Server Discovery

Discover MCP servers for plugin integration using PulseMCP, the comprehensive MCP server directory.

## Discovery Method

Use Tavily extract to search PulseMCP's server directory:

### Step 1: Search PulseMCP

```
Tool: mcp__tavily-mcp__tavily-extract
URLs: ["https://www.pulsemcp.com/servers?q=[keyword]"]
Format: markdown
```

**URL patterns:**

| Purpose | URL |
|---------|-----|
| Basic search | `https://www.pulsemcp.com/servers?q=[keyword]` |
| By popularity | `https://www.pulsemcp.com/servers?q=[keyword]&sort=popular-desc` |
| Official only | `https://www.pulsemcp.com/servers?q=[keyword]&classification=official` |
| Server details | `https://www.pulsemcp.com/servers/[slug]` |

**Search keywords:**

- Service names: `notion`, `github`, `slack`, `postgres`
- Categories: `database`, `api`, `file`, `memory`, `browser`
- Combined: `vector database`, `project management`

### Step 2: Parse Results

Extract from search results:

| Field | Description | Use For |
|-------|-------------|---------|
| Server name | Display name | User presentation |
| Provider | Company/author | Trust signal |
| Description | Brief summary | Feature matching |
| Classification | official/community | Quality signal |
| Downloads/visitors | Weekly estimates | Popularity signal |
| Slug | URL segment | Detail page fetch |

**Example parsed entry:**

```
Name: DBHub (Universal Database Gateway)
Provider: Bytebase
Description: Universal database gateway for PostgreSQL, MySQL, SQLite, DuckDB
Classification: official
Downloads: 6.7k/week
Slug: bytebase-dbhub
```

### Step 3: Evaluate and Recommend

Recommend servers based on:

1. **Relevance** - Description matches user's needs
2. **Classification** - Prefer `official` over `community`
3. **Popularity** - Higher downloads indicate stability
4. **Recency** - Recent releases suggest active maintenance

Present top 3-5 matches with key differentiators.

### Step 4: Fetch Details (Optional)

For servers the user wants to integrate, fetch the detail page:

```
Tool: mcp__tavily-mcp__tavily-extract
URLs: ["https://www.pulsemcp.com/servers/[slug]"]
```

Extract from detail page:

- GitHub repository URL and stars
- Full description
- server.json availability (for standardized config)
- Related servers (alternatives)

## Quick Reference: Top MCP Servers

Curated recommendations for common use cases. Use live search for comprehensive results.

### Databases

| Server | Provider | Type | Best For |
|--------|----------|------|----------|
| Toolbox for Databases | Google | stdio | Multi-DB (PostgreSQL, MySQL, SQL Server, Neo4j, Spanner) |
| DBHub | Bytebase | stdio | Universal gateway (PostgreSQL, MySQL, SQLite, DuckDB) |
| Context7 | Upstash | stdio | Documentation/library lookup |

### Productivity

| Server | Provider | Type | Best For |
|--------|----------|------|----------|
| Notion | Notion | SSE | Workspace integration |
| Asana | Asana | SSE | Task/project management |
| Slack | Slack | SSE | Team communication |
| Linear | Linear | SSE | Issue tracking |

### Developer Tools

| Server | Provider | Type | Best For |
|--------|----------|------|----------|
| GitHub | GitHub | SSE | Repository management, PRs, issues |
| GitLab | GitLab | SSE | GitLab repositories and CI/CD |
| Playwright | Microsoft | stdio | Browser automation, testing |

### Cloud & Infrastructure

| Server | Provider | Type | Best For |
|--------|----------|------|----------|
| AWS | AWS | stdio | AWS service management |
| Kubernetes | Community | stdio | K8s cluster operations |
| Docker | Community | stdio | Container management |

### AI & Search

| Server | Provider | Type | Best For |
|--------|----------|------|----------|
| Tavily | Tavily | stdio | Web search and extraction |
| Perplexity | Perplexity | SSE | AI-powered search |
| Memory | Various | stdio | Conversation memory/RAG |

### File & Storage

| Server | Provider | Type | Best For |
|--------|----------|------|----------|
| Filesystem | Anthropic | stdio | Local file access |
| Google Drive | Google | SSE | Cloud storage |
| S3 | AWS | stdio | Object storage |

## Integration Workflow

After discovering a server:

1. **Check server type** - stdio (local), SSE (hosted), HTTP, or WebSocket
2. **Get installation info** - Fetch detail page for GitHub README
3. **Determine auth method** - OAuth (SSE), tokens (HTTP), env vars (stdio)
4. **Generate configuration** - Create `.mcp.json` entry

**Example workflow:**

```
User: "I need an MCP server for Notion"

1. Search: tavily-extract on pulsemcp.com/servers?q=notion
2. Find: Notion (official SSE server)
3. Recommend: Official Notion MCP with OAuth
4. Configure:
   {
     "notion": {
       "type": "sse",
       "url": "https://mcp.notion.com/sse"
     }
   }
```

## Alternative Discovery

If Tavily is unavailable, use WebFetch:

```
Tool: WebFetch
URL: https://www.pulsemcp.com/servers?q=[keyword]
Prompt: List MCP servers matching "[keyword]" with name, description, classification, and slug
```

## PulseMCP MCP Server

For plugins needing programmatic server discovery, recommend the PulseMCP MCP server:

```json
{
  "pulsemcp": {
    "command": "npx",
    "args": ["-y", "pulsemcp-server"]
  }
}
```

**Tools provided:**

- `list_servers` - Search/filter servers with pagination
- `list_integrations` - List all integration categories

Use when building plugins that help users discover and configure MCP servers.
