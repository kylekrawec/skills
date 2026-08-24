---
name: alembic
description: Run an alembic — a distillation loop where this session is the dispatcher and single source of truth, spawning cheap stateless Codex workers to build and a stateless top-tier reviewer to audit each charge, so only distillate ships. Use when the user mentions an alembic, or asks to orchestrate work across model tiers with independent review.
argument-hint: "(optional) the first charge — a task to run through the vessel"
---

An alembic is two connected vessels: the **cucurbit**, where material is heated,
and the **head**, where vapor condenses and only the refined essence — the
**distillate** — is collected. Work here flows the same way, and the anatomy is
the vocabulary of this skill:

| term           | meaning here                                                             |
| -------------- | ------------------------------------------------------------------------ |
| **cucurbit**   | the dispatcher — this session: the single source of truth where the user speaks, plans form, workers are briefed, and findings are fixed |
| **heat**       | stateless workers — one-shot Codex CLI runs the dispatcher spawns         |
| **head**       | the reviewer — a stateless top-tier agent spawned fresh per charge        |
| **charge**     | one batch fed into the vessel: one coherent review unit                   |
| **crude**      | worker output before the dispatcher has verified it                       |
| **distillate** | work that passed the head's review — the only thing that ships            |
| **cohobation** | pouring impure work back in for another pass after review findings        |
| **residue**    | small mechanical flaws fixed in place rather than re-worked               |

The session that invokes this skill is the cucurbit. Read
[DISPATCHER.md](DISPATCHER.md) — the operating rulebook — before the first
charge.

## The architecture, named

The alembic composes the two multi-agent patterns that hold up in practice:

- Cucurbit + heat are **one strong loop over stateless workers**: a single
  stateful session carries every decision, and workers are pure functions —
  self-contained brief in, diff and report out, then gone. Rework is a fresh
  brief, never a steered session.
- The head is the **independent reviewer** of a builder/reviewer pair,
  attached to the loop's _output_: it audits the diff with fresh eyes and
  returns findings. It never coordinates, edits, or accumulates context.

State lives in exactly one place. When a second stateful agent starts
accumulating context — a standing reviewer, an interactive worker, a peer
session — the design has drifted; pull the state back into the loop.

## Choosing the tiers

When the user names models, use them. Otherwise:

- **Cucurbit**: the current session's model — the loop is wherever the user
  already is.
- **Head**: the highest-end model available to spawn (today: fable-5).
- **Heat**: maximum intelligence per dollar — taste stays upstream in the
  brief (today: gpt-5.6-sol via Codex CLI, driven through the
  codex-implementation, codex-computer-use, and codex-review skills that
  ship alongside this one). Downshift to gpt-5.6-terra only for provably
  mechanical work; the first capability lost going cheaper is noticing the
  thing nobody asked about.

Rankings, higher = better. Intelligence is how hard a problem the model
handles unsupervised; taste covers UI/UX, code quality, API design, and
copy. The chart moves — re-derive the defaults from whatever chart is
current:

| model         | cost | intelligence | taste |
| ------------- | ---- | ------------ | ----- |
| gpt-5.6-terra | 8    | 7            | 4     |
| gpt-5.6-sol   | 6    | 10           | 5     |
| opus-5        | 4    | 7            | 8     |
| fable-5       | 2    | 10           | 9     |

This deliberately inverts the usual put-the-best-model-in-the-loop advice:
the loop runs at volume, so it takes the model the user can afford to sit
in; the head reads one diff and one report per charge, so its volume is
tiny and its judgment should be the best in the fleet. The escape rate is
the check on that bet: a head that keeps catching conceptual misses rather
than residue is telling you the loop is too dim for its judgment load —
upshift the cucurbit or narrow the charges.

## Assembling the vessel

1. **Lay the shared ground.** The project needs a `CLAUDE.md` (or
   equivalent) carrying its conventions, verification gates, and known
   traps, so every worker brief and review packet can point at it. Done
   when the file exists and names the gates a charge must pass.
2. **Start from distillate.** The working tree must be clean on a committed
   baseline — the diff against it _is_ the review unit. Record the hash.
3. **Check the worker credentials.** Run `codex login status` — an
   unauthenticated worker has been observed exiting 0 having done nothing.

Everything runs inside this one session: there are no peer sessions to
spawn, no windows to manage, and permissions are this session's ordinary
prompts.

## The cycle

1. **One charge at a time.** The commit gate sets the pace, not the agent
   pool — parallelism belongs _within_ a charge (workers on disjoint
   files), never across review units. Charges accumulated over shared
   files weld together and can no longer be committed apart; disjoint
   files are still not disjoint effects when a shared dev server, database,
   or process joins them at runtime. The rulebook carries the details.
2. **Brief and spawn the heat** per the rulebook; verify the crude
   yourself — the combined gate run on the integrated tree is the
   dispatcher's, never a worker's.
3. **Spawn the head**: a fresh, stateless reviewer on the top-tier model,
   operating per [REVIEWER.md](REVIEWER.md). Hand it the baseline hash,
   your report with every claim labeled **observed** or **derived**, and
   the conventions pointer. Never fork it from this session and never hand
   it your reasoning — fresh eyes are the point. It returns findings and
   edits nothing.
4. **Route the findings.** Conceptual misses cohobate — fixed through a
   fresh worker brief, or by the loop directly when small. Residue the
   loop fixes in place. After cohobation, spawn a _new_ head: it is
   stateless, so re-review costs one spawn and re-reads the whole charge
   with no memory of having approved anything. A finding you believe is
   wrong goes to the user with your evidence — never into a re-prompt loop
   until a reviewer relents.
5. **Only distillate ships.** When the head passes the charge, draft the
   commit message and any sensible split — but commit only on the user's
   explicit approval, staging by path so in-flight work stays out of the
   index.

## Hazards

- **One tree, one loop.** A second builder session interleaves batches
  invisibly and no one can un-weld them. Never run two cucurbits on one
  tree.
- **Hot files.** Every repo has files everyone needs — a global stylesheet,
  a router, a barrel export. List them before the first spawn; tell the
  head to review edits to them hardest.
- **Global mutexes.** A shared browser profile or device is a lock one
  stale process can hold forever. Give workers isolated instances by
  construction, and verify through your own throwaway instance rather than
  inheriting anyone's word.
- **Real side effects.** Dev databases and live services are shared state,
  and the user is writing to them too. Open the bounding window immediately
  before the action, never at session start — "changed since I started" is
  not "changed by me." Verify an attribution column can actually
  discriminate before relying on it. Dump before you delete, attribute
  every row to a specific action you took, and remove only those.
  Restoring state means restoring what is _derived_ from it — ask what the
  app _shows_ from a table, not just what it stores. Cleanup is the loop's
  own job, never a worker's: executing a delete is mechanical, deciding
  whose rows these are is not.
- **Blast radius is not visible in the UI.** Two adjacent controls can
  differ by everything — one writes locally and recovers, its neighbour
  pushes to an external system and locks records forever. An irreversible
  action fires only on the user's explicit instruction.
- **Two-layer state models.** When a request implies defaults plus
  overrides, ask the user one question about how the layers interact _over
  time_ before anything is dispatched — "override" alone is ambiguous by a
  database table.
- **A named hazard is not a mitigated one.** The moment a hazard is
  identified, either build the mitigation or sequence around it —
  identifying it grants no immunity.
