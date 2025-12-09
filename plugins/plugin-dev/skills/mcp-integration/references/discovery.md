# MCP Server Discovery: Finding and Evaluating Servers

Complete reference for discovering MCP servers to integrate into Claude Code plugins.

## Overview

When building plugins that need external capabilities, finding the right MCP server saves development time and leverages community-tested implementations. This guide covers discovery sources, search strategies, and evaluation criteria.

### When to Use MCP Servers

**Integrate existing MCP servers when:**

- Standard functionality exists (file system, database, API clients)
- Multiple tools needed from single service (10+ related operations)
- OAuth or complex authentication required
- Community maintenance preferred over custom implementation

**Build custom solutions when:**

- Functionality is unique to your use case
- Only 1-2 simple tools needed
- Tight integration with plugin logic required
- Existing servers don't meet security requirements

## Official MCP Registry

The official registry at `registry.modelcontextprotocol.io` provides a REST API for discovering servers.

### API Endpoint

```text
https://registry.modelcontextprotocol.io/v0/servers
```

### Search Syntax

**Basic search:**

```text
GET /v0/servers?search=filesystem
```

**With limit:**

```text
GET /v0/servers?search=database&limit=10
```

**Pagination:**

```text
GET /v0/servers?cursor=<cursor_from_previous_response>
```

**Quick test:**

```bash
curl "https://registry.modelcontextprotocol.io/v0/servers?search=filesystem&limit=5"
```

No authentication required. Returns JSON with matching servers.

### Response Structure

```json
{
  "servers": [
    {
      "name": "@modelcontextprotocol/server-filesystem",
      "description": "MCP server for file system operations",
      "repository": "https://github.com/modelcontextprotocol/servers",
      "homepage": "https://modelcontextprotocol.io"
    }
  ],
  "cursor": "next_page_cursor"
}
```

### Key Fields

| Field | Description |
|-------|-------------|
| `name` | Package/server name (often npm scope) |
| `description` | Brief functionality summary |
| `repository` | Source code location |
| `homepage` | Documentation URL |

### Limitations

The official registry provides no popularity metrics. Supplement with GitHub stars or npm downloads for quality signals.

## Alternative Discovery Sources

### Smithery.ai

Largest MCP server marketplace with usage metrics.

**URL:** <https://smithery.ai/>

**Advantages:**

- Call volume statistics (popularity indicator)
- Curated categories
- Installation instructions
- User ratings

**Search tips:**

- Browse categories for common use cases
- Sort by popularity for battle-tested servers
- Check "Recently Added" for new capabilities

### npm Registry

Official MCP servers and community packages available via npm.

**Official scope search:**

```bash
npm search @modelcontextprotocol
```

**Community search:**

```bash
npm search mcp-server
```

**Key indicators:**

- Weekly downloads (popularity)
- Last publish date (maintenance)
- Dependency count (complexity)

### GitHub

Direct source code access and community engagement metrics.

**Topic search:**

```text
https://github.com/topics/mcp-server
```

**Curated lists:**

- `awesome-mcp-servers` repositories
- `modelcontextprotocol` organization

**Search queries:**

```text
mcp server in:name,description language:TypeScript
model context protocol in:readme
```

### MCP.SO

Third-party aggregator with rankings and categories.

**URL:** <https://mcp.so/>

**Features:**

- Combined metrics from multiple sources
- Category browsing
- Quick comparison view

## Category Mappings

Find servers for common plugin needs:

| Plugin Need | Search Terms | Notable Servers |
|-------------|--------------|-----------------|
| Database access | postgres, sqlite, database, sql | @modelcontextprotocol/server-postgres, mcp-server-sqlite |
| File operations | filesystem, files, directory | @modelcontextprotocol/server-filesystem |
| GitHub integration | github, git, repository | Official GitHub MCP server |
| Web search | search, web, exa, tavily | Exa MCP, Tavily MCP |
| Browser automation | browser, playwright, puppeteer | Browserbase, Playwright MCP |
| Memory/knowledge | memory, knowledge, notes | @modelcontextprotocol/server-memory |
| Time/scheduling | time, calendar, scheduling | Google Calendar MCP |
| HTTP/APIs | fetch, http, rest, api | mcp-server-fetch |
| Slack integration | slack, messaging | Slack MCP server |
| Email | email, gmail, smtp | Gmail MCP servers |

## Evaluation Criteria

### Popularity Signals

Strong indicators of production-ready servers:

| Metric | Good | Excellent |
|--------|------|-----------|
| GitHub stars | 50+ | 500+ |
| npm weekly downloads | 100+ | 1,000+ |
| Smithery call volume | 1K+ | 10K+ |
| Forks | 10+ | 50+ |

### Maintenance Indicators

Signs of active development:

- **Recent commits:** Last commit within 3 months
- **Issue response time:** Maintainers respond within 1-2 weeks
- **Release cadence:** Regular releases (monthly or quarterly)
- **Open issues ratio:** Less than 50% of total issues open

### Quality Markers

Technical quality signals:

- **TypeScript:** Type safety and better IDE support
- **Tests:** Test suite with reasonable coverage
- **Documentation:** README with setup instructions and examples
- **Semantic versioning:** Proper version management
- **License:** Permissive license (MIT, Apache 2.0)
- **CI/CD:** Automated testing and publishing

### Red Flags

Avoid servers with these issues:

| Red Flag | Risk |
|----------|------|
| No license | Legal uncertainty |
| Abandoned (1+ year stale) | Security vulnerabilities, no bug fixes |
| Hardcoded secrets in examples | Poor security practices |
| No error handling | Unreliable in production |
| Excessive permissions | Security risk |
| No README | Integration difficulty |
| Only personal use | Not designed for distribution |

## Discovery Workflow

Recommended process for finding MCP servers:

1. **Define requirements**
   - List needed capabilities
   - Identify authentication requirements
   - Consider security constraints

2. **Search official registry first**
   - Query `registry.modelcontextprotocol.io`
   - Check official `@modelcontextprotocol` packages

3. **Expand to alternative sources**
   - Browse Smithery categories
   - Search npm for community packages
   - Check GitHub awesome lists

4. **Evaluate candidates**
   - Apply popularity filters
   - Check maintenance status
   - Review code quality

5. **Test integration**
   - Clone and run locally
   - Verify tools work as expected
   - Check error handling

6. **Document choice**
   - Record why server was selected
   - Note any limitations
   - Plan for future updates

## Discovery Script

Use the discovery script for automated server search with popularity ranking:

```bash
# Basic search
./scripts/search-mcp-servers.sh database postgres

# Limit results and get JSON output
./scripts/search-mcp-servers.sh --limit 5 --format json filesystem

# Simple output for scripting (stars|name|url)
./scripts/search-mcp-servers.sh --format simple github
```

Run `./scripts/search-mcp-servers.sh --help` for all options.

## Quick Reference

### Search Priority

1. Official MCP Registry (`registry.modelcontextprotocol.io`)
2. npm `@modelcontextprotocol` scope
3. Smithery.ai curated servers
4. npm community packages (`mcp-server-*`)
5. GitHub topic search

### Minimum Quality Bar

Before integrating an MCP server, verify:

- [ ] Active maintenance (commits within 6 months)
- [ ] Proper license (MIT, Apache 2.0, etc.)
- [ ] Documentation exists
- [ ] No obvious security issues
- [ ] Works with current MCP protocol version

**Verifying protocol compatibility:** Check the server's `package.json` for `@modelcontextprotocol/sdk` dependency version, or look for protocol version notes in the README.

### Quick Evaluation

```bash
# Check npm package health
npm view <package-name> time.modified
npm view <package-name> repository.url

# Check GitHub activity
gh repo view <owner/repo> --json stargazerCount,pushedAt
```
