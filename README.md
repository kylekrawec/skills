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
