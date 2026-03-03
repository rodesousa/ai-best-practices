# Writing Better CLAUDE.md Files

Practical guidelines derived from empirical research:
*Evaluating AGENTS.md: Are Repository-Level Context Files Helpful for Coding Agents?*
Gloaguen et al., 2026 — https://arxiv.org/abs/2602.11988v1

---

## Key finding

Human-written context files improve task success by +4%.
LLM-generated ones reduce it by 2%.
Both increase inference cost by ~20%.

Every instruction you add has a cost. Make it count.

---

## Files

**`context-file-best-practices.md`**
What to write (and not write) in a CLAUDE.md.
7 practices covering minimalism, tooling, conditional reading,
runnable examples, deduplication, file structure, and validation hierarchy.

**`behavior-best-practices.md`**
How to behave during sessions.
3 rules covering rule origin, audit file usage, and code vs doc conflicts.

---

## How to use

These are audit documents — not context files.
Do not load them at session start.
Open them when reviewing your CLAUDE.md, then close them.
