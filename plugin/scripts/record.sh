#!/usr/bin/env bash

# Append one answered question to the local familiarity log.
# Usage: record.sh <domain-key> <correct|wrong>
# Keys: agentic | claude-code | prompting | tools-mcp | context

d="$1"
r="$2"

case "$d" in
  agentic|claude-code|prompting|tools-mcp|context) ;;
  *) echo "unknown domain key: '$d' (expected agentic|claude-code|prompting|tools-mcp|context)" >&2; exit 1 ;;
esac

case "$r" in
  correct) c=true ;;
  wrong)   c=false ;;
  *) echo "usage: record.sh <domain-key> <correct|wrong>" >&2; exit 1 ;;
esac

STATE_DIR="${HOME}/.claude/cert-insights"
mkdir -p "$STATE_DIR"
printf '{"ts":"%s","domain":"%s","correct":%s}\n' \
  "$(date -u +%Y-%m-%dT%H:%M:%SZ)" "$d" "$c" >> "${STATE_DIR}/answers.jsonl"

echo "recorded: $d $r"
