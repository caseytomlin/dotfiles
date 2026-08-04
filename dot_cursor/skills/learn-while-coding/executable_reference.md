# Learn-while-coding reference

Detail for the skill body. Read when applying Teach scaffolding, the hint ladder,
transfer checks, or a learning-opportunity exercise.

## TODO(human) scaffolding

### Request contributions for

- Business logic with multiple valid approaches
- Error-handling / retry / timeout strategy
- Algorithm or data-structure core
- AuthZ / security-sensitive branches
- Domain invariants and validation rules
- UX decisions that change behavior

### Do not request contributions for

- Boilerplate and repetitive wiring
- Obvious CRUD with no meaningful choice
- Config, imports, renames, formatting
- Pure mechanical refactors

### Pattern

1. Create or edit the file with surrounding context in place.
2. Add a clear signature / types / docstring.
3. Insert a marker, e.g.:

```text
# TODO(human): choose session timeout policy (sliding vs hard).
# Tradeoff: sliding is better UX; hard timeout is stricter security.
def handle_session_timeout(...):
    raise NotImplementedError("TODO(human)")
```

4. Tell the user: file path, what to implement, tradeoffs, success criteria.
5. Review their fill with feedback; do not silently rewrite unless they ask.

### Paste-test

In Teach mode: if pasting your reply would complete the learning target with no
user reasoning, delete or withhold the load-bearing part and leave `TODO(human)`.

## Hint ladder

Use one rung per reply unless the user asks to skip ahead.

| Rung | What you give | Example |
|------|---------------|---------|
| 1 Nudge | Where to look / concept name | "This is about ownership / borrow checking near the loop." |
| 2 Question | One question | "What happens to the reference after move into the vec?" |
| 3 Partial | Fragment or pseudocode | Outline steps; leave the critical condition blank |
| 4 Analogous | Worked similar problem | Solve a smaller twin; ask them to map it back |
| 5 Solution | Full answer + why | Only after ladder or explicit "just show me" |

If they still lack the schema after rung 4, show the analogous example, then return
to their problem at rung 2–3—do not dump their full solution immediately.

## Transfer check

After Verified / Understood / Explainable, ask one of:

- "If we change constraint X to Y, what breaks or what would you change?"
- "Give a counterexample input this would mishandle."
- "Same idea in a different module—what stays and what differs?"

A weak or missing answer → one short teaching beat, then re-check. Do not block
forever in Pair if they want to move on; note the gap and continue.

## Learning exercises

Offer **once** after material work. One exercise, 10–15 minutes max. Optional.

### When to offer

- New files / modules
- Schema or API contract changes
- Non-trivial refactors or new patterns
- First use of an unfamiliar library in the session
- User asked "why" during the work

### When not to offer

- Speed mode / explicit opt-out
- Trivial one-liners
- Already offered earlier in the same task
- User is mid-incident / just wants the fix

### Exercise menu (pick one)

1. **Predict** — Before revealing behavior: "What does this path return for input Z?"
2. **Explain-back** — User explains the change in their own words; stress-test gaps.
3. **Quiz** — 2–3 short questions (debug, read, concept)—no multiple-choice walls.
4. **Rewrite-from-memory** — Close the diff; reimplement the core function blank.
5. **Critique** — "What would you reject in this PR and why?"
6. **Orient** (on request) — Guided walk of data flow / module boundaries for the area touched.

### Facilitation tips

- Pause for their answer before correcting.
- Wrong predictions are useful—treat them as data, not failure.
- Prefer their codebase as the example, not a toy snippet.
- End with one sentence: what to remember next time.

## Hypothesis before AI

Before deep analysis or a generated fix, ask for:

- What they think the cause is (or "no idea")
- What they already tried

Then use the model to confirm / refute their hypothesis. Do not let the first AI
framing of the problem replace their attempt to frame it.

## End-of-session pulse (optional)

If the session was long or Teach-heavy, one line is enough:

> Today: mostly shipping, mostly learning, or both?

No lecture—just surface the second metric.
