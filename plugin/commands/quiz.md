---
description: 5-question CCA-Foundations drill weighted toward your weakest domains
---

Run a 5-question Claude Certified Architect - Foundations drill (exam code CCAR-F).

1. Read the blueprint at `${CLAUDE_PLUGIN_ROOT}/reference/blueprint.md`. It holds the
   five official domains, their weights, and the 30 numbered task statements. Do not
   paste it into the conversation.
2. Read the familiarity log at `~/.claude/cert-insights/answers.jsonl` (each line:
   `{"ts": ..., "domain": ..., "correct": true|false}`, plus `"obj": "1.3"` on lines
   written by v0.3.0 and later). Compute per-domain correct/attempted for the keys
   `agentic`, `tools-mcp`, `claude-code`, `prompting`, `context`, and collect the set
   of objective ids already attempted. If the log is missing or empty, treat every
   domain and objective as unattempted.
3. Pick 5 questions weighted toward domains with the lowest accuracy or fewest
   attempts (an unattempted domain outranks a weak one). Never more than 2 from one
   domain. Within each domain you pick, choose an objective with NO recorded attempt
   before any objective already covered; repeat a covered objective only when the whole
   domain is covered or the user previously got that objective wrong.
4. Questions are exam-style: default to 4 options with exactly one correct answer and
   plausible distractors. Include one multiple-response item in the set if the material
   suits it, and state how many answers to select. Ground each question in the objective
   it tests and, where possible, in the current repo or session. Make them hinge on exact
   fields and semantics (stop_reason, tool_choice, tool_result, isError, allowedTools,
   `context: fork`, `--json-schema`, custom_id, fork_session).
5. ORIGINAL QUESTIONS ONLY. Never reproduce, paraphrase, or reconstruct an item from the
   live exam, a vendor question bank, a braindump, or a practice-test site, and never ask
   the user to recall one. Write every question yourself from the objectives and from
   documented product behavior. Respect the out-of-scope list at the end of the blueprint;
   in particular, no prompt caching implementation detail and no token counting specifics.
6. Ask ONE question at a time. Wait for the answer. Then say correct or incorrect, explain
   why and why each distractor is wrong, and record it:
   `bash "${CLAUDE_PLUGIN_ROOT}/scripts/record.sh" <domain-key> <correct|wrong> <objective-id>`
7. After question 5, show the updated per-domain tally, name the single weakest domain
   with one concrete thing to review in it, and list which of its objectives are still
   uncovered.

If the user passed an argument (e.g. `/quiz context`), draw all 5 questions from that
domain key instead of weighting, still preferring its uncovered objectives.
Arguments: $ARGUMENTS
