# Label Management

This directory contains the canonical label configuration for the repository.

## Files

- **labels.yml**: Source of truth for all repository labels
- **sync-labels.sh**: Script for manual label syncing (helper/documentation)
- **workflows/sync-labels.yml**: Automated workflow that syncs label definitions on push to main
- **workflows/semantic-labeler.yml**: Claude-powered workflow that applies labels to issues and PRs

## Label Categories

### Type Labels

Default GitHub labels for issue/PR classification:
- `bug`, `documentation`, `duplicate`, `enhancement`, `invalid`, `question`, `refactor`, `chore`, `wontfix`

### Component Labels

Identify which part of the codebase:
- `component:agent`, `component:command`, `component:docs`, `component:hook`, `component:skill`

### Priority Labels

Urgency classification:
- `priority:critical`, `priority:high`, `priority:medium`, `priority:low`

### Status Labels

Current state of work:
- `status:blocked`, `status:in-progress`, `status:needs-repro`, `status:needs-review`

### Effort Labels

Time estimates:
- `effort:small` (< 1 hour), `effort:medium` (1-4 hours), `effort:large` (> 4 hours)

### Community, Dependency, and Special Labels

**Community**:
- `good first issue` - Good for newcomers
- `help wanted` - Extra attention needed

**Dependency** (Dependabot):
- `dependencies` - Dependency file updates
- `github-actions` - GitHub Actions updates

**Special**:
- `experiment` - Testing/experimental changes
- `pinned` - Never mark as stale
- `reverted` - Merged but later reverted from codebase
- `security` - Security-related issues
- `stale` - No recent activity (auto-applied by stale workflow)

**Category** (type of change):
- `breaking` - Breaking change requiring major version bump
- `automation` - CI/CD and workflow automation improvements
- `optimization` - Performance and efficiency improvements

### Discussion Labels

Labels for GitHub Discussions categories:
- `idea` - Feature idea or suggestion
- `showcase` - Community showcase

## Automatic Label Application

Labels are automatically applied to issues and PRs using Claude-powered semantic analysis.

### How It Works

The `semantic-labeler.yml` workflow:

- **Triggers on**: Issues (opened, edited) and PRs (opened, synchronize, edited)
- **Analyzes**: Title, body, and for PRs, the diff
- **Applies**: Type, component, priority, effort, and impact labels

### Labels Applied Automatically

| Category | Labels | Required |
|----------|--------|----------|
| Type | bug, enhancement, documentation, question, refactor, chore | Yes (one) |
| Component | component:\*, github-actions, dependencies | If applicable |
| Priority | priority:critical/high/medium/low | Yes (one) |
| Effort | effort:small/medium/large | Yes (one) |
| Impact | breaking, security | If applicable |
| Community | good first issue, help wanted | If applicable |

### Differences from Previous Labeler

The semantic labeler replaces the old `actions/labeler` which only applied labels based on file paths:

| Aspect | Old (path-based) | New (semantic) |
|--------|------------------|----------------|
| Issues | Not supported | Full support |
| Content understanding | File paths only | Semantic analysis |
| Priority/effort | Manual only | Automatic |
| Speed | ~5 seconds | ~30-60 seconds |

### Skipped Cases

The workflow skips:

- Bot-created issues/PRs (dependabot, claude)
- Draft PRs
- Fork PRs (for security - secrets not exposed)

## Managing Labels

### Adding a New Label

1. **Update labels.yml** (source of truth):
   ```yaml
   - name: "new-label"
     color: "ff6ec7"
     description: "Description here"
   ```

2. **Create a PR** - the workflow runs in dry-run mode to preview the new label

3. **Merge to main** - the label is created automatically

   Or apply manually:
   ```bash
   gh label create "new-label" --color "ff6ec7" --description "Description here"
   ```

### Updating a Label

1. **Update labels.yml** (source of truth):
   ```yaml
   - name: "label-name"
     color: "new-color"
     description: "new description"
   ```

2. **Create a PR** - the workflow runs in dry-run mode to preview changes

3. **Merge to main** - the label is updated automatically

   Or apply manually:
   ```bash
   gh label edit "label-name" --color "new-color" --description "new description"
   ```

### Deleting a Label

Deleting labels requires manual action - the automated workflow only creates and updates labels (never deletes) for safety.

1. **Remove from labels.yml** (source of truth)

2. **Delete from GitHub manually**:
   ```bash
   gh label delete "label-name" --yes
   ```

3. **Commit** labels.yml changes

### Syncing All Labels

Labels are **automatically synced** when changes to `labels.yml` are pushed to main.

- **PR preview**: When you open a PR that modifies `labels.yml`, the workflow runs in dry-run mode to show what changes would be applied.
- **Automatic sync**: When the PR is merged to main, changes are applied automatically.
- **Manual sync**: Use the GitHub CLI (see sync-labels.sh for guidance) or trigger the workflow manually via GitHub Actions > Sync Labels > Run workflow.

## Label Naming Convention

- **Custom labels**: Use hyphens (`-`) not underscores (`_`) for multi-word labels
- **Default GitHub labels**: Keep spaces as-is (`good first issue`, `help wanted`) for ecosystem compatibility
- Use lowercase
- Use colons (`:`) for category prefixes (`component:`, `priority:`, `status:`, `effort:`)
- Keep names concise and descriptive

## Best Practices

1. **labels.yml is the source of truth** - always update it when changing labels
2. **Use consistent colors** within categories (e.g., component labels use cool colors: blues, purples, and teals)
3. **Keep descriptions clear** - they appear in the label picker
4. **Don't create too many labels** - aim for 25-35 total
5. **Archive unused labels** rather than delete (consider dependencies)

## Label Count

The repository maintains a balanced set of labels - enough for good organization without overwhelming contributors. Check `labels.yml` for the current complete list.
