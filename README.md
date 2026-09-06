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

## Exam domains tracked

| Domain | Weight | Record key |
|---|---|---|
| Agentic Architecture & Orchestration | 27% | `agentic` |
| Claude Code | 20% | `claude-code` |
| Prompt Engineering | 20% | `prompting` |
| Tool Design & MCP | 18% | `tools-mcp` |
| Context Management | 15% | `context` |

Weights are from third-party exam guides (freeCodeCamp, community study repos),
not Anthropic. The authoritative exam guide is in your Anthropic Academy account —
if it disagrees, edit the domain list in
[`plugin/hooks-handlers/session-start.sh`](plugin/hooks-handlers/session-start.sh)
and validate with `bash plugin/hooks-handlers/session-start.sh | python -m json.tool`.

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

Three small parts, no dependencies:

1. A `SessionStart` hook ([session-start.sh](plugin/hooks-handlers/session-start.sh))
   computes per-domain scores from the answer log and emits quiz-mode instructions
   as `additionalContext` — the same mechanism as Anthropic's official
   `explanatory-output-style` plugin, which this descends from.
2. A recorder ([record.sh](plugin/scripts/record.sh)) that Claude runs after each
   answered question, appending one JSONL line.
3. The [`/quiz`](plugin/commands/quiz.md) command for deliberate drills.

## Disclaimer

Unofficial and unaffiliated with Anthropic. Question quality is Claude's, not a
licensed item bank — treat this as ambient reinforcement alongside the official
Anthropic Academy course, not as your only prep. Good luck on the exam.
