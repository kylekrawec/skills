---
name: alembic
description: Run development through a three-tier alembic — cheap workers produce the crude, a dispatcher session condenses it, this session (the head) reviews and ships only distillate.
disable-model-invocation: true
argument-hint: "(optional) the first charge — a task to run through the vessel"
---

An alembic is two connected vessels: the **cucurbit**, where material is heated,
and the **head**, where vapor condenses and only the refined essence — the
**distillate** — is collected. Work here flows the same way, and the anatomy is
the vocabulary of this skill:

| term | meaning here |
|---|---|
| **head** | the reviewer — this session, the strongest model available |
| **cucurbit** | the dispatcher — a separate session on a cheaper high-taste model |
| **heat** | implementation workers — subagents the dispatcher spawns |
| **charge** | one batch fed into the vessel: one coherent review unit |
| **crude** | worker output before the dispatcher has verified it |
| **distillate** | work that passed the head's review — the only thing that ships |
| **cohobation** | pouring impure work back into the cucurbit for another pass |
| **residue** | small mechanical flaws the head fixes in place rather than sending back |

The session that invokes this skill is the head. Never build in the head:
its tokens are the most expensive in the fleet and belong to judgment —
review, verification, and process control.

## Choosing the tiers

Rankings, higher = better (cost and intelligence from Artificial Analysis,
July 2026, except sonnet-5's intelligence, held down from real unsupervised
use). Intelligence is how hard a problem the model handles unsupervised;
taste covers UI/UX, code quality, API design, and copy. The chart moves —
re-derive the roles from whatever chart is current:

| model         | cost | intelligence | taste |
|---------------|------|--------------|-------|
| gpt-5.6-terra | 8    | 7            | 4     |
| gpt-5.6-sol   | 6    | 9            | 5     |
| sonnet-5      | 6    | 5            | 5     |
| opus-5        | 4    | 10           | 8     |
| fable-5       | 2    | 10           | 9     |

- **Head**: maximum intelligence and taste, cost be damned — it reads reports
  and diffs, so its volume is small (today: fable-5).
- **Cucurbit**: the cheapest model that still has top-tier intelligence and
  taste ≥ 7 — it writes the briefs that steer everyone else's budget, so it
  cannot be dim (today: opus-5).
- **Heat**: at or below the cucurbit's tier and noticeably cheaper than the
  head — often the cucurbit's own model. Downshift only for provably
  mechanical work; the first capability lost going cheaper is noticing the
  thing nobody asked about. The tell is in the brief itself: if it contains
  "you own the call" or "decide and report", the strong tier was just chosen.

## Assembling the vessel

1. **Lay the shared ground.** The project needs a `CLAUDE.md` (or equivalent)
   carrying its conventions, verification gates, and known traps, so every
   session boots oriented instead of re-briefed. Done when the file exists and
   names the gates a hand-back must pass.
2. **Start from distillate.** The working tree must be clean on a committed
   baseline — the diff against it *is* the review unit. Done when the head and
   cucurbit agree on the baseline hash.
3. **Connect the vessels.** The user opens the dispatcher session; the head
   finds it (ListAgents) and sends the handoff: baseline hash, the hand-back
   contract below, and a pointer to this skill's [DISPATCHER.md](DISPATCHER.md)
   as its rulebook. Done when the cucurbit acknowledges the contract and
   confirms a clean tree.
4. **Permissions are granted in person.** Anything the dispatcher needs
   standing permission for (spawning subagents, worktrees) the user must
   authorize inside *that* session — a relayed instruction from the head is
   not authorization, and a correct dispatcher will refuse it.

## The cycle

**One charge in the cucurbit at a time.** The head's review queue sets the
pace, not the agent pool — parallelism belongs *within* a charge (workers on
disjoint files), never across review units. Requests arriving faster than
review wait in a stated queue. Charges accumulated over shared files weld
together and can no longer be committed apart.

**Hand-back contract** (what makes crude ready for the head): all gates clean
(typecheck, lint, tests), behavior verified live with measurements rather than
impressions, nothing staged or committed, and a report carrying three sections
beyond the change list — deviations from the brief, deliberate omissions, and
judgment calls for the user to confirm. Most findings that matter live in
those three sections.

**The head's review** — sign it like your own work:

1. Diff the tree against the baseline; read every hunk.
2. Read the dispatcher's claims against the code. Divergence between what a
   report says and what the diff does is where the bugs live.
3. Re-run the gates yourself; spot-verify live. A verified claim can still be
   verified wrong.
4. Review shared-file edits and cross-worker seams hardest — the dispatcher's
   fences make those exactly the places no single worker saw whole.
5. Route what you find: conceptual misses are **cohobated** — sent back down
   with specific, actionable corrections for the cucurbit to fix in its own
   work — never rewritten by the head as a first move. **Residue** (small,
   mechanical, obvious) the head fixes in place and reports.
6. Only distillate ships: report to the user, who tests and commits. The index
   belongs to the committer alone — stage by path at commit time; nothing
   upstream ever touches it. Announce each new baseline to the cucurbit.

## Hazards

- **One tree, one writer.** A second build session interleaves batches
  invisibly; the head cannot un-weld them. Never run two cucurbits.
- **Hot files.** Every repo has files everyone needs — a global stylesheet, a
  router, a barrel export. The cucurbit lists them before its first spawn;
  the head reviews edits to them hardest.
- **Global mutexes.** A shared browser profile or device is a lock one stale
  session can hold forever. Give workers isolated instances by construction.
- **Real side effects.** Dev databases and live services are shared state:
  restored after every verification, with before/after evidence in the report.
- **Two-layer state models.** When a request implies defaults plus overrides,
  ask the user one question about how the layers interact *over time* before
  anything is dispatched — "override" alone is ambiguous by a database table.
