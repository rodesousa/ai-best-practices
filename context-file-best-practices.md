# Context File Best Practices — AGENTS.md / CLAUDE.md
Source: *Evaluating AGENTS.md: Are Repository-Level Context Files Helpful for Coding Agents?* (Gloaguen et al., 2026)

---

## BP1 — Strict Minimalism

**Principle:** Only write the minimum required instructions. Exhaustive context files reduce task success rates and increase inference costs by +20 to +23%. The paper explicitly states: *"human-written context files should describe only minimal requirements."*

**Remove first (per paper author):**

| Content | Why it's useless |
|---------|-----------------|
| Repository overviews | The agent explores on its own |
| Generic best practices | Too vague, not actionable |
| LLM-generated recommendations | Risk of hallucination |

**Before (anti-pattern):**
```
## Tech Stack
- OBS → screen recording (Ubuntu)
- ElevenLabs → AI voice
- Remotion → video assembly (React, automatable)
- Canva → thumbnails
- CapCut Web → alternative editing
```

**After (BP1 applied):**
```
## Stack
Remotion (React), ElevenLabs (TTS), OBS (capture).
```

---

## BP2 — Specific Tooling Instructions

**Principle:** Explicitly mentioning tools to use produces a measurable effect. The paper measures that `uv` is used 1.6x per instance when mentioned in the context file, vs < 0.01x when it is not. Agents reliably follow tool recommendations.

**Example:**
```md
## Commands

| Action                  | Exact command                                |
|-------------------------|----------------------------------------------|
| Fetch sources from DB   | make items-by-ids IDS="'uuid1','uuid2'"      |
| Preview                 | npx remotion studio                          |
| Render                  | ./render.sh YYYY-MM-DD                       |
| Validate assets         | ./validate-episode.sh YYYY-MM-DD             |
```

---

## BP3 — Conditional File Reading

**Principle:** Instructions like "read X at the start of every session" trigger unnecessary broad exploration. The paper identifies that agents follow these instructions faithfully — increasing cost with no gain. Replace with task-scoped reading.

**Example:**
```md
## Conditional Reading

| If the session is about...      | Read...                               |
|---------------------------------|---------------------------------------|
| script writing                  | youtube-strategie.md + video plan     |
| channel stats / review          | youtube-strategie.md only             |
| Remotion config / renaming      | nothing extra                         |
| render / asset validation       | nothing extra                         |
| ElevenLabs transcript           | remotion/CLAUDE.md "Audio" section    |
```

---

## BP4 — Runnable Examples over Abstract Descriptions

**Principle:** Agents perform better with concrete, reproducible patterns than with textual descriptions of what is expected. A code example is more actionable than a prose rule.

**Before (anti-pattern):**
```
ElevenLabs-optimized script: short sentences, no parentheses,
blank line = pause.
```

**After (BP4 applied):**
```md
## ElevenLabs Transcript Format

Template to reproduce:
---
This is a short sentence.
<break time="0.5s" />
Another short sentence, no parentheses.
<break time="0.8s" />
A strong stat gets a longer pause after it.
<break time="1.5s" />
---
Rules: max 15 words per sentence. No em dashes. Acronyms: A I, C L I, A P I.
```

---

## BP5 — Never Duplicate, Always Point

**Principle:** Any information that exists elsewhere (doc or code) must not be copied into the CLAUDE.md — point to the source instead. Duplication costs tokens and becomes false as soon as the source evolves. Risk is graduated depending on what you duplicate.

| What you duplicate | Risk | Reason |
|--------------------|------|--------|
| A markdown file (README, strategie.md) | Medium — redundant but stable | Docs evolve slowly |
| Code (types, structures, names) | High — redundant and perishable | Code evolves every session |

**Real examples found in `remotion/CLAUDE.md`:**

| What CLAUDE.md says | What the code says | Source file |
|---------------------|-------------------|-------------|
| `Effect = "static" \| "zoom-in" \| ... \| "overlay-fit"` | `Effect` also includes `"banner"` | `src/episodes/types.ts:1` |
| `tracks: [{ src, startSec }]` as episode structure | `EpisodeConfig` with `intro / hook / segments / outro` | `src/episodes/types.ts:73` |
| Composition `TestSegment1` in Root.tsx | Composition is named `SegmentScene` | `src/Root.tsx:75` |

**Anti-pattern:**
```md
## Project overview
This project builds a faceless YouTube channel about AI for devs...

## Available types
type Effect = "static" | "zoom-in" | "zoom-out" | ...
```

**BP5 applied:**
```md
→ Project context: see youtube-strategie.md
→ Types: see src/episodes/types.ts — single source of truth
```

**Why a pointer and not nothing?**
Without a mention, the agent doesn't know it should read the source file. The pointer is the right compromise:

| What you put in CLAUDE.md | Risk |
|---------------------------|------|
| Full content copy | High — goes stale or redundant |
| Prose description | High — goes stale or redundant |
| Pointer to file | Low — always true |
| Nothing | Low — but agent has to guess |

---

## BP6 — Separate Strategy from Tactics

**Principle:** Mixing strategic goals and implementation details in the same file dilutes critical instructions. The agent doesn't know what to prioritize. Each file should have a single responsibility.

**Recommended split:**
```
CLAUDE.md                   → session modes + editorial rules
remotion/CLAUDE.md          → episode config + effects + Remotion workflow
remotion/audio-rules.md     → ElevenLabs rules (format, acronyms, breaks)
remotion/effects-ref.md     → visual effects reference (static, overlay, etc.)
```

One file = one layer of responsibility.

---

## BP7 — Explicit Validation Hierarchy

**Principle:** Contradictory instructions are cited by the paper as particularly harmful — the agent must infer priority, which generates unpredictable behavior. Making the hierarchy explicit eliminates ambiguity.

**Example:**
```md
## Validation Levels

| Action                      | Required validation                              |
|-----------------------------|--------------------------------------------------|
| Episode config modification | Show full diff + wait for explicit OK            |
| Screenshot renaming         | Execute without per-file confirmation            |
| Transcript generation       | Validate script first, then generate             |
| Final render                | Run without confirmation if validate-episode passes |
```
