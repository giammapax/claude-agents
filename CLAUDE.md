# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this repo is

A version-controlled backup of Claude Code **subagent definitions**. It is not application code — there is nothing to build, lint, or test. Each agent is a single Markdown file (YAML frontmatter + prompt body) that Claude Code loads as a custom subagent. Currently the only agent is `sap-troubleshooter.md`.

The repo is a **mirror** of `~/.claude/agents/`, kept in sync by `sync-agents.sh`.

## Sync workflow

`sync-agents.sh` is the pipeline that populates and publishes this repo:

1. `rsync` copies `~/.claude/agents/` → this repo (the repo is a downstream copy; the live agents dir is the source).
2. Stages everything, then runs a **security guard**: if any staged path matches `vps[-_]config`, `id_ed25519`, `id_rsa`, `*.pem`, `*.key`, or `secret`, it aborts the push and unstages. This guard is the reason the script exists — never weaken or bypass it, and never commit VPS configs or secrets here.
3. Commits (`Auto-sync agents <date>`) and pushes.

Run it (typically via cron/daily) with:

```bash
./sync-agents.sh
```

Because the repo is downstream of `~/.claude/agents/`, edits made directly here will be **overwritten** on the next sync unless the same change is also made to the live agent file. When editing an agent, treat `~/.claude/agents/<name>.md` as the source of truth.

## Editing agent definitions

An agent file's frontmatter drives how Claude Code loads it. Valid fields: `name`, `description`, `tools` (comma-separated allow-list — omitting it grants all tools), `model`, `color`, `memory`. Keep `description` in the "use this agent when…" form with concrete examples — it's what the router matches on.

Guardrails learned from prior work on `sap-troubleshooter.md`:

- **Preserve diagnostic structure verbatim.** The L1–L5 layer table, D-Change/D-Data dimensions, the Phase 0–4b workflow, the SAP Note & KBA Verification Workflow, the Uncertainty Protocol, and Edge Case Handling are load-bearing. Touch frontmatter, the intro, and Interaction Modes; leave the analytical scaffolding alone unless that's the explicit task.
- **Don't re-add memory boilerplate.** When `memory: local` is set, the platform injects memory instructions automatically — the prompt body should not restate them.
- The agent has **no live SAP access** by design; never add or imply system connectivity.

## Change methodology (superpowers / SDD)

Non-trivial agent changes go through the **superpowers subagent-driven-development (SDD)** flow rather than ad-hoc edits:

- Design specs live in `docs/superpowers/specs/`, implementation plans in `docs/superpowers/plans/` (dated, task-by-task with `- [ ]` checkboxes).
- SDD working artifacts (task briefs, reports, per-commit review diffs, `progress.md` ledger) live in `.superpowers/sdd/`.
- Convention: one commit per plan task, and commit directly to `main` (the branch the daily auto-sync uses). Reserve manual commits for deliberate work; the dated `Auto-sync agents` commits are machine-generated.
