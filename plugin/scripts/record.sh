#!/usr/bin/env bash

# Append one answered question to the local familiarity log.
# Usage: record.sh <domain-key> <correct|wrong> [objective-id]
# Keys: agentic | claude-code | prompting | tools-mcp | context
# Objective id is the blueprint task-statement number, e.g. 1.3 or 4.5.
# It is optional; lines written before v0.3.0 carry no objective field and
# still count toward the per-domain tally.

d="$1"
r="$2"
o="$3"

case "$d" in
  agentic|claude-code|prompting|tools-mcp|context) ;;
  *) echo "unknown domain key: '$d' (expected agentic|claude-code|prompting|tools-mcp|context)" >&2; exit 1 ;;
esac

case "$r" in
  correct) c=true ;;
  wrong)   c=false ;;
  *) echo "usage: record.sh <domain-key> <correct|wrong> [objective-id]" >&2; exit 1 ;;
esac

obj=""
if [ -n "$o" ]; then
  case "$o" in
    [1-5].[1-9]|[1-5].[1-9][0-9]) obj="$o" ;;
    *) echo "ignoring malformed objective id: '$o' (expected e.g. 1.3)" >&2 ;;
  esac
fi

STATE_DIR="${HOME}/.claude/cert-insights"
mkdir -p "$STATE_DIR"

if [ -n "$obj" ]; then
  printf '{"ts":"%s","domain":"%s","correct":%s,"obj":"%s"}\n' \
    "$(date -u +%Y-%m-%dT%H:%M:%SZ)" "$d" "$c" "$obj" >> "${STATE_DIR}/answers.jsonl"
  echo "recorded: $d $r ($obj)"
else
  printf '{"ts":"%s","domain":"%s","correct":%s}\n' \
    "$(date -u +%Y-%m-%dT%H:%M:%SZ)" "$d" "$c" >> "${STATE_DIR}/answers.jsonl"
  echo "recorded: $d $r"
fi
