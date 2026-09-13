# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

This is a Claude Code plugin marketplace repository containing bundled plugins for AI-driven SDLC workflows. The main plugin is `maister` which provides structured development workflows.

## Structure

```
.claude-plugin/marketplace.json    # Marketplace manifest (lists all plugins)
plugins/
└── maister/                       # Main plugin
    ├── .claude-plugin/plugin.json # Plugin manifest
    ├── CLAUDE.md                  # Detailed plugin documentation (READ THIS)
    ├── agents/                    # Subagent definitions (*.md)
    ├── commands/                  # Slash commands (organized by workflow type)
    └── skills/                    # Skills with SKILL.md entry points
docs/                              # User-facing documentation and guides
```

## Key Files

- **`@plugins/maister-fork/CLAUDE.md`**: Comprehensive plugin documentation with all skills, commands, agents, and workflow principles. Read this when working on plugin internals.
- **`README.md`**: User-facing documentation for plugin consumers.

## Plugin Development

### Adding a New Skill

1. Create directory: `plugins/maister-fork/skills/[skill-name]/`
2. Create `SKILL.md` with workflow phases and execution instructions
3. Optionally add `references/` directory for supporting documentation
4. Document in `@plugins/maister-fork/CLAUDE.md` under "Available Skills"

### Adding a New Command

1. Create markdown file: `plugins/maister-fork/commands/[category]/[command].md`
2. Commands are thin wrappers that invoke skills
3. Document in `plugins/maister-fork/CLAUDE.md` under "Available Commands"

### Adding a New Agent

1. Create markdown file: `plugins/maister-fork/agents/[agent-name].md`
2. Define agent purpose, tools, and workflow
3. Document in `plugins/maister-fork/CLAUDE.md` under "Available Subagents"

## Documentation Principles

This plugin follows specific documentation guidelines (see @plugins/maister-fork/CLAUDE.md section "Plugin Documentation Principles"):

- Trust Claude to reason—provide principles, not prescriptive implementations
- Commands are thin wrappers; orchestration logic lives in skills
- Reference files guide implementation, not provide complete code
- Single source of truth: technical details in `SKILL.md`, not scattered across files

## Fork and Release Management

This repository is a security-hardened fork of `SkillPanel/maister` (upstream version 2.2.3, commit `f75ef4f`, original author Skillpanel), renamed to `maister-fork`. The original attribution is kept in README.md § Upstream. It does **not** track upstream. Do not merge upstream changes without re-running the security review (see README "Security posture"). There is no beta branch; all work lands on `master`.

### Releasing a new version

Claude Code caches installed plugins by version, so every change that should reach users needs a version bump in both manifest files, in a separate commit:
- `.claude-plugin/marketplace.json` — `version` (marketplace name stays `maister-fork`)
- `plugins/maister-fork/.claude-plugin/plugin.json` — `version`

After bumping, reinstall the plugin (or clear `~/.claude/plugins/cache/maister-fork/`) so the new version is picked up.

## Testing Changes

1. Navigate to a test project
2. Run `/maister-fork:init` to initialize the framework
3. Test commands like `/maister-fork:development "test feature"`
4. Test workflows with different task types and complexity levels
