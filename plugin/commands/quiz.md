---
description: 5-question CCA-Foundations drill weighted toward your weakest domains
---

Run a 5-question Claude Certified Architect - Foundations drill.

1. Read the familiarity log at `~/.claude/cert-insights/answers.jsonl` (each line:
   `{"ts": ..., "domain": ..., "correct": true|false}`). Compute per-domain
   correct/attempted for the keys `agentic`, `claude-code`, `prompting`,
   `tools-mcp`, `context`. If the log is missing or empty, treat all domains as
   unattempted.
2. Pick 5 questions weighted toward domains with the lowest accuracy or fewest
   attempts (an unattempted domain outranks a weak one). Never more than 2 from
   one domain. Questions are exam-style: 4 options, one correct, plausible
   distractors, hinging on exact API semantics (stop_reason, tool_choice,
   cache_control, tool_result, MCP primitives, agentic loop, Claude Code
   configuration). Where possible, ground them in the current repo or session.
3. Ask ONE question at a time. Wait for the answer. Then say correct or
   incorrect, explain why and why each distractor is wrong, and record it:
   `bash "${CLAUDE_PLUGIN_ROOT}/scripts/record.sh" <domain-key> <correct|wrong>`
4. After question 5, show the updated per-domain tally and name the single
   weakest domain with one concrete thing to review in it.

If the user passed an argument (e.g. `/quiz context`), draw all 5 questions from
that domain key instead of weighting. Arguments: $ARGUMENTS
