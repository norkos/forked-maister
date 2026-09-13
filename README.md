<div align="center">

# Maister Fork

**Structured, standards-aware development workflows for Claude Code**

This is a security-hardened fork of [SkillPanel/maister](https://github.com/SkillPanel/maister) intended for use with private codebases on self-hosted model endpoints such as AWS Bedrock. It does not track upstream. Compared to upstream it removes the Playwright MCP server, browser-driven E2E verification and user-docs generation, the migration workflow, and the GitHub Copilot variant, and it binds the mockup preview server to localhost only. See [Security posture](#security-posture) below.

Describe what you want to build, and the plugin handles the rest - from specification through implementation to verification - while enforcing your project's coding standards at every step.

</div>

## What You Get

- **Guided workflows** for features, bug fixes, enhancements, performance, research, and product design
- **Auto-discovered standards** from your codebase - config files, source patterns, and documentation are analyzed and enforced throughout every workflow
- **Test-driven implementation** with automated planning, incremental verification, and full test suite runs before completion
- **Pause and resume** any workflow - state is preserved across sessions
- **Production readiness checks** including code review, reality assessment, and pragmatic over-engineering detection

## Getting Started

### Prerequisites

- [Claude Code](https://claude.ai/code) CLI installed and configured

### Installation

```bash
/plugin marketplace add norkos/forked-maister
/plugin install maister-fork@maister-fork
```

After installing, restart Claude Code (`/exit` and relaunch) to ensure the plugin is fully loaded.

### Initial project setup

Initialize your project to auto-detect coding standards and generate project documentation:

```bash
/maister-fork:init
```

This scans your codebase and creates `.maister/` with standards, docs, and task folders. May take a few minutes on larger projects.

If you have another project already using Maister, you can reuse its standards as a starting point:

```bash
/maister-fork:init --standards-from=/path/to/other-project
```

### First Workflow

```bash
/maister-fork:development Add user profile page with avatar upload
```

Or just discuss your task with Claude and then run:

```bash
/maister-fork:development
```

The plugin picks up context from your conversation - no arguments needed.

## How It Works

1. You describe a task - either as an argument or just in conversation
2. The plugin classifies it (feature, bug, enhancement, etc.) and proposes a workflow
3. You confirm, and it guides you through phases: **requirements → spec → plan → implement → verify**
4. At each phase, it asks for your input and decisions
5. You get tested, verified code with a detailed work log

All artifacts are saved in `.maister/tasks/` organized by type and date.

### Context-Aware Commands

Every workflow command works without arguments. The plugin reads your current conversation to extract the task description and auto-detect the task type:

```
You: "The login page throws a 500 error when the session expires"
You: /maister-fork:development
→ Auto-detects: bug fix, extracts description from conversation
```

```
You: /maister-fork:standards-update
→ Scans conversation for patterns like "we always use..." or "prefer X over Y"
```

You can always be explicit when you prefer - arguments and flags simply override the auto-detection.

## Supported Workflows

| Command | Use When |
|---------|----------|
| `/maister-fork:development` | Features, bug fixes, enhancements |
| `/maister-fork:research` | Research with synthesis and solution design |
| `/maister-fork:performance` | Optimizing speed or resource usage |
| `/maister-fork:product-design` | Product and feature design |

Task type (feature/bug/enhancement) is auto-detected from context. Override with `--type=feature|bug|enhancement` if needed. Or use `/maister-fork:work` as a single entry point that routes to the right workflow.

### Quick Commands

For smaller tasks that don't need a full workflow:

| Command | Use When |
|---------|----------|
| `/maister-fork:quick-plan` | You want a plan with standards awareness before coding |
| `/maister-fork:quick-dev` | You know what to do - just implement with standards applied |
| `/maister-fork:quick-bugfix` | Quick TDD-driven bug fix — write failing test, fix, verify |

## Standards-Aware Development

This is the key differentiator. Maister doesn't just run workflows - it learns your project's conventions and enforces them:

- **`/maister-fork:init`** scans config files, source code, and documentation to auto-detect your coding standards
- **Continuous checking** - standards are consulted before specification, during planning, and while coding (not just at the start)
- **`/maister-fork:standards-discover`** refreshes standards from your evolving codebase
- **`/maister-fork:standards-update`** lets you add or refine standards manually, or sync from another project with `--from=PATH`

Standards live in `.maister/docs/standards/` and are indexed in `.maister/docs/INDEX.md`.

**Important**: Run workflows with **auto-accept edits** enabled. Do not use Claude Code's plan mode with workflows (see [Best Practices](#best-practices) below).

## Upstream

This plugin is a fork of **Maister** by Marek Kaluzny (SkillPanel.com), originally published at [SkillPanel/maister](https://github.com/SkillPanel/maister) under the marketplace name `maister-plugins`. The fork was taken from upstream version **2.2.3** (commit `f75ef4f`) and renamed to `maister-fork` so it can coexist with, and never be confused for, the original. All credit for the workflow design belongs to the original author; this fork only removes and hardens components for use on private codebases.

## Differences from the original plugin

Every change below was made for one reason: this fork is used against private company code, on a self-hosted model endpoint, and nothing derived from that code may leave the machine except the model call itself. Features were removed rather than disabled so that a stray instruction cannot re-enable them.

| Area | Original (2.2.3) | This fork | Why |
|---|---|---|---|
| Playwright MCP server | `.mcp.json` ran `npx @playwright/mcp@latest` at every session start | Removed | Downloaded an unpinned package from public npm plus a Chromium build, and exposed `browser_navigate`, `browser_network_request`, and `browser_run_code_unsafe` to the model. Any of those could carry analyzed content to an arbitrary host, including through prompt injection from a file being analyzed. |
| E2E browser verification | `e2e-test-verifier` agent, development Phase 12, `--e2e` flag | Removed | Depended entirely on the Playwright MCP server. |
| User documentation generation | `user-docs-generator` agent, development Phase 13, `--user-docs` flag | Removed | Depended on Playwright for screenshots. The migration workflow's documentation step was already gone with the workflow itself. |
| Migration workflow | `/maister:migration` orchestrator with 8 phases | Removed; "migrate" and "upgrade" tasks route to the development workflow | Its current-state analysis instructed the model to run web searches for version upgrades, which would send internal library names and versions to a search provider. |
| Mockup preview server | Listened on all network interfaces, ports 3847 to 3850, no authentication | Binds to `127.0.0.1` only | Anyone on the same network could read every rendered mockup (derived from specs and requirements) and post or shut down screens. |
| Browser opening for mockups | Playwright MCP first, OS `open` command as fallback | OS `open` command only | Follows from removing Playwright. |
| GitHub Copilot CLI variant | Generated `plugins/maister-copilot/` plus `Makefile`, build script, and CI workflow | Removed | Duplicate surface to audit and keep in sync. Only Claude Code is used. |
| Destructive-command hook | Required `jq`; when `jq` was missing the guard silently allowed every command | Falls back to regex parsing when `jq` is absent | The guard must fail closed. A missing dependency should not disable a safety control without notice. |
| Model pinning | `project-analyzer` pinned `model: haiku` | `model: inherit` | On Bedrock the pinned alias may not be provisioned, and all subagents should run on the model the operator configured. |
| Task artifacts in git | Not addressed | `/maister-fork:init` adds `.maister/tasks/` to the project `.gitignore` | Task folders hold codebase analyses, specs, work logs, and verification reports. They should not be pushed to a remote by accident. |
| Identity | Plugin `maister`, marketplace `maister-plugins`, owner Skillpanel | Plugin and marketplace `maister-fork`, version 3.0.0, owner norkos | A distinct name and version guarantee Claude Code never serves the cached upstream copy and the two can never be confused on one machine. |
| Beta channel | `beta` branch with squash-merge release flow | Removed | The fork does not track upstream. Single `master` branch. |

**What is deliberately unchanged**: the development, performance, research, and product-design workflows; all standards discovery; all verification agents; the operator dashboard and HTML companion reports; the `.maister/` directory layout.

**What is left to the operator** (see Security posture below): the `WebSearch` and `WebFetch` tools and the `gh`, `az`, `jira`, and `acli` command-line tools are still mentioned by a few workflows and must be denied through permission settings if outbound access is not wanted.

## Security posture

This fork is meant to run against internal code without sending anything outside your environment beyond the model call itself.

**What the plugin never does**: no telemetry, no analytics, no remote endpoints, no CDN-loaded scripts, no MCP servers. Hook scripts and the mockup preview server are local-only and contain no network calls. All workflow artifacts are written under `.maister/` inside the analyzed repository, and `/maister-fork:init` adds `.maister/tasks/` to the project's `.gitignore`.

**What still needs a permission rule**: a few workflows instruct the model to use the `WebSearch` and `WebFetch` tools (research with external sources, product-design link fetching, issue URL lookup) or issue-tracker CLIs (`gh`, `az`, `jira`, `acli`). Deny them in the settings you deploy with the plugin if outbound access is not wanted:

```json
{
  "permissions": {
    "deny": ["WebSearch", "WebFetch", "Bash(gh *)", "Bash(az *)", "Bash(jira *)", "Bash(acli *)"]
  }
}
```

**Recommended**: install `jq` on the host so the destructive-command hook uses exact JSON parsing (a regex fallback is used otherwise).

## Best Practices

**Don't use plan mode when starting a workflow.** Planning is a built-in part of every workflow — the orchestrator creates specs, plans, and other files as it goes. Claude Code's plan mode restricts file creation, which conflicts with this. Let the workflow handle planning on its own.

**Start workflows in a fresh session.** This is especially useful when chaining workflows (e.g., research → development). Research and product-design artifacts already contain all the context needed, so a clean session avoids noise from prior conversation.

**Chain workflows by passing a task folder.** If you've completed a research or product-design workflow and want to build on those results, pass the task folder directly:

```bash
/maister-fork:development .maister/tasks/research/2026-01-12-oauth-research
```

You can also append additional instructions to narrow scope or guide the workflow:

```bash
/maister-fork:development .maister/tasks/product-design/2026-03-10-dashboard-redesign Implement only phase 1
```

## Known Issues

**Orchestrator may stall after long phases.** After context compaction (which typically happens after lengthy phases like implementation), the main agent may stop progressing automatically. If you notice it's idle, just type something like "continue" or "proceed" — it will pick up where it left off. You can also re-invoke the workflow in resume mode to reload the orchestrator state:

```bash
/maister-fork:development .maister/tasks/development/2026-03-24-my-feature
```

## License

MIT. The original work is copyright Marek Kaluzny (SkillPanel.com) and Maister contributors; the modifications in this fork are copyright norkos. See [LICENSE](LICENSE). This fork is independent and is not endorsed by the original author.

## Learn More

- [Workflow Details](docs/workflows.md) - phases, examples, and task structure for each workflow type
- [Full Command Reference](docs/commands.md) - all workflow, review, utility, and quick commands
