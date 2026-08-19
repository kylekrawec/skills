# Skills

[![skills.sh](https://skills.sh/b/kylekrawec/skills)](https://skills.sh/kylekrawec/skills)

A small collection of agent skills I use with Claude Code. They're meant to be
read, adapted, and made your own — each is a single self-contained folder under
[`skills/`](./skills).

## Quickstart

Install with the [skills.sh](https://skills.sh) installer:

```bash
npx skills@latest add kylekrawec/skills
```

Pick the skills you want and which agents to install them on. That's it — they're
ready to use.

> [!NOTE]
> `npx skills` copies the whole skill folder into your agent's skills directory
> and re-copies it on every update. Per-user data (e.g. `teach`'s learning
> workspaces) lives outside the skill folder so it survives updates.

## Reference

- **[alembic](./skills/alembic/SKILL.md)** — Run development through a
  three-tier reviewer–dispatcher pipeline built for the economics of mixed
  model fleets. The session you invoke it in becomes the **reviewer** — your
  strongest, most expensive model, spent only on judgment: reading diffs
  against a clean baseline, checking the dispatcher's claims against the code,
  and deciding what ships. A **dispatcher** session on a cheaper high-taste
  model owns the middle: it reads the code first, writes precise `file:line`
  briefs, fences file ownership, and spawns the **workers** — cheaper still —
  that do the actual building. Work flows in one direction as review units,
  one at a time; the skill ships a [dispatcher rulebook](./skills/alembic/DISPATCHER.md)
  distilled from a real multi-agent run, mostly from its failures (batch
  pile-ups, contested files, mid-flight re-scoping, seams nobody owned).

  *Why "alembic"?* An alembic is the alchemist's still: two connected vessels,
  where material is heated in the lower **cucurbit** and only the refined
  essence — the distillate — condenses out in the **head**. That's this
  pipeline's exact shape: workers are the heat, the dispatcher is the cucurbit,
  the reviewer is the head, and only distillate reaches your repo. The
  vocabulary comes free with the name: each batch is a **charge** fed into the
  vessel, and when the reviewer sends flawed work back down for another pass
  instead of rewriting it, that's **cohobation** — the centuries-old practice
  of pouring the distillate back over the residue and distilling again until
  it runs pure. Alchemists never got gold out of base metal; run cheap tokens
  through enough glass, though, and you genuinely do.
- **[commit](./skills/commit/SKILL.md)** — Write git commit messages using
  [Conventional Commits](https://www.conventionalcommits.org) with
  [Gitmoji](https://gitmoji.dev): the standard `type(scope)!: description`
  structure, but the type word (`feat`, `fix`, …) replaced by a single emoji
  (✨, 🐛, …). Use when committing or writing commit messages.
- **[simple](./skills/simple/SKILL.md)** — Brief response mode. Answers get
  straight to the point in plain, grammatical English — no fluff, no narration,
  no hedging. Trigger with "simple", "be brief", or `/simple`.
- **[omarchy](./skills/omarchy/SKILL.md)** — Customize an
  [Omarchy](https://omarchy.org/) Linux desktop: Hyprland, Waybar, Walker,
  terminals, themes, keybindings, monitors, and other `~/.config` tweaks.
- **[teach](./skills/teach/SKILL.md)** — Teach you a new skill or concept over
  multiple sessions, using a persistent per-topic workspace to track progress.
  Run with `/teach <topic>`.
