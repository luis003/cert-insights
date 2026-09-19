# cert-insights

Study for the **Claude Certified Architect - Foundations** exam *while you work*.

Instead of flashcards, this Claude Code plugin turns your real sessions into prep:
when a session actually exercises something the exam tests — a hook fires, an MCP
tool is called, a subagent spawns, a `cache_control` breakpoint or `tool_choice`
comes up — Claude asks you one exam-style multiple-choice question about it, at a
natural pause. Answers are logged locally per exam domain, and every new session
reads that log, so questions (and the depth of the explanations after you answer)
steer toward the domains you are weakest in.

## What you get

- **Impromptu questions** grounded in what your session just did, not textbook
  trivia. At most ~1 per work block; the task always comes first.
- **Familiarity tracking**: answers append to `~/.claude/cert-insights/answers.jsonl`
  (local only, never leaves your machine). Session start injects your current
  per-domain score and tells Claude to prioritize weak/unattempted domains.
- **`/quiz`** — an on-demand 5-question drill weighted toward your weakest
  domains (`/quiz context` drills a single domain; keys below).

## What it looks like

You work normally. When your session does something the exam tests, Claude slips
in one question at the next natural pause:

> *[Claude just wired up an MCP server in your project]*
>
> Quick one while that sinks in, **Tool Design & MCP Integration**: Claude calls a tool and
> the API response has `stop_reason: "tool_use"`. What must your code do next?
>
> A. Retry the request with a higher `max_tokens`
> B. Send a new message containing a `tool_result` block for each `tool_use` block
> C. Wait for a webhook with the tool output
> D. Nothing — the API executes the tool server-side
>
> **You:** B
>
> Correct — the API never executes tools; your code runs them and returns
> `tool_result` blocks referencing each `tool_use` id. (D is the classic trap.)
> `recorded: tools-mcp correct (1.1)`

That `recorded:` line is the tracking: your answer lands in a local log, and
every future session reads it, steering questions toward whatever you keep
getting wrong. Want a focused session instead? Run `/quiz`.

## Exam domains tracked

| # | Domain | Weight | Record key |
|---|---|---|---|
| 1 | Agentic Architecture & Orchestration | 27% | `agentic` |
| 2 | Tool Design & MCP Integration | 18% | `tools-mcp` |
| 3 | Claude Code Configuration & Workflows | 20% | `claude-code` |
| 4 | Prompt Engineering & Structured Output | 20% | `prompting` |
| 5 | Context Management & Reliability | 15% | `context` |

Domains and weights are taken from the official **Claude Certified Architect -
Foundations Exam Guide, version 1.0, effective July 2026, exam code CCAR-F**
(reconciled 2026-09-19). The 30 task statements under these domains, the six exam
scenarios, and the official out-of-scope list live in
[`plugin/reference/blueprint.md`](plugin/reference/blueprint.md), which the
session-start hook references by path rather than inlining, so it is loaded only
when a question needs it.

Answers are recorded per domain *and* per objective
(`record.sh <domain-key> <correct|wrong> [objective-id]`), and both the hook and
`/quiz` prefer objectives with no recorded attempt over ones already covered.

If a newer exam guide disagrees, edit
[`plugin/reference/blueprint.md`](plugin/reference/blueprint.md) and the domain
list in
[`plugin/hooks-handlers/session-start.sh`](plugin/hooks-handlers/session-start.sh),
then validate with
`bash plugin/hooks-handlers/session-start.sh | python -m json.tool`.

Note: prompt caching implementation detail and token counting specifics are
**out of scope** for this exam, so the plugin no longer asks about them. See
[CHANGELOG.md](CHANGELOG.md).

## Install

From GitHub:

```
claude plugin marketplace add <github-user>/cert-insights
claude plugin install cert-insights@cert-insights
```

Or from a local clone:

```
claude plugin marketplace add /path/to/cert-insights
claude plugin install cert-insights@cert-insights
```

Pause without uninstalling: `claude plugin disable cert-insights` (do this after
the exam — the hook adds ~3.5KB of instructions to every session).

Reset your familiarity log: delete `~/.claude/cert-insights/answers.jsonl`.

**Windows**: the hooks run via `bash`, so Git Bash must be on PATH (it is with any
standard Git for Windows install). macOS/Linux work out of the box.

## How it works

Four small parts, no dependencies:

1. A `SessionStart` hook ([session-start.sh](plugin/hooks-handlers/session-start.sh))
   computes per-domain scores and attempted objectives from the answer log and emits
   quiz-mode instructions as `additionalContext` — the same mechanism as Anthropic's
   official `explanatory-output-style` plugin, which this descends from.
2. A blueprint ([blueprint.md](plugin/reference/blueprint.md)) holding the official
   domains, the 30 task statements and the out-of-scope list. Referenced by path from
   the hook, so it is read only when a question needs a specific objective.
3. A recorder ([record.sh](plugin/scripts/record.sh)) that Claude runs after each
   answered question, appending one JSONL line with the domain, the result and the
   objective id.
4. The [`/quiz`](plugin/commands/quiz.md) command for deliberate drills.

## Disclaimer

Unofficial and unaffiliated with Anthropic. Question quality is Claude's, not a
licensed item bank — treat this as ambient reinforcement alongside the official
Anthropic Academy course, not as your only prep. Good luck on the exam.
