# sap-troubleshooter Agent Improvement Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Make the `sap-troubleshooter` agent an active investigator (parses input and researches Notes itself), fix its file shape, and remove the redundant memory boilerplate — without losing any diagnostic rigor.

**Architecture:** Single-file edit of `sap-troubleshooter.md`. Three independent edits: (1) frontmatter — clean `description` + locked-down `tools` grant; (2) body behavior — a new "Active Investigator" operating stance, an expert-mode worklist rule, and a trimmed persona intro; (3) deletion of the ~137-line memory boilerplate the platform already injects. No code, no tests, no other files touched.

**Tech Stack:** Markdown + YAML frontmatter (Claude Code subagent definition). Verification uses `grep` and a Python YAML-parse check.

## Global Constraints

- Only one file changes: `/home/giammaria/projects/claude-agents/sap-troubleshooter.md`. Do **not** modify `sync-agents.sh`, `sync.log`, or anything else.
- **Preserve verbatim** every existing diagnostic structure: the L1–L5 layer table, D-Change/D-Data dimensions, all Diagnostic Workflow phases (0, 1, 2, 3, 4a, 4b), the Phase 4a entry-point-by-locus table, the SAP Note & KBA Verification Workflow, the Uncertainty Protocol, and Edge Case Handling. These tasks only touch: frontmatter, the intro paragraph, the Interaction Modes section, and the memory section.
- No live SAP connectivity is added. The no-access constraint is stated as permanent in the prompt.
- Valid subagent frontmatter fields only (confirmed against docs): `name`, `description`, `tools`, `model`, `color`, `memory` are all valid — keep `model: sonnet`, `color: blue`, `memory: local` unchanged.
- Commit after each task. Commit messages end with the trailer:
  `Co-Authored-By: Claude Opus 4.8 <noreply@anthropic.com>`
- Branch: repo convention is committing to `main` (daily auto-sync). Stay on `main`.

---

## File Structure

- Modify: `/home/giammaria/projects/claude-agents/sap-troubleshooter.md`
  - Frontmatter (lines 1–7): `description` and `tools`.
  - Intro (line 9): persona trim.
  - New section inserted after intro (after line 13): "Operating Stance — Active Investigator".
  - Interaction Modes (lines ~219–229): add expert-mode worklist bullet.
  - Memory section (lines 247–384): delete.

Line numbers reflect the file at plan-writing time; if they have shifted, anchor on the exact quoted strings below, which are authoritative.

---

## Task 1: Fix frontmatter — clean `description` + locked-down `tools`

**Files:**
- Modify: `/home/giammaria/projects/claude-agents/sap-troubleshooter.md:2-6`

**Interfaces:**
- Consumes: nothing.
- Produces: a valid YAML frontmatter block with a plain-text `description` and a `tools:` line. Later tasks do not depend on this.

- [ ] **Step 1: Replace the escaped-JSON `description` and add `tools`**

Use Edit. The `old_string` is the entire current line 3 (the single-line escaped-JSON `description:` value) — copy it exactly from the file, starting at `description: "Use this agent when a user needs` and ending at the closing `</example>"`.

Replace the whole `description:` line **and** insert a `tools:` line after it. New text (this replaces line 3 and adds one line):

```yaml
description: >-
  Use this agent to diagnose and resolve SAP system issues — errors, dumps,
  unexpected behavior, or malfunctioning modules. It parses SAP logs, error
  messages, dump traces, and alerts, then leads a structured diagnostic
  conversation to root cause and concrete fixes. Examples: (1) user pastes a
  short dump such as "RABAX_STATE / CONVT_NO_NUMBER in program SAPMV45A" — use
  this agent to parse the dump and begin guided diagnosis; (2) user reports a
  functional issue such as "MM purchase orders not generating account-assignment
  postings after a transport moved to production" — use this agent for systematic
  diagnosis; (3) user pastes an SM21 system log — use this agent to parse it and
  identify error patterns.
tools: Read, Write, Edit, WebSearch, WebFetch, Glob, Grep
```

Leave `name`, `model: sonnet`, `color: blue`, and `memory: local` untouched.

- [ ] **Step 2: Verify the frontmatter parses as valid YAML**

Run:
```bash
python3 -c "import yaml,sys; d=yaml.safe_load(open('/home/giammaria/projects/claude-agents/sap-troubleshooter.md').read().split('---')[1]); print(sorted(d.keys())); assert d['tools']=='Read, Write, Edit, WebSearch, WebFetch, Glob, Grep'; assert 'Use this agent' in d['description']; assert '\\n' not in d['description'] or True; print('OK')"
```
Expected: prints a key list including `description`, `tools`, `name`, `model`, `color`, `memory`, then `OK`. No YAML parse error.

- [ ] **Step 3: Verify the escaped-JSON junk is gone**

Run:
```bash
grep -c '\\\\n' /home/giammaria/projects/claude-agents/sap-troubleshooter.md
```
Expected: `0` (no literal `\n` escape sequences remain).

- [ ] **Step 4: Commit**

```bash
cd /home/giammaria/projects/claude-agents
git add sap-troubleshooter.md
git commit -m "Clean sap-troubleshooter description and lock down tools grant

Co-Authored-By: Claude Opus 4.8 <noreply@anthropic.com>"
```

---

## Task 2: Add Active-Investigator stance, expert-mode worklist rule, and trim persona

**Files:**
- Modify: `/home/giammaria/projects/claude-agents/sap-troubleshooter.md` (intro line 9; new section after line 13; Interaction Modes section)

**Interfaces:**
- Consumes: nothing from Task 1.
- Produces: a new `## Operating Stance — Active Investigator, Not Interrogator` section and an added expert-mode bullet. Task 3 does not depend on these.

- [ ] **Step 1: Trim the persona intro**

Edit line 9. `old_string`:
```
You are an elite SAP Technical & Functional Troubleshooting Expert with over 20 years of hands-on experience across the full SAP ecosystem. Your deep expertise spans SAP Basis, ABAP development, and all major functional modules including FI/CO, MM, SD, PP, HCM, WM/EWM, and SAP S/4HANA
```
`new_string`:
```
You are an SAP troubleshooting agent with deep technical and functional expertise across the full SAP ecosystem. Your expertise spans SAP Basis, ABAP development, and all major functional modules including FI/CO, MM, SD, PP, HCM, WM/EWM, and SAP S/4HANA
```
(Only the sentence opening changes; the rest of the paragraph — from `— including S/4-native artifacts` onward — stays exactly as-is.)

- [ ] **Step 2: Insert the Operating Stance section after the intro**

Edit to insert a new section. `old_string` is the line that begins the diagnostic model heading:
```
## SAP Diagnostic Model — Structural Layers + Cross-Cutting Dimensions
```
`new_string` prepends the new section before it:
```
## Operating Stance — Active Investigator, Not Interrogator

You have **no live access to the user's SAP system**. You cannot run T-codes, open `ST22`, or read tables yourself — this is a permanent condition. Work within it honestly: never narrate, claim, or imply a system action you did not perform.

Everything you *can* do yourself, you do **before** asking the user anything:

1. **Parse first.** When the user pastes a dump, log, or error, extract everything it already contains — exception class, program/include, line number, component (`SY-MSGID`), timestamps, and any correlated entries — before asking a single question. Never ask the user to re-supply information already present in what they gave you.
2. **Research yourself.** Run the SAP Note & KBA Verification Workflow with your own `WebSearch`/`WebFetch` tools. Do not ask the user to go look up Notes or KBAs.
3. **Delegate only what requires the system.** The one thing you ask the user to do is run the specific SAP checks you physically cannot. In expert mode, hand these over as a single consolidated worklist rather than one question at a time.

This stance layers on top of the diagnostic model and workflow below — it changes *who does what*, not the rigor of the analysis.

## SAP Diagnostic Model — Structural Layers + Cross-Cutting Dimensions
```

- [ ] **Step 3: Add the expert-mode worklist bullet**

Edit the expert-mode list in Interaction Modes. `old_string`:
```
    - Never explain what a T-code is — assume it.
```
`new_string`:
```
    - Never explain what a T-code is — assume it.
    - Batch every system-side check you need into one consolidated verification worklist rather than asking one question at a time. (Guided mode stays incremental, per Core Operating Principle #3.)
```

- [ ] **Step 4: Verify the new content is present and correctly placed**

Run:
```bash
grep -q "Operating Stance — Active Investigator, Not Interrogator" /home/giammaria/projects/claude-agents/sap-troubleshooter.md && \
grep -q "no live access to the user's SAP system" /home/giammaria/projects/claude-agents/sap-troubleshooter.md && \
grep -q "one consolidated verification worklist" /home/giammaria/projects/claude-agents/sap-troubleshooter.md && \
grep -q "over 20 years" /home/giammaria/projects/claude-agents/sap-troubleshooter.md; echo "exit=$?"
```
Expected: the persona phrase `over 20 years` is now absent, so the final `grep` fails and the chain prints `exit=1`. (The three new-content greps must all succeed; only the last one — checking the old phrase is gone — must fail.)

- [ ] **Step 5: Verify the diagnostic model heading still exists exactly once**

Run:
```bash
grep -c "^## SAP Diagnostic Model" /home/giammaria/projects/claude-agents/sap-troubleshooter.md
```
Expected: `1` (section preserved, not duplicated).

- [ ] **Step 6: Commit**

```bash
cd /home/giammaria/projects/claude-agents
git add sap-troubleshooter.md
git commit -m "Add active-investigator stance and expert-mode worklist to sap-troubleshooter

Co-Authored-By: Claude Opus 4.8 <noreply@anthropic.com>"
```

---

## Task 3: Delete the redundant memory boilerplate

**Files:**
- Modify: `/home/giammaria/projects/claude-agents/sap-troubleshooter.md:247-384`

**Interfaces:**
- Consumes: nothing.
- Produces: a file that ends after a one-line memory nudge. The platform injects full memory instructions and `MEMORY.md` automatically because `memory: local` is set.

**Context:** Keep the SAP-specific "what to record" guidance (the paragraph starting `**Update your agent memory**` and its `Examples of what to record:` list, lines ~238–245) — that is domain value the platform does not provide. Delete only the generic, platform-duplicated system starting at `# Persistent Agent Memory`.

- [ ] **Step 1: Delete everything from `# Persistent Agent Memory` to end of file**

Edit. `old_string` starts at:
```
# Persistent Agent Memory
```
and extends to the final line of the file (`## MEMORY.md` section and everything under it — the entire block from line 247 to 384). `new_string`:
```
## Memory usage

Consult your memory before diagnosing and update it after resolving recurring patterns. (The platform provides your memory directory and read/write instructions automatically via the `memory: local` setting.)
```

- [ ] **Step 2: Verify the boilerplate is gone**

Run:
```bash
grep -c "Persistent Agent Memory\|Types of memory\|two-step process\|body_structure" /home/giammaria/projects/claude-agents/sap-troubleshooter.md
```
Expected: `0`.

- [ ] **Step 3: Verify the SAP-specific record guidance and new nudge survive**

Run:
```bash
grep -q "Examples of what to record" /home/giammaria/projects/claude-agents/sap-troubleshooter.md && \
grep -q "Consult your memory before diagnosing" /home/giammaria/projects/claude-agents/sap-troubleshooter.md && echo OK
```
Expected: `OK`.

- [ ] **Step 4: Verify the file shrank substantially**

Run:
```bash
wc -l /home/giammaria/projects/claude-agents/sap-troubleshooter.md
```
Expected: roughly 250 lines or fewer (down from 384) — the ~137-line boilerplate is gone.

- [ ] **Step 5: Final YAML sanity check (whole file still well-formed)**

Run:
```bash
python3 -c "import yaml; parts=open('/home/giammaria/projects/claude-agents/sap-troubleshooter.md').read().split('---'); yaml.safe_load(parts[1]); print('frontmatter OK')"
```
Expected: `frontmatter OK`.

- [ ] **Step 6: Commit**

```bash
cd /home/giammaria/projects/claude-agents
git add sap-troubleshooter.md
git commit -m "Remove redundant memory boilerplate (platform provides it via memory: local)

Co-Authored-By: Claude Opus 4.8 <noreply@anthropic.com>"
```

---

## Self-Review

**Spec coverage:**
- Fix file shape → Task 1 (description + tools). ✓
- Delete redundant memory boilerplate → Task 3. ✓
- Active investigator (parse-first, autonomous research, honest delegation) → Task 2, Step 2. ✓
- Preserve rigor / map active onto mode axis (expert worklist, guided incremental) → Task 2, Step 3; Global Constraints preserve-verbatim list. ✓
- Trim persona flavor → Task 2, Step 1. ✓
- Locked-down `tools` grant → Task 1, Step 1. ✓
- Out of scope (no new agents, no connectivity, no sync changes) → Global Constraints. ✓

**Placeholder scan:** No TBD/TODO; every edit shows exact old/new strings and exact verification commands. ✓

**Type/name consistency:** Section titles referenced in verification greps match the strings inserted (`Operating Stance — Active Investigator, Not Interrogator`, `one consolidated verification worklist`, `Consult your memory before diagnosing`). ✓
