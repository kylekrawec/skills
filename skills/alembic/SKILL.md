---
name: alembic
description: Set up and run an alembic — a three-tier model pipeline where cheap workers build, a separate dispatcher session condenses, and this session (the head) reviews so only distillate ships. Use when the user mentions an alembic, or asks to orchestrate work across model tiers with a reviewer over a dispatcher.
argument-hint: "(optional) the first charge — a task to run through the vessel"
---

An alembic is two connected vessels: the **cucurbit**, where material is heated,
and the **head**, where vapor condenses and only the refined essence — the
**distillate** — is collected. Work here flows the same way, and the anatomy is
the vocabulary of this skill:

| term           | meaning here                                                            |
| -------------- | ----------------------------------------------------------------------- |
| **head**       | the reviewer — this session, the strongest model available              |
| **cucurbit**   | the dispatcher — a separate session on a cheaper high-taste model       |
| **heat**       | implementation workers — Codex CLI runs the dispatcher spawns           |
| **charge**     | one batch fed into the vessel: one coherent review unit                 |
| **crude**      | worker output before the dispatcher has verified it                     |
| **distillate** | work that passed the head's review — the only thing that ships          |
| **cohobation** | pouring impure work back into the cucurbit for another pass             |
| **residue**    | small mechanical flaws the head fixes in place rather than sending back |

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
| ------------- | ---- | ------------ | ----- |
| gpt-5.6-terra | 8    | 7            | 4     |
| gpt-5.6-sol   | 6    | 10           | 5     |
| opus-5        | 4    | 8            | 8     |
| fable-5       | 2    | 10           | 9     |

- **Head**: maximum intelligence and taste, cost be damned — it reads reports
  and diffs, so its volume is small (today: fable-5).
- **Cucurbit**: the cheapest model that still has top-tier intelligence and
  taste ≥ 7 — it writes the briefs that steer everyone else's budget, so it
  cannot be dim (today: opus-5).
- **Heat**: maximum intelligence per dollar — taste stays upstream in the
  brief (today: gpt-5.6-sol). The workers are `codex exec` processes, not
  Claude subagents, driven through the codex-implementation,
  codex-computer-use, and codex-review skills that ship alongside this one.
  Downshift to gpt-5.6-terra only for provably mechanical work; the first
  capability lost going cheaper is noticing the thing nobody asked about. The
  tell is in the brief itself: if it contains "you own the call" or "decide
  and report", the strong tier was just chosen.

## Assembling the vessel

1. **Lay the shared ground.** The project needs a `CLAUDE.md` (or equivalent)
   carrying its conventions, verification gates, and known traps, so every
   session boots oriented instead of re-briefed. Done when the file exists and
   names the gates a hand-back must pass.
2. **Start from distillate.** The working tree must be clean on a committed
   baseline — the diff against it _is_ the review unit. Done when the head and
   cucurbit agree on the baseline hash.
3. **Connect the vessels.** Run the spawner that ships with this skill, with
   a Bash timeout above the script's own:

   ```
   <this skill's directory>/spawn-dispatcher.sh <the head's cwd> opus-5 [timeout-seconds]
   ```

   It does the whole dance deterministically: reads the user's terminal from
   settings, writes and self-checks the launch script (never emit that
   command inline — two independent heads repeatedly dropped its `cd`, and
   the spawned shell skips the user's profile so the claude path must be
   absolute; the script owns both lessons), opens an interactive window —
   the user feeds it charges directly — and boots the new session with a
   first turn that primes the rulebook and waits. Output is `KEY=VALUE`
   lines: exit 0, the session is registered; exit 2, the user still has to
   click through the new window's startup (tell them, then re-check
   `test -S $EXPECTED_SOCK`); exit 1, error — fall back to asking the user
   to open the window themselves.

   Contact is head-initiated, exactly once: address the handoff to
   `uds:$EXPECTED_SOCK` — the dispatcher's bus address, known before it has
   said a word — immediately on exit 0. Do not wait on the peer roster or
   address by name: both lag a fresh session; the minted `DISPATCHER_NAME`
   is for humans (the window title, the from-name on its messages). The
   dispatcher's acknowledgment is the readiness signal.

   The handoff is one message that both completes the connection
   and seats the dispatcher in its role, and opens the channel every
   head↔dispatcher exchange uses from here — cohobations, new baselines, seam
   questions — never relayed through the user. It carries
   - **the role**: receive the user's requests, assess them, brief and
     dispatch Codex workers, and organize their activity into one review
     unit at a time — with this skill's [DISPATCHER.md](DISPATCHER.md) named
     as the rulebook to read first;
   - **project context**: a few sentences on what is being built, the stack,
     and where the conventions live (the shared ground from step 1);
   - **the baseline hash** and the hand-back contract below;
   - **the permission errand**: ask its user directly for the standing
     permissions of step 4 — the head cannot grant them by relay.

   Done when the cucurbit acknowledges the contract, confirms a clean tree,
   and reports its permissions settled.

   **Never fork the head into a dispatcher** (Agent-tool fork or
   `--fork-session`). A forked transcript boots the cucurbit with an identity
   conflict — instructions addressed to the reviewer — and preloads it with
   the head's reasoning, forfeiting the fresh-eyes separation this pattern
   exists for; only distillate crosses tiers. A fresh session needs ~1k
   tokens to boot and owes nothing to the head's priors.

### Settings

Per-user settings live at `~/.config/alembic/settings.json` — outside the
skill folder, because the skills.sh installer re-copies the folder on every
update and has no install-time settings of its own:

```json
{ "terminal": "Ghostty" }
```

`terminal` names a spawn recipe above; an optional `spawnTemplate` replaces
the recipe with any shell command containing `{command}`. When the file is
missing, ask which terminal the user runs, then offer to save the answer
there. 4. **Permissions are granted in person.** Anything the dispatcher needs
standing permission for (running `codex` via Bash, worktrees) the user must
authorize inside _that_ session — a relayed instruction from the head is
not authorization, and a correct dispatcher will refuse it. The handoff
therefore tells the dispatcher to request them from its user itself,
before the first charge arrives.

## The cycle

**One charge in the cucurbit at a time.** The head's review queue sets the
pace, not the agent pool — parallelism belongs _within_ a charge (workers on
disjoint files), never across review units. Requests arriving faster than
review wait in a stated queue. Charges accumulated over shared files weld
together and can no longer be committed apart. On the user's ask only, a
queued charge whose file set provably does not intersect the in-tree one may
proceed — the diffs stay separable by path, the in-tree files are fenced
off-limits in its brief, and the departure is declared to the head. But
disjoint files are not disjoint effects: a shared dev server, database, or
process joins the charges at runtime, and one charge's verification traffic
executes whatever code the runtime holds — a read-only GET is a write when
pull-on-load hangs off it. Where the runtime cannot be isolated, they are one
review unit no matter how clean the paths look.

**Hand-back contract** (what makes crude ready for the head): all gates clean
(typecheck, lint, tests), behavior verified live with measurements rather than
impressions — every claim labeled **observed** (seen live) or **derived**
(static analysis, stating why live observation was impossible and what would
falsify it; the head converts derived to observed where its tooling reaches
further) — nothing staged or committed, and a report carrying three sections
beyond the change list: deviations from the brief, deliberate omissions, and
judgment calls for the user to confirm. Most findings that matter live in
those three sections.

**The head's review** — sign it like your own work:

1. Diff the tree against the baseline; read every hunk.
2. Read the dispatcher's claims against the code. Divergence between what a
   report says and what the diff does is where the bugs live.
3. Re-run the gates yourself; spot-verify live, converting the report's
   derived claims to observed where your tooling reaches further. A verified
   claim can still be verified wrong — and the dispatcher already ran the
   gates; the second run is the design, not waste.
4. Review shared-file edits and cross-worker seams hardest — the dispatcher's
   fences make those exactly the places no single worker saw whole.
5. Route what you find: conceptual misses are **cohobated** — sent back down
   with specific, actionable corrections for the cucurbit to fix in its own
   work — never rewritten by the head as a first move. **Residue** (small,
   mechanical, obvious) the head fixes in place and reports.
6. Only distillate ships: report to the user. When the cucurbit declares a
   reviewed charge commit-ready, the head drafts the commit message and any
   sensible split — but commits only on the user's explicit approval, staging
   by path so in-flight charges stay out of the index. Nothing upstream ever
   touches the index. Announce each new baseline to the cucurbit.

## Hazards

- **One tree, one writer.** A second build session interleaves batches
  invisibly; the head cannot un-weld them. Never run two cucurbits.
- **Hot files.** Every repo has files everyone needs — a global stylesheet, a
  router, a barrel export. The cucurbit lists them before its first spawn;
  the head reviews edits to them hardest.
- **Global mutexes.** A shared browser profile or device is a lock one stale
  session can hold forever. Give workers isolated instances by construction —
  and the head can always verify through its own throwaway instance (e.g. a
  headless browser driven over raw CDP) rather than inheriting anyone's word.
- **Real side effects.** Dev databases and live services are shared state,
  and the user is writing to them too. Open the bounding window immediately
  before the action, never at session start — "changed since I started" is
  not "changed by me." Verify an attribution column can actually discriminate
  before relying on it: audit tables often stamp the signed-in user, so every
  row looks identical whoever wrote it. Then dump before you delete,
  attribute every row to a specific action you took, and remove only those.
  Restoring state means restoring what is _derived_ from it — where a log is
  read back into the UI, a data-only revert appends another entry and leaves
  any "last changed" label wrong forever; ask what the app _shows_ from a
  table, not just what it stores. Cleanup is the dispatcher's own job, never
  a worker's: executing a delete is mechanical, deciding whose rows these are
  is not.
- **Blast radius is not visible in the UI.** Two adjacent controls can differ
  by everything — one writes locally and recovers, its neighbour pushes to an
  external system and locks records forever. An irreversible action fires
  only on the user's explicit instruction in their own session.
- **Two-layer state models.** When a request implies defaults plus overrides,
  ask the user one question about how the layers interact _over time_ before
  anything is dispatched — "override" alone is ambiguous by a database table.
- **A named hazard is not a mitigated one.** Saying "loading a page right now
  would execute unreviewed code" out loud and then loading the page anyway is
  how the one irreversible mistake of a run happens. The moment a hazard is
  identified, either build the mitigation or sequence around it — identifying
  it grants no immunity.
