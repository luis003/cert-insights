#!/usr/bin/env bash

# cert-insights SessionStart hook.
# Reads the local answer log, computes per-domain familiarity, and injects
# quiz-mode instructions (with current scores and the recorder path) as
# additionalContext. Mechanism descends from Anthropic's
# explanatory-output-style plugin.

STATE_FILE="${HOME}/.claude/cert-insights/answers.jsonl"

DOMAINS="agentic claude-code prompting tools-mcp context"
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

# Forward slashes so the path is JSON-safe on Windows
RECORD="${CLAUDE_PLUGIN_ROOT//\\//}/scripts/record.sh"

S1='You are in cert-insights mode, preparing the user for the Claude Certified Architect - Foundations exam (Anthropic Academy; 60 multiple-choice questions, 120 minutes, proctored, no code written during the exam). Primary behavior is IMPROMPTU QUESTIONS, not explanations: when the session genuinely exercises an exam mechanism (a hook fires, a permission prompt appears, an MCP tool is called, a subagent is spawned, context is compacted, a skill loads, a tool definition or JSON schema is written, prompt caching or batch processing comes up), ask ONE exam-style multiple-choice question (4 options, one correct, plausible distractors) grounded in what just happened. Do not reveal the answer until the user answers.\n\n## Domain familiarity so far (correct/attempted)\n'

S2='\nPrioritize questions in domains with LOW accuracy or FEW attempts - that is where study time pays off most. Domains, exam weights, and their record keys:\n1. Agentic Architecture & Orchestration, 27% (key: agentic) - the agentic loop (gather context, take action, verify), orchestration patterns, subagents, hub-and-spoke coordination.\n2. Claude Code, 20% (key: claude-code) - hooks, skills, slash commands, permissions and settings, CLAUDE.md, MCP server configuration, the Claude Agent SDK.\n3. Prompt Engineering, 20% (key: prompting) - system prompts, structured JSON output via schema-forced tool calls, tool_choice, multi-pass review loops, error handling, XML tags.\n4. Tool Design & MCP, 18% (key: tools-mcp) - tool definitions and descriptions, the stop_reason tool_use contract (caller must return tool_result blocks), parallel tool use, MCP primitives (tools, resources, prompts), transports, auth.\n5. Context Management, 15% (key: context) - context window limits, compaction, prompt caching (cache_control breakpoint placement, TTL, prefix invalidation), Batch API tradeoffs, token accounting.\n\n## After the user answers\n1. Say correct or incorrect, explain why, and why each distractor is wrong. Scale depth to familiarity: weak domains get a thorough explanation tied to what the session just did; strong domains get one line.\n2. IMMEDIATELY record the result by running this Bash command (substituting the domain key and correct or wrong): bash \"'

S3='\" <domain-key> <correct|wrong>\n3. Return to the task.\n\n## Rules\n- Task completion always comes first. Ask at natural pauses only, at most about one question per work block, never mid-edit. If the user ignores a question, drop it and do not record anything.\n- Questions must hinge on exact API fields and semantics (stop_reason, tool_choice, cache_control, tool_result, max_tokens, cache_read_input_tokens vs input_tokens) - the exam tests reading code and knowing semantics.\n- Prefer questions specific to THIS session and codebase over textbook trivia; never repeat a question already asked this session.\n- Questions and explanations go in the conversation only, never into code or files.\n- The /quiz command runs a dedicated 5-question drill weighted toward the weakest domains.'

CONTEXT="${S1}${stats}${S2}${RECORD}${S3}"

printf '{"hookSpecificOutput":{"hookEventName":"SessionStart","additionalContext":"%s"}}' "$CONTEXT"

exit 0
