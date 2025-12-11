---
description: Create plugin marketplaces with guided workflow
argument-hint: [marketplace-description]
allowed-tools: Read, Write, Edit, Grep, Glob, Bash(mkdir:*), Bash(git init:*), TodoWrite, AskUserQuestion, Skill, Task
---

# Marketplace Creation Workflow

Guide the user through creating a complete plugin marketplace from initial concept to validated, distributable collection. Follow a systematic approach: understand requirements, plan plugins, configure structure, add entries, validate, and prepare for distribution.

## Core Principles

- **Ask clarifying questions**: Identify all ambiguities about marketplace purpose, plugins, distribution strategy. Ask specific questions rather than making assumptions. Wait for user answers before proceeding.
- **Load marketplace-structure skill**: Use the Skill tool to load the marketplace-structure skill for schema and pattern guidance
- **Use plugin-validator agent**: Leverage the plugin-validator agent for comprehensive marketplace validation
- **Follow best practices**: Apply patterns from this repository's own marketplace.json
- **Use TodoWrite**: Track all progress throughout all phases

**Initial request:** $ARGUMENTS

---

## Phase 1: Discovery

**Goal**: Understand what marketplace needs to be created and its purpose

**Actions**:

1. Create todo list with all 8 phases
2. If marketplace purpose is clear from arguments:
   - Summarize understanding
   - Identify marketplace type (team internal, community, single-plugin, multi-plugin)
3. If marketplace purpose is unclear, ask user:
   - What plugins will this marketplace contain?
   - Who is the target audience? (team, community, public)
   - Will plugins be local (in same repo) or external (GitHub, git URLs)?
   - Single maintainer or community contributions?
4. Summarize understanding and confirm with user before proceeding

**Output**: Clear statement of marketplace purpose and distribution strategy

---

## Phase 2: Plugin Planning

**Goal**: Determine which plugins to include and their sources

**MUST load marketplace-structure skill** using Skill tool before this phase.

**Actions**:

1. Load marketplace-structure skill for schema guidance
2. List plugins to include in marketplace:
   - For each plugin: name, source type, brief description
3. Categorize by source type:
   - **Local (relative path)**: Plugins maintained in same repository
   - **GitHub**: External plugins on GitHub
   - **Git URL**: External plugins on GitLab, Bitbucket, or self-hosted
4. Present plugin plan to user as table:

   ```text
   | Plugin Name      | Source Type | Description            |
   |------------------|-------------|------------------------|
   | code-formatter   | local       | Code formatting tools  |
   | security-scanner | github      | Security analysis      |
   | legacy-tool      | git-url     | Legacy utility         |
   ```

5. For each local plugin, determine:
   - Does it already exist? (will validate)
   - Need to create it? (redirect to /plugin-dev:create-plugin)
6. Get user confirmation or adjustments

**Output**: Confirmed list of plugins with sources

---

## Phase 3: Metadata Design

**Goal**: Define marketplace metadata and owner information

**Actions**:

1. Determine marketplace name:
   - Must be kebab-case (lowercase, hyphens)
   - Should be descriptive of purpose
   - Examples: `team-tools`, `security-plugins`, `awesome-claude-plugins`

2. Gather owner information:
   - Ask user: "Who maintains this marketplace?"
   - Required: name
   - Optional: email, url

3. Define optional metadata:
   - description: Brief marketplace description
   - version: Initial version (recommend 1.0.0 or 0.1.0)
   - pluginRoot: Base path for relative sources (default: none)

4. Present configuration summary:

   ```json
   {
     "name": "team-tools",
     "owner": {
       "name": "Platform Team",
       "email": "platform@company.com"
     },
     "metadata": {
       "description": "Internal development tools",
       "version": "1.0.0"
     }
   }
   ```

5. Get user confirmation

**Output**: Confirmed marketplace metadata

---

## Phase 4: Structure Creation

**Goal**: Create marketplace directory structure and manifest

**Actions**:

1. Determine marketplace location:
   - Ask user: "Where should I create the marketplace?"
   - Offer options: current directory, new directory, custom path

2. Create directory structure using bash:

   ```bash
   mkdir -p marketplace-name/.claude-plugin
   mkdir -p marketplace-name/plugins  # if local plugins
   ```

3. Create marketplace.json manifest using Write tool:

   ```json
   {
     "name": "marketplace-name",
     "owner": {
       "name": "[from Phase 3]"
     },
     "metadata": {
       "description": "[from Phase 3]",
       "version": "[from Phase 3]"
     },
     "plugins": []
   }
   ```

4. Create README.md template with:
   - Marketplace description
   - Installation instructions
   - Available plugins table (to be filled in Phase 5)
   - Contributing guidelines (if community)

5. Initialize git repo if creating new directory (only `git init` is available; additional git operations like staging and committing are left to the user after the workflow completes to respect their commit preferences)

**Output**: Marketplace directory structure created

**Post-workflow git operations** (user can run after completion):

```bash
git add .
git commit -m "feat: initial marketplace structure"
```

---

## Phase 5: Plugin Entry Configuration

**Goal**: Configure each plugin entry with appropriate metadata

**Actions**:

1. For each plugin in the plan (from Phase 2):

   **For local plugins**:

   - If plugin exists:
     - Read its plugin.json to get metadata
     - Create entry with relative source path
   - If plugin doesn't exist:
     - Ask: "Plugin 'X' doesn't exist. Create it now or add placeholder?"
     - If create: Use Task tool to run /plugin-dev:create-plugin
     - If placeholder: Create entry with TODO comment in README

   **For GitHub plugins**:

   - Create entry with github source object
   - Prompt for version, description if not known
   - Consider strict: false if plugin lacks plugin.json

   **For git URL plugins**:

   - Create entry with url source object
   - Prompt for version, description if not known

2. For each entry, configure optional fields:
   - version (recommend always including)
   - description (recommend always including)
   - category (if marketplace uses categories)
   - tags (for discoverability)

3. Update marketplace.json with all plugin entries

4. Update README.md with plugin table:

   | Plugin | Description | Version |
   |--------|-------------|---------|
   | X      | Does Y      | 1.0.0   |

**Output**: All plugin entries configured in marketplace.json

---

## Phase 6: Distribution Setup

**Goal**: Configure distribution strategy based on target audience

**Actions**:

1. **For team/internal marketplaces**:
   - Provide team settings configuration:

     ```json
     {
       "extraKnownMarketplaces": {
         "marketplace-name": {
           "source": {
             "source": "github",
             "repo": "org/marketplace-repo"
           }
         }
       }
     }
     ```

   - Document which plugins should be in `enabledPlugins`
   - Add to README: How team members install

2. **For community/public marketplaces**:
   - Create CONTRIBUTING.md with:
     - Plugin submission guidelines
     - Review process
     - Quality requirements
   - Create CI workflow for validation (optional):
     - JSON syntax check
     - Required field validation
     - Duplicate name detection

3. **For all marketplaces**:
   - Document installation command in README:

     ```bash
     /plugin marketplace add owner/repo
     ```

   - List individual plugin installation:

     ```bash
     /plugin install plugin-name@marketplace-name
     ```

**Output**: Distribution documentation complete

---

## Phase 7: Validation

**Goal**: Ensure marketplace meets quality standards

**Actions**:

1. **Run plugin-validator agent**:
   - Use plugin-validator agent to validate marketplace
   - Check: schema, required fields, plugin entries, source paths

2. **Fix critical issues**:
   - Address any critical errors from validation
   - Fix warnings that indicate real problems

3. **Validate local plugins** (if any):
   - For each local plugin, run plugin validation
   - Fix any issues found

4. **Check best practices**:
   - All entries have version
   - All entries have description
   - README documents all plugins
   - Owner information complete

5. **Present validation report**:
   - Summary of marketplace validation
   - Summary of each local plugin validation
   - Overall quality assessment

6. **Ask user**: "Validation complete. Would you like me to fix any issues, or proceed to testing?"

**Output**: Marketplace validated and ready for testing

---

## Phase 8: Testing & Finalization

**Goal**: Test marketplace installation and finalize

**Actions**:

1. **Test locally**:
   - Show user how to test:

     ```bash
     /plugin marketplace add ./path/to/marketplace
     ```

   - List marketplace:

     ```bash
     /plugin marketplace list
     ```

   - Install test plugin:

     ```bash
     /plugin install plugin-name@marketplace-name
     ```

2. **Verification checklist**:
   - [ ] Marketplace adds successfully
   - [ ] All plugins appear in `/plugin` browser
   - [ ] Local plugins install correctly
   - [ ] External plugins accessible (if public)

3. **Create summary**:
   - Mark all todos complete
   - List what was created:
     - Marketplace name and purpose
     - Number of plugins configured
     - Distribution strategy
     - Key files created
   - Next steps:
     - Push to GitHub/git hosting
     - Share with team
     - Add to project settings

4. **Suggest improvements** (optional):
   - Additional plugins to consider
   - CI/CD integration opportunities
   - Version management strategies

**Output**: Complete, validated marketplace ready for distribution

---

## Important Notes

### Throughout All Phases

- **Use TodoWrite** to track progress at every phase
- **Load marketplace-structure skill** for schema reference
- **Use plugin-validator agent** for validation
- **Ask for user confirmation** at key decision points
- **Follow this repository's marketplace.json** as reference
- **Apply best practices**:
  - kebab-case names
  - Complete owner information
  - Version all entries
  - Document all plugins in README
  - ${CLAUDE_PLUGIN_ROOT} for local plugin paths

### Key Decision Points (Wait for User)

1. After Phase 1: Confirm marketplace purpose
2. After Phase 2: Approve plugin plan
3. After Phase 3: Confirm metadata
4. After Phase 5: Proceed to distribution setup
5. After Phase 7: Fix issues or proceed

### Skills to Load

- **Phase 2+**: marketplace-structure (for schema and patterns)
- **Phase 5**: plugin-structure (if creating local plugins)

### Quality Standards

Every marketplace must meet these standards:

- ✅ Valid JSON syntax
- ✅ All required fields present (name, owner, plugins)
- ✅ Plugin entries have name and source
- ✅ No duplicate plugin names
- ✅ Local source paths exist
- ✅ README documents marketplace and plugins
- ✅ Validated with plugin-validator agent

---

## Example Workflow

### User Request

"Create a marketplace for our team's internal tools"

### Phase 1: Discovery

- Understand: Internal team distribution
- Confirm: Team-only plugins, GitHub hosting

### Phase 2: Plugin Planning

- 3 plugins: linter-config (local), security-scanner (local), docs-generator (github)

### Phase 3: Metadata

- name: team-tools
- owner: Platform Team
- version: 1.0.0

### Phase 4-8: Structure, Entries, Distribution, Validation, Testing

---

Begin with Phase 1: Discovery.
