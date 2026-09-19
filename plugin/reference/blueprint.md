# CCA-Foundations exam blueprint

Source: **Claude Certified Architect - Foundations Exam Guide, Version 1.0, effective
July 2026, exam code CCAR-F** (official Anthropic Certification Program PDF, linked from
the Anthropic Partner Academy course page). Retrieved 2026-09-19. This file restates the
blueprint structure and objective titles so question generation can target them. It is a
study aid, not a reproduction of the exam.

Read this file when you need to pick a specific objective to test. Do not paste it into
the conversation.

## Exam format (official)

| Field | Value |
|---|---|
| Items | 60 |
| Item format | Multiple choice **and multiple response**; each item states how many answers to select |
| Structure | 4 scenarios drawn from a bank of 6 |
| Time | 120 minutes |
| Passing score | 720 scaled, on 100 to 1000 |
| Delivery | Proctored, online or test center |
| Reporting | Pass/fail plus percent correct by domain |

Most items are single answer with four options. Occasionally write a multiple response
item that states how many to select, because the real exam mixes both.

## Domains

| # | Domain | Weight | Record key |
|---|---|---|---|
| 1 | Agentic Architecture & Orchestration | 27% | `agentic` |
| 2 | Tool Design & MCP Integration | 18% | `tools-mcp` |
| 3 | Claude Code Configuration & Workflows | 20% | `claude-code` |
| 4 | Prompt Engineering & Structured Output | 20% | `prompting` |
| 5 | Context Management & Reliability | 15% | `context` |

## Scenarios (the exam frames questions inside these)

1. Customer support resolution agent, Agent SDK plus MCP tools, escalation targets.
2. Code generation with Claude Code, slash commands, CLAUDE.md, plan mode.
3. Multi-agent research system, coordinator plus search, analysis, synthesis, report subagents.
4. Developer productivity, built-in tools and MCP servers on unfamiliar codebases.
5. Claude Code in CI/CD, automated review, test generation, false positive control.
6. Structured data extraction, JSON schema validation, edge cases, downstream integration.

## Objectives

Use these ids when recording an answer, for example `record.sh agentic correct 1.3`.

### Domain 1, Agentic Architecture & Orchestration (27%, key `agentic`)

- **1.1** Design and implement agentic loops. Continue on `stop_reason: "tool_use"`, stop on
  `"end_turn"`, append tool results to history. Anti-patterns: parsing natural language for
  termination, iteration caps as the primary stop, reading assistant text as a done signal.
- **1.2** Orchestrate coordinator and subagent systems. Hub and spoke, all routing through the
  coordinator, subagents do not inherit coordinator history, scope partitioning, iterative
  refinement when synthesis shows gaps.
- **1.3** Configure subagent invocation and context passing. The `Task` tool spawns subagents and
  `allowedTools` must include `Task`, context must be passed explicitly in the prompt,
  `AgentDefinition` fields, parallel spawning by emitting several `Task` calls in one response,
  goal-and-criteria prompts over step-by-step procedure.
- **1.4** Multi-step workflows with enforcement and handoff. Programmatic prerequisite gates versus
  prompt guidance, deterministic compliance for things like identity verification before a refund,
  structured handoff summaries for humans who cannot see the transcript.
- **1.5** Agent SDK hooks for interception and normalization. `PostToolUse` to normalize
  heterogeneous tool output, outgoing call interception to block policy violations, hooks for
  guarantees versus prompts for probabilistic compliance.
- **1.6** Task decomposition strategies. Fixed prompt chaining for predictable multi-aspect work,
  dynamic decomposition for open-ended investigation, per-file passes plus a cross-file pass.
- **1.7** Session state, resumption, forking. `--resume <session-name>`, `fork_session` for
  divergent branches off one baseline, telling a resumed session which files changed, choosing a
  fresh session with an injected summary when prior tool results are stale.

### Domain 2, Tool Design & MCP Integration (18%, key `tools-mcp`)

- **2.1** Tool interfaces, descriptions, boundaries. Descriptions drive selection, include input
  formats and edge cases, eliminate overlap by renaming and splitting, watch system prompt
  keywords that override good descriptions.
- **2.2** Structured error responses for MCP tools. The `isError` flag, transient versus validation
  versus business versus permission errors, `errorCategory` and `isRetryable` metadata, local
  recovery in subagents, access failure versus valid empty result.
- **2.3** Tool distribution and tool choice. Too many tools degrades selection, scope tools to a
  role, constrained replacements for generic tools, `tool_choice` values `"auto"`, `"any"`, and
  `{"type": "tool", "name": "..."}`.
- **2.4** MCP server integration. Project scope `.mcp.json` versus user scope `~/.claude.json`,
  `${ENV_VAR}` expansion for credentials, all configured servers discovered at connection time,
  MCP resources as content catalogs, description quality so MCP tools are not passed over for
  built-ins, community servers over custom ones for standard integrations.
- **2.5** Built-in tool selection. `Grep` for content, `Glob` for path patterns, `Read`/`Write` for
  whole files, `Edit` for unique-anchor edits with Read plus Write as the fallback, incremental
  codebase understanding rather than reading everything upfront.

### Domain 3, Claude Code Configuration & Workflows (20%, key `claude-code`)

- **3.1** CLAUDE.md hierarchy and modularity. User, project, and directory levels, user level is
  not shared through version control, `@import` for modular files, `.claude/rules/` instead of one
  monolith, `/memory` to see what is loaded.
- **3.2** Custom slash commands and skills. `.claude/commands/` project versus `~/.claude/commands/`
  personal, `.claude/skills/` SKILL.md frontmatter `context: fork`, `allowed-tools`,
  `argument-hint`, skills for on-demand work versus CLAUDE.md for always-loaded standards.
- **3.3** Path-specific rules. `.claude/rules/` YAML frontmatter `paths` globs, load only when
  editing matching files, glob rules beat directory CLAUDE.md when a convention spans directories.
- **3.4** Plan mode versus direct execution. Plan mode for architectural or multi-file work and safe
  exploration, direct execution for well-scoped changes, the Explore subagent to keep verbose
  discovery out of the main context.
- **3.5** Iterative refinement. Two or three concrete input/output examples, test-driven iteration
  by sharing failures, the interview pattern, one message for interacting issues versus sequential
  fixes for independent ones.
- **3.6** Claude Code in CI/CD. `-p` / `--print` for non-interactive runs, `--output-format json`
  with `--json-schema`, CLAUDE.md as the carrier of review and testing standards, an independent
  instance reviews better than the session that wrote the code, feed prior findings back to avoid
  duplicate comments.

### Domain 4, Prompt Engineering & Structured Output (20%, key `prompting`)

- **4.1** Explicit criteria to reduce false positives. Categorical criteria beat "be conservative"
  or confidence filtering, define severity with concrete examples, false positives in one category
  damage trust in the rest.
- **4.2** Few-shot prompting. Two to four targeted examples for ambiguous cases, examples that show
  the reasoning and the output format, generalization to novel patterns, fewer hallucinated
  extractions across varied document structures.
- **4.3** Structured output via tool use and JSON schemas. Schema-forced `tool_use` removes syntax
  errors but not semantic ones, `tool_choice` `"auto"` versus `"any"` versus a forced named tool,
  nullable/optional fields so the model does not fabricate, `enum` with `"other"` plus a detail
  string, `"unclear"` for ambiguity.
- **4.4** Validation, retry, and feedback loops. Retry with the original document plus the specific
  validation errors, retries do not help when the information is simply absent, `detected_pattern`
  fields for dismissal analysis, `calculated_total` against `stated_total` and `conflict_detected`
  flags.
- **4.5** Batch processing. Message Batches API gives 50% savings with up to a 24 hour window and no
  latency SLA, right for overnight and weekly work and wrong for blocking pre-merge checks, no
  multi-turn tool calling inside a batch request, `custom_id` correlation and failure resubmission,
  submission cadence math against an SLA.
- **4.6** Multi-instance and multi-pass review. A generator reviewing itself keeps its own reasoning
  context, an independent instance catches more, per-file passes plus cross-file integration
  passes, self-reported confidence for routing.

### Domain 5, Context Management & Reliability (15%, key `context`)

- **5.1** Preserve critical information across long interactions. Summarization loses amounts, dates
  and stated expectations, the lost-in-the-middle effect, trim verbose tool output before it
  accumulates, keep a persistent case-facts block outside the summarized history, put key findings
  first in aggregated input.
- **5.2** Escalation and ambiguity resolution. Escalate on explicit human request, policy gaps, and
  lack of progress, sentiment and self-reported confidence are poor proxies, ask for another
  identifier when a lookup returns multiple matches.
- **5.3** Error propagation across multi-agent systems. Structured error context with failure type,
  what was attempted, partial results and alternatives, access failure versus valid empty result,
  never silently suppress and never kill the workflow on one failure, coverage annotations on
  synthesis output.
- **5.4** Context in large codebase exploration. Context degradation in long sessions, scratchpad
  files, subagent delegation for verbose exploration, manifest-based state export for crash
  recovery, `/compact`.
- **5.5** Human review workflows and confidence calibration. Aggregate accuracy hides per-type
  failure, stratified random sampling of high-confidence extractions, field-level confidence
  calibrated on a labeled validation set, segment accuracy before automating.
- **5.6** Provenance and uncertainty in multi-source synthesis. Structured claim-to-source mappings
  preserved through synthesis, annotate conflicting figures instead of picking one, require
  publication or collection dates, render content types appropriately instead of flattening.

## Out of scope, do not write questions on these

Fine-tuning or training custom models. API authentication, billing, or account management.
Language or framework implementation detail beyond tool and schema configuration. Deploying or
hosting MCP servers, which covers infrastructure, networking and container orchestration. Claude's
internal architecture, training process, or weights. Constitutional AI, RLHF, safety training.
Embedding models and vector databases. Computer use. Vision and image analysis. Streaming and
server-sent events. Rate limits, quotas, pricing calculations. OAuth, key rotation, auth protocols.
Specific cloud provider configuration. Benchmarking and model comparison. **Prompt caching
implementation detail beyond knowing it exists**, so no `cache_control` breakpoint placement, TTL,
or prefix invalidation questions. **Token counting algorithms and tokenization specifics.**

The last two are a change from earlier versions of this plugin, which treated cache breakpoints and
token accounting as core Context Management material. The official guide lists both as out of scope.
