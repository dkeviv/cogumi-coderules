---
name: cogumi-rules
description: Engineering guidelines for AI coding agents. Use whenever writing, reviewing, testing or refactoring code to surface assumptions, keep changes simple and surgical, design for change, test real user flows, search before writing, and prove the work before saying done.
license: MIT
---

# Cogumi Rules

Behavioral guidelines to reduce common LLM coding mistakes and cut refactoring. Merge with project-specific instructions as needed.

**Tradeoff:** These guidelines bias toward caution over speed. For trivial tasks, use judgment.

Rules 1 to 4 are Andrej Karpathy's observations as packaged by forrestchang/andrej-karpathy-skills (MIT). Rules 5 to 8 are the Cogumi additions.

## 1. Think Before Coding

**Don't assume. Don't hide confusion. Surface tradeoffs.**

Before implementing:
- State your assumptions explicitly. If uncertain, ask.
- If multiple interpretations exist, present them - don't pick silently.
- If a simpler approach exists, say so. Push back when warranted.
- If something is unclear, stop. Name what's confusing. Ask.

## 2. Simplicity First

**Minimum code that solves the problem. Nothing speculative.**

- No features beyond what was asked.
- No abstractions for single-use code.
- No "flexibility" or "configurability" that wasn't requested.
- No error handling for impossible scenarios.
- If you write 200 lines and it could be 50, rewrite it.

Ask yourself: "Would a senior engineer say this is overcomplicated?" If yes, simplify.

## 3. Surgical Changes

**Touch only what you must. Clean up only your own mess.**

When editing existing code:
- Don't "improve" adjacent code, comments, or formatting.
- Don't refactor things that aren't broken.
- Match existing style, even if you'd do it differently.
- If you notice unrelated dead code, mention it - don't delete it.

When your changes create orphans:
- Remove imports/variables/functions that YOUR changes made unused.
- Don't remove pre-existing dead code unless asked.

The test: Every changed line should trace directly to the user's request.

## 4. Goal-Driven Execution

**Define success criteria. Loop until verified.**

Transform tasks into verifiable goals:
- "Add validation" → "Write tests for invalid inputs, then make them pass"
- "Fix the bug" → "Write a test that reproduces it, then make it pass"
- "Refactor X" → "Ensure tests pass before and after"

For multi-step tasks, state a brief plan:
```
1. [Step] → verify: [check]
2. [Step] → verify: [check]
3. [Step] → verify: [check]
```

Strong success criteria let you loop independently. Weak criteria ("make it work") require constant clarification.

## 5. Design for Change

**Build where change is expected. Keep everything else simple.**

- Find the change points: what the spec or owner says will vary, such as new providers, formats or integrations. Make each one an addition (a new module plus a registration), never an edit to existing code. If none are named, ask once.
- No abstraction for anything that is not a change point. Rule 2 still applies.
- Keep logic apart from input and output such as the database, network, clock and randomness.
- Define each fact once, whether a name, state, error code or setting.
- Keep contracts additive. Add fields, events and endpoints. Don't rename or remove them without approval and a migration path.
- If a file, function or interface does more than one thing, split it before adding more. Limits belong in the project's lint configuration. Never raise one to get past it.
- Don't mix refactoring with a feature. If structure blocks the work, refactor first as its own step, with tests green before and after.

The test: Could the next expected variant be added without editing an existing module?

## 6. Test the Product, Not Just the Code

**Done means the user-visible flow works.**

- Every behavior asked for gets a flow test. It enters through the real entry point (HTTP, command line, message or screen), uses real storage and asserts only what a user would see. Don't mock your own code.
- Fake only what you don't control, and make the fake follow the real protocol.
- Failure paths are flows too: timeout, duplicate, bad input, dropped connection, denied permission.
- Build the thinnest end-to-end path first, then widen it.
- Use unit tests for dense logic, not to raise coverage.
- Watch each new test fail before the feature exists.
- Keep tests deterministic. Fix or delete a flaky test.

The test: Would the flow test fail if the feature were removed? Would it catch a break between two modules that each pass alone?

## 7. Read Before You Write

**Search first. Reuse before creating.**

- Before adding any type, function, constant, endpoint, event, error code, setting or dependency, search for it by name and by meaning. Reuse or extend what exists.
- Read nearby files and tests. Match their naming, error handling and layout.
- If two similar things already exist, say so and ask which is canonical. Don't add a third.
- Check the documentation or source for the installed version of a library. Don't rely on memory.
- End with a short note: what you reused, what you created and why.

The test: Does every new name and helper exist because a search found nothing to reuse?

## 8. Prove It Before Saying Done

**Run it. Report what you saw. Hide nothing.**

- Run the project's quality gate (format, lint, types, tests) and exercise the flow in the running app before claiming done.
- Don't weaken a test, lint rule or threshold to get green. If a check is wrong, say so and ask.
- Don't hide failures. No empty catch blocks and no defaults that mask an error. Validate input where it enters.
- Make data changes safe to roll back. Nothing destructive without approval.
- If the implementation must differ from the spec, say so and update the spec or ask. Never diverge silently.
- State what you didn't verify and what you assumed.

The test: Could a reviewer reproduce your verification from your report alone?

## Project Facts

If `cogumi-project.md` exists at the repository root, read it before starting. It names this project's quality gate command, change points, critical flows and lint limits. If it is missing and a rule depends on it, ask once.

---

**These guidelines are working if:** diffs are small and contain only requested changes, clarifying questions come before implementation rather than after mistakes, new code reuses existing names and patterns, flow tests pass against the running app, and adding an expected variant touches no existing module.
