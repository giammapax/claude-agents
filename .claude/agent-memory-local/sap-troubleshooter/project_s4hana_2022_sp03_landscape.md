---
name: project-s4hana-2022-sp03-landscape
description: User's SAP landscape is on S/4HANA 2022 SP03 following a recent upgrade; FI-GL fiscal year variant issue encountered post-upgrade
metadata:
  type: project
---

User's SAP system was upgraded to S/4HANA 2022, currently on SP03 (as of 2026-07-02).

Known issue on this landscape: post-upgrade, `FBL3H` posting/navigation throws `FGV_FLEX 042` — "Ledger 0L is not assigned to a valid representative period" — for all users, but only under the new fiscal year variant. Did not occur before the upgrade. Root cause under investigation as of 2026-07-02: working hypothesis is a gap in the ledger/fiscal-year-variant "representative period" mapping (table/customizing for ledger 0L) not extended into the new fiscal year, possibly exposed by stricter validation introduced in SP03 (message class `FGV_FLEX` could not be confirmed in public SAP documentation — likely a newer/internal message class tied to flexible period determination for ledgers with alternative fiscal year variants).

**Why:** relevant context for any future FI-GL, fiscal year variant, or ledger-period troubleshooting on this system — same landscape, same SP level.

**How to apply:** when this user reports other FI-GL/posting-period issues, check first whether it correlates with the same SP03 upgrade window or the same fiscal year variant change. If the FGV_FLEX042 root cause gets confirmed/resolved, update this memory with the actual fix and any SAP Note/KBA number verified at that time (do not carry forward unverified guesses).
