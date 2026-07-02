# Design: Improve the `sap-troubleshooter` agent

**Date:** 2026-07-02
**Scope:** Moderate rewrite of the single `sap-troubleshooter.md` agent (no new agents, no live SAP connectivity).

## Motivation

The current agent is functionally strong (two-axis L1–L5 diagnostic model, phased
workflow, SAP Note verification, uncertainty protocol, interaction modes) but has three
problems the user identified:

1. **Passive** — it interrogates the user one question at a time and depends on the human
   to run every T-code and paste results back. It doesn't do its own homework.
2. **Persona padding** — reads like a character sheet ("elite expert, 20 years").
3. **Format / file shape** — feels machine-generated and bloated.

Hard constraint: **the agent has no access to a live SAP system.** "Active" must mean
active *with the tools it actually has* (web research, reading pasted logs/files, memory,
reasoning) — never faking system actions it cannot perform.

## Findings that shape the design (verified against official Claude Code subagent docs)

- **Frontmatter is not broken.** `memory: local`, `color: blue`, and `model: sonnet` are
  all valid optional fields. There is no invalid-field problem to fix.
- **~137 lines of the body are redundant.** Lines 247–384 hand-write memory-system
  instructions. When `memory: local` is set, the platform **automatically** injects
  memory read/write instructions and the first 200 lines of `MEMORY.md`, and auto-enables
  Read/Write/Edit. This entire block duplicates a built-in feature and can be deleted with
  zero capability loss. **This is where "too long" actually lives** — not in the diagnostic
  rigor and not in the persona prose (a token rounding error).
- **The real "shape" problem is the `description`.** Line 3 is a single-line escaped-JSON
  blob with literal `\n\n` sequences. It should be clean YAML text.
- **`tools` is omitted** → the agent inherits every tool. Decision: lock it down.

## Design

### 1. Fix file shape

- Rewrite the `description` as clean YAML text: one tight "use when" sentence plus the
  three routing examples in readable form (examples are kept — they help Claude route to
  this agent correctly).
- Add an explicit `tools:` grant limited to what the agent genuinely needs:
  `Read, Write, Edit, WebSearch, WebFetch, Glob, Grep`.
  Rationale: a diagnostic advisor should have web research, log/file reading, and memory —
  and nothing (Bash, arbitrary edits) that would invite it to fake system actions.
  Read/Write/Edit are also required by the memory feature.
- Delete the redundant memory boilerplate (lines 247–384). Replace with a single line:
  "Consult your memory before diagnosing and update it after resolving recurring patterns."
  The platform injects the rest.

### 2. Make it active — investigator, not interrogator

Add a concise section near the top establishing the operating stance:

- **Parse-first mandate.** Given any pasted dump/log, extract everything it contains
  (exception class, include, program, line, component, timestamps, correlated entries)
  *before* asking a single question. Never ask the user to re-supply information already
  present in what they pasted.
- **Autonomous research.** Proactively run the existing SAP Note/KBA `WebSearch`/`WebFetch`
  verification workflow itself. Do not ask the user to go look up Notes.
- **Honest delegation.** State plainly that the agent has no live SAP access. The *only*
  things it asks the human to perform are the T-code checks it physically cannot run —
  delivered as **one consolidated worklist**, not drip-fed one at a time.

### 3. Preserve rigor; map "active" onto the existing mode axis

- Keep intact: the L1–L5 structural model + D-Change/D-Data dimensions, the phased
  workflow (Compass → Triage → Investigation → RCA → Verification → Resolution), the SAP
  Note & KBA verification discipline, the entry-point-by-locus table, and the uncertainty
  protocol.
- Route the batched-worklist behavior through **expert mode**; keep **guided mode**
  incremental. Rationale: the agent already has a guided/expert axis, and
  "one or two questions at a time" (Core Operating Principle #3) is a deliberate choice for
  confused generalists. Reusing the existing axis avoids contradicting it. Update the
  Interaction Modes section so expert mode explicitly means "parse-first, auto-research,
  hand over a single worklist."

### 4. Trim persona flavor

Lightly reduce the "elite expert, 20 years" framing to a crisp capability statement. Low
token impact but removes the character-sheet feel the user flagged.

## Out of scope

- No new/sibling agents; no fleet decomposition.
- No live SAP connectivity (MCP/RFC/OData). The no-access constraint is treated as a
  permanent design condition, made explicit in the prompt.
- No changes to `sync-agents.sh` or the auto-sync workflow.

## Success criteria

- File is meaningfully shorter (redundant memory block gone) with **no loss** of diagnostic
  capability.
- `description` is clean YAML; `tools` grant present and limited.
- The prompt instructs the agent to parse pasted input and research Notes on its own before
  querying the user, and to batch its human-side asks in expert mode.
- All existing diagnostic structure (L1–L5, phases, entry-point table, Note workflow,
  uncertainty protocol) remains.
- The agent still loads and functions as a Claude Code subagent.
