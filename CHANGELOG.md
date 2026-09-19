# Changelog

## 0.3.0 - 2026-09-19

Reconciled the exam blueprint against the official exam guide. Until now the domain list
came from third-party guides; it is now taken from the Anthropic Certification Program
document itself.

### Sources used

| Source | Fetched | Status | Official? |
|---|---|---|---|
| Claude Certified Architect - Foundations Exam Guide, version 1.0, effective July 2026, exam code CCAR-F (PDF, 39 pages, 628,815 bytes, from the Everpath/Skilljar course content bucket) | 2026-09-19 | HTTP 200, text extracted with pdftotext | Yes. Self-describes as "the authoritative reference for candidates". |
| Anthropic Partner Academy course page for the certification (Skilljar) | 2026-09-19 | HTTP 200 | Yes, but gated. Confirms the $125 fee and that the PDF above is the exam guide; publishes no domains, weights, item count or duration. |
| `paullarionov/claude-certified-architect`, `guide_en.md` | 2026-09-19 | HTTP 200, 194,238 bytes | No. Community study guide that states it is "Based on the Official Exam Guide". |

The earlier fetch attempts recorded in `003-os/docs/flashcard-sources.md` (2026-09-18) had
returned 403 for the PDF and the portal. A plain curl with a browser User-Agent got both.

### Changed

- **Domain names now match the official blueprint.** Weights and record keys are unchanged,
  so `~/.claude/cert-insights/answers.jsonl` history stays valid.
  - `agentic` 27%: Agentic Architecture & Orchestration (unchanged)
  - `tools-mcp` 18%: Tool Design & MCP **Integration**
  - `claude-code` 20%: Claude Code **Configuration & Workflows**
  - `prompting` 20%: Prompt Engineering **& Structured Output**
  - `context` 15%: Context Management **& Reliability**
- **New `plugin/reference/blueprint.md`** with all 30 official task statements, the six exam
  scenarios, the exam format table and the official out-of-scope list. The session-start hook
  now points at this file by path instead of inlining objectives, so it costs nothing until
  a question actually needs it.
- **Objective-level tracking.** `record.sh` takes an optional third argument, the blueprint
  objective id (for example `1.3`), and writes it as an `obj` field. Lines without the field
  still count toward the per-domain tally, so nothing in the existing log is invalidated.
  Session start now also reports which objective ids have been attempted.
- **Coverage-first rule** added to the injected guidance and to `/quiz`: prefer an objective
  with no recorded attempt over one already covered, before repeating within a domain.
- **Originality rule** added: never reproduce, paraphrase or reconstruct an item from the
  live exam, a vendor question bank, a braindump or a practice-test site, and never ask the
  user to recall one.
- **Exam format corrected** in the injected text: 60 items, 120 minutes, passing score 720 on
  a 100 to 1000 scale, 4 scenarios drawn from a bank of 6, and items are multiple choice **or
  multiple response**, with each item stating how many answers to select. The previous text
  described the exam as entirely four-option single answer.

### Removed

- **Prompt caching questions.** The official guide lists "prompt caching implementation
  details (beyond knowing it exists)" as out of scope. `cache_control` breakpoint placement,
  TTL and prefix invalidation were previously a headline topic of the Context Management
  domain description and of the question-style rule. They are gone, and the blueprint records
  them as out of scope.
- **Token accounting questions.** "Token counting algorithms or tokenization specifics" is
  also out of scope, so `cache_read_input_tokens` versus `input_tokens` is no longer offered
  as a question hook.

### Notes on disagreements between sources

- The community guide says the exam draws 4 scenarios from a bank of **8**. The official
  guide says **6**, and lists them. The official value is used.
- An older note in the author's own memory listed the fifth domain as "Cost Optimization".
  There is no Cost Optimization domain. The phrase does not appear in the official guide or
  in the community guide. The cost material that exists (Message Batches API, 50% savings,
  24-hour window) sits inside Domain 4 as task statement 4.5.
- Domain weights agree across the official guide and the community guide at 27/18/20/20/15.
