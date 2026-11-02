# Cogumi Rules

Engineering rules for AI coding agents. They build on Andrej Karpathy's four principles and add the practices that reduce refactoring and bugs. The rules are standing constraints loaded into the agent's context. There is nothing to invoke.

Works with Claude Code, Codex and ChatGPT, and Cursor. One source file generates every format.

## The Problems

Karpathy's observations cover how agents behave while coding: silent assumptions, overcomplicated code and orthogonal edits. Three further problems remain once those are fixed:

- Unit tests pass but the product does not work.
- The agent adds a second copy of something that already exists, so names and behavior drift apart.
- Code is correct today and costly to change tomorrow.

## The Solution

Eight rules in one file. Rules 1 to 4 are Karpathy's. Rules 5 to 8 are ours.

| Rule | Addresses |
|------|-----------|
| **1. Think Before Coding** | Wrong assumptions, hidden confusion, missing tradeoffs |
| **2. Simplicity First** | Overcomplication, bloated abstractions |
| **3. Surgical Changes** | Orthogonal edits, touching code you shouldn't |
| **4. Goal-Driven Execution** | Weak success criteria |
| **5. Design for Change** | Refactoring when an expected variant arrives, tangled modules |
| **6. Test the Product, Not Just the Code** | Green unit tests with a broken product |
| **7. Read Before You Write** | Duplication and inconsistent names |
| **8. Prove It Before Saying Done** | Unverified "done", weakened checks, hidden failures, silent spec drift |

The full text is in [`src/rules.md`](src/rules.md).

## Project facts

The rules stay generic. Anything that differs per repository lives in one small file. Copy [`cogumi-project.template.md`](cogumi-project.template.md) to `cogumi-project.md` at your repository root and fill in the quality gate command, change points, critical flows and lint limits. The rules tell the agent to read it.

## Install

**Claude Code (plugin, recommended)**

```
/plugin marketplace add dkeviv/cogumi-coderules
/plugin install cogumi-rules@cogumi
```

The plugin includes a `SessionStart` hook that places the rules, and `cogumi-project.md` if present, in context at the start of every session, so they do not depend on a skill description matching. It also exposes the same text as a skill.

**Claude Code (per repository)**

Copy [`CLAUDE.md`](CLAUDE.md) into your project. To keep it separate from your own instructions, save it as `cogumi-rules.md` and add this line to your existing `CLAUDE.md`:

```
@cogumi-rules.md
```

**Codex and ChatGPT**

Codex reads `AGENTS.md` at the repository root. Copy [`AGENTS.md`](AGENTS.md) there, or merge its contents into your existing file. For ChatGPT outside Codex, paste the contents of [`src/rules.md`](src/rules.md) into custom instructions or project instructions.

**Cursor**

Copy [`.cursor/rules/cogumi-rules.mdc`](.cursor/rules/cogumi-rules.mdc) into your project's `.cursor/rules/`. It is set to `alwaysApply: true`. Cursor also reads `AGENTS.md`, so that file works as well.

## How it works

Every format is plain text that the tool loads into the agent's context. Nothing enforces it. Compliance is strongest when the project backs the rules with real checks: the quality gate command, lint limits, a script that fails on duplicate shared names, and flow tests that fail without the feature.

## For maintainers

Edit only [`src/rules.md`](src/rules.md). Then run:

```
scripts/build.sh    # regenerates CLAUDE.md, AGENTS.md, the skill and the Cursor rule
scripts/check.sh    # fails if any generated file is out of sync
```

The workflow in [`.github/workflows/check.yml`](.github/workflows/check.yml) runs `scripts/check.sh` on every push and pull request, so the formats never drift.

## Credits

Rules 1 to 4 come from [forrestchang/andrej-karpathy-skills](https://github.com/forrestchang/andrej-karpathy-skills), derived from [Andrej Karpathy's observations](https://x.com/karpathy/status/2015883857489522876).
