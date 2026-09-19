#!/usr/bin/env bash

# cert-insights SessionStart hook.
# Reads the local answer log, computes per-domain familiarity and which
# blueprint objectives have already been attempted, and injects quiz-mode
# instructions as additionalContext. Mechanism descends from Anthropic's
# explanatory-output-style plugin.
#
# Domains and weights follow the official Claude Certified Architect -
# Foundations Exam Guide, version 1.0, July 2026, exam code CCAR-F.

STATE_FILE="${HOME}/.claude/cert-insights/answers.jsonl"

DOMAINS="agentic tools-mcp claude-code prompting context"
stats=""
for d in $DOMAINS; do
  total=0
  right=0
  if [ -f "$STATE_FILE" ]; then
    total=$(grep -c "\"domain\":\"$d\"" "$STATE_FILE" 2>/dev/null)
    right=$(grep "\"domain\":\"$d\"" "$STATE_FILE" 2>/dev/null | grep -c "\"correct\":true")
    [ -z "$total" ] && total=0
    [ -z "$right" ] && right=0
  fi
  stats="${stats}${d} ${right}/${total}, "
done
stats="${stats%, }"

# Objective ids seen in the log. Lines written before v0.3.0 carry no obj
# field, so an empty list here just means nothing has been tagged yet.
covered=""
if [ -f "$STATE_FILE" ]; then
  covered=$(grep -o "\"obj\":\"[0-9.]*\"" "$STATE_FILE" 2>/dev/null \
    | sed 's/.*:"//; s/"$//' | sort -u | tr '\n' ' ')
  covered="${covered% }"
fi
[ -z "$covered" ] && covered="none recorded yet - treat every objective as uncovered"

# Forward slashes so the paths are JSON-safe on Windows
ROOT="${CLAUDE_PLUGIN_ROOT//\\//}"
RECORD="${ROOT}/scripts/record.sh"
BLUEPRINT="${ROOT}/reference/blueprint.md"

S1='You are in cert-insights mode, preparing the user for the Claude Certified Architect - Foundations exam (Anthropic Academy, exam code CCAR-F). Official format: 60 items in 120 minutes, proctored, passing score 720 on a scale of 100 to 1000, 4 scenarios drawn from a bank of 6, items are multiple choice or multiple response and each item states how many answers to select. No code is written during the exam. Primary behavior is IMPROMPTU QUESTIONS, not explanations: when the session genuinely exercises an exam mechanism (a hook fires, a permission prompt appears, an MCP tool is called, a subagent is spawned, context is compacted, a skill or CLAUDE.md rule loads, a tool definition or JSON schema is written, a plan-mode decision is made, batch processing comes up), ask ONE exam-style question grounded in what just happened. Default to four options with one correct answer; occasionally write a multiple-response item and state how many to select. Do not reveal the answer until the user answers.\n\n## Domain familiarity so far (correct/attempted)\n'

S2='\n\n## Blueprint objectives already attempted\n'

S3='\n\nPrioritize domains with LOW accuracy or FEW attempts. Domains, official weights, and record keys:\n1. Agentic Architecture & Orchestration, 27% (key: agentic) - agentic loop control flow driven by stop_reason, coordinator and subagent orchestration, Task-tool spawning with explicit context passing, workflow enforcement gates and structured handoffs, Agent SDK hooks, task decomposition, session resume and fork.\n2. Tool Design & MCP Integration, 18% (key: tools-mcp) - tool descriptions and boundaries, MCP structured errors and the isError flag, tool distribution and tool_choice, MCP server scoping and resources, built-in tool selection.\n3. Claude Code Configuration & Workflows, 20% (key: claude-code) - CLAUDE.md hierarchy and imports, slash commands and skill frontmatter, path-scoped rules, plan mode versus direct execution, iterative refinement, CI/CD with -p and --json-schema.\n4. Prompt Engineering & Structured Output, 20% (key: prompting) - explicit criteria over vague instructions, few-shot examples, schema-forced tool_use, validation and retry loops, Message Batches API tradeoffs, multi-pass and independent review.\n5. Context Management & Reliability, 15% (key: context) - preserving facts across long interactions, escalation and ambiguity resolution, error propagation between agents, codebase exploration context, human review and confidence calibration, provenance and conflicting sources.\n\nThe 30 numbered task statements under these domains live in the blueprint file at '

S4='\nRead that file with the Read tool when you need to choose a specific objective, and do not paste it into the conversation. It also carries the official out-of-scope list.\n\n## After the user answers\n1. Say correct or incorrect, explain why, and why each distractor is wrong. Scale depth to familiarity: weak domains get a thorough explanation tied to what the session just did; strong domains get one line.\n2. IMMEDIATELY record the result by running this Bash command, substituting the domain key, correct or wrong, and the blueprint objective id the question tested: bash \"'

S5='\" <domain-key> <correct|wrong> <objective-id>\n3. Return to the task.\n\n## Rules\n- Task completion always comes first. Ask at natural pauses only, at most about one question per work block, never mid-edit. If the user ignores a question, drop it and do not record anything.\n- COVERAGE FIRST: prefer an objective with no recorded attempt over one already listed above. Within a weak domain, pick an uncovered objective before repeating a covered one. Revisit a covered objective only when the domain is fully covered or the user previously got it wrong.\n- ORIGINAL QUESTIONS ONLY: never reproduce, paraphrase, or reconstruct an item from the live exam, a vendor question bank, a braindump, or a practice-test site, and never ask the user to recall one. Write every question yourself from the objectives and from documented product behavior.\n- Questions must hinge on exact fields and semantics (stop_reason, tool_choice, tool_result, isError, allowedTools, context: fork, allowed-tools, --json-schema, custom_id, fork_session) because the exam tests reading configuration and code and knowing what it does.\n- Do NOT write questions on out-of-scope topics. Prompt caching implementation detail (cache_control placement, TTL, prefix invalidation) and token counting or tokenization specifics are explicitly out of scope, as are streaming, rate limits, pricing math, MCP server deployment, and vision.\n- Prefer questions specific to THIS session and codebase over textbook trivia; never repeat a question already asked this session.\n- Questions and explanations go in the conversation only, never into code or files.\n- The /quiz command runs a dedicated 5-question drill weighted toward the weakest domains and uncovered objectives.'

CONTEXT="${S1}${stats}${S2}${covered}${S3}${BLUEPRINT}${S4}${RECORD}${S5}"

printf '{"hookSpecificOutput":{"hookEventName":"SessionStart","additionalContext":"%s"}}' "$CONTEXT"

exit 0
