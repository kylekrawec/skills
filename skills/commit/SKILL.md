---
name: commit
description: >
  Writes git commit messages in this project's Conventional Commits style where
  the type word is replaced by a single emoji (✨ feat, 🐛 fix, …), followed by
  an optional (scope), an optional ! for breaking changes, a colon, and an
  imperative lowercase description, plus an optional bracketed ticket when the
  user provides one. Use when committing code, writing or editing commit
  messages, or when the user asks to commit changes.
---

# Commit — Conventional Commits with emoji types

Follows [Conventional Commits](https://www.conventionalcommits.org), but the
textual type (`feat`, `fix`, …) is replaced by a single emoji. The `(scope)`,
`!` marker, `:` separator, and `BREAKING CHANGE:` footer are unchanged.

## Quick start

Title format — `(scope)`, `!`, and `[<TICKET>]` are all optional:

```
<emoji>(<scope>)<!>: <description> [<TICKET>]

<optional body: why, not what>

<optional BREAKING CHANGE: footer>
```

```
✨: add user authentication endpoint

Implements JWT-based auth with refresh token rotation.
```

```
🐛(auth): fix token refresh race condition [PROJ-42]
```

## Type → emoji

| Type       | Emoji | Use for                                                 |
| ---------- | ----- | ------------------------------------------------------- |
| `feat`     | ✨    | a new feature                                           |
| `fix`      | 🐛    | a bug fix                                               |
| `docs`     | 📝    | documentation only                                     |
| `style`    | 🎨    | formatting/whitespace, no code-behavior change          |
| `refactor` | ♻️    | change that neither fixes a bug nor adds a feature      |
| `perf`     | ⚡️    | performance improvement                                 |
| `test`     | ✅    | adding or fixing tests                                  |
| `build`    | 📦️    | build system or dependencies                            |
| `ci`       | 👷    | CI configuration and scripts                            |
| `chore`    | 🔧    | maintenance/tooling, no production code change          |
| `revert`   | ⏪️    | reverts a previous commit                               |

## Workflow

1. Inspect changes with `git diff` and `git status`.
2. Pick the emoji whose type fits (table above); add a `(scope)` only when one
   area is affected, then the colon.
3. Write an imperative, lowercase description (under 72 chars, no trailing
   period; keep proper nouns and acronyms as-is).
4. If the change is breaking, add `!` before the colon and a `BREAKING CHANGE:`
   footer explaining the break.
5. Append a ticket only if the user gave one (see Tickets); never invent one.
6. Add a body explaining **why** for non-trivial changes, separated from the
   title by a blank line.
7. Show the message and **get approval before committing**.
8. If staged changes mix distinct concerns, suggest splitting into separate
   commits, each with its own emoji type and description.

## Tickets

Tickets are optional — include one only when the user supplies it. Never ask for
a ticket and never block a commit on having one. Format: `[A-Z0-9]+-\d+`
(e.g. `PROJ-123`, `DEV-42`), appended to the title in square brackets.

The user signals a ticket with phrases such as:

- "use PROJ-35" → `[PROJ-35]`.
- "commit the changes on 25" → a bare number; pair it with the project prefix
  already in use (branch name or a recent commit) to form `[PROJ-25]`. If no
  prefix is known, ask which project it belongs to rather than guessing.

## More examples

```
♻️(forms): extract validation logic into shared util

Reduces duplication across three form handlers.
```

```
♻️(api)!: drop support for Node 14

BREAKING CHANGE: minimum supported Node version is now 18.
```
