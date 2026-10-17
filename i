#!/usr/bin/env bash
# Install a chosen subset of this package.
# Local:  bash install.sh
# One line:
#   curl -fsSL https://sshdkeyu.github.io/skill-prod-cursor/i | bash
# Prompts read /dev/tty, so the pipe does not swallow the questions.
set -euo pipefail

DEFAULT_BASE="${PRODUCTION_SKILLS_BASE:-https://raw.githubusercontent.com/sshdkeyu/skill-prod-cursor/main}"

TTY=/dev/tty
if [[ ! -r "$TTY" || ! -w "$TTY" ]]; then
  echo "A terminal is required so you can choose what to install." >&2
  exit 1
fi

say() { printf '%s\n' "$*" >"$TTY"; }
ask() {
  local ans
  printf '%s' "$1" >"$TTY"
  IFS= read -r ans <"$TTY" || ans=""
  printf '%s' "$ans"
}
yes() {
  local ans
  ans="$(ask "$1 [y/N] ")"
  [[ "$ans" == [yY] || "$ans" == [yY][eE][sS] ]]
}

SCRIPT_DIR=""
if [[ -n "${BASH_SOURCE[0]:-}" && -f "${BASH_SOURCE[0]}" ]]; then
  SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
fi

from_local() {
  [[ -n "$SCRIPT_DIR" && -f "$SCRIPT_DIR/AGENTS.md" && -d "$SCRIPT_DIR/skills" ]]
}

copy_file() {
  local rel="$1" dest="$2"
  mkdir -p "$(dirname "$dest")"
  if from_local; then
    cp "$SCRIPT_DIR/$rel" "$dest"
  else
    if [[ -z "$DEFAULT_BASE" ]]; then
      say "This script was piped, so it needs the package URL."
      say "Publish install.sh, set DEFAULT_BASE inside it, then:"
      say "  curl -fsSL https://sshdkeyu.github.io/skill-prod-cursor/i | bash"
      exit 1
    fi
    curl -fsSL "$DEFAULT_BASE/$rel" -o "$dest"
  fi
}

# id|label|paths (space-separated, relative to the package root)
ITEMS=(
  "rule00|Rule 00 · global standards|.cursor/rules/00-global-standards.mdc"
  "rule01|Rule 01 · code quality|.cursor/rules/01-code-quality.mdc"
  "rule02|Rule 02 · security|.cursor/rules/02-security.mdc"
  "rule03|Rule 03 · performance|.cursor/rules/03-performance.mdc"
  "rule04|Rule 04 · architecture|.cursor/rules/04-architecture.mdc"
  "rule05|Rule 05 · AWS / IaC|.cursor/rules/05-cloud-aws.mdc"
  "solid|Skill · solid (tests, module shape)|skills/solid/SKILL.md skills/solid/README.md skills/solid/references/tdd.md skills/solid/references/testing.md skills/solid/references/solid-principles.md skills/solid/references/code-smells.md skills/solid/references/object-design.md skills/solid/references/complexity.md"
  "go|Skill · Go|skills/go/SKILL.md skills/go/README.md skills/go/references/bad-vs-good.md"
  "javascript|Skill · JavaScript and TypeScript|skills/javascript/SKILL.md skills/javascript/README.md skills/javascript/references/bad-vs-good.md"
  "data|Skill · data access (N+1)|skills/data-access/SKILL.md skills/data-access/README.md skills/data-access/references/bad-vs-good.md"
  "api|Skill · API design|skills/api-design-assistant/SKILL.md skills/api-design-assistant/README.md examples/bad-vs-good-api-design.md"
  "review|Skill · code review|skills/code-review-expert/SKILL.md skills/code-review-expert/README.md .cursor/templates/pr-review-template.md"
  "refactor|Skill · large refactor|skills/refactor-large-codebase/SKILL.md skills/refactor-large-codebase/README.md"
  "incident|Skill · production incident|skills/debug-production-incident/SKILL.md skills/debug-production-incident/README.md .cursor/templates/incident-report-template.md"
  "production|Skill · package door|skills/production/SKILL.md skills/production/README.md"
)

say "Production skills"
say "Nothing is installed unless you answer y."
say ""

target="$(ask "Install into [${PWD}]: ")"
target="${target:-$PWD}"
mkdir -p "$target"
target="$(cd "$target" && pwd)"

if from_local && [[ "$target" == "$SCRIPT_DIR" ]]; then
  say "That directory is this package. Choose the app repo, not the source tree."
  exit 1
fi

take_all=0
if yes "Install every component?"; then
  take_all=1
fi

selected=()
for row in "${ITEMS[@]}"; do
  id="${row%%|*}"
  rest="${row#*|}"
  label="${rest%%|*}"
  if [[ "$take_all" -eq 1 ]] || yes "  $label?"; then
    selected+=("$id")
  fi
done

if [[ "${#selected[@]}" -eq 0 ]]; then
  say "Nothing selected. No files written."
  exit 0
fi

rule_ids=()
for id in "${selected[@]}"; do
  [[ "$id" == rule* ]] && rule_ids+=("$id")
done

mode=""
glob=""
if [[ "${#rule_ids[@]}" -gt 0 ]]; then
  say ""
  say "How should the selected rules apply?"
  say "  1) Always Apply — every chat"
  say "  2) Apply Intelligently — only when the description matches"
  say "  3) Apply to Specific Files — a glob you type"
  say "  4) Apply Manually — only when @-mentioned"
  choice="$(ask "Choice [2]: ")"
  choice="${choice:-2}"
  case "$choice" in
    1) mode=always ;;
    2) mode=intelligent ;;
    3) mode=files
       glob="$(ask "Glob (example **/*.{go,ts}): ")"
       if [[ -z "$glob" ]]; then
         say "A glob is required for that mode."
         exit 1
       fi
       ;;
    4) mode=manual ;;
    *) say "Unknown choice."; exit 1 ;;
  esac
fi

paths_for() {
  local row id rest
  for row in "${ITEMS[@]}"; do
    id="${row%%|*}"
    [[ "$id" == "$1" ]] || continue
    rest="${row#*|}"
    rest="${rest#*|}"
    set -f
    printf '%s\n' $rest
    set +f
  done
}

installed=()
for id in "${selected[@]}"; do
  while IFS= read -r rel; do
    [[ -n "$rel" ]] || continue
    copy_file "$rel" "$target/$rel"
    installed+=("$rel")
    say "  + $rel"
  done < <(paths_for "$id")
done

# scaling note rides along with performance or data access
need_scaling=0
for id in "${selected[@]}"; do
  [[ "$id" == "rule03" || "$id" == "data" ]] && need_scaling=1
done
if [[ "$need_scaling" -eq 1 ]]; then
  copy_file "examples/scaling-example.md" "$target/examples/scaling-example.md"
  installed+=("examples/scaling-example.md")
  say "  + examples/scaling-example.md"
fi

yaml_quote() {
  local s="$1"
  s="${s//\\/\\\\}"
  s="${s//\"/\\\"}"
  printf '"%s"' "$s"
}

rewrite_rule() {
  local file="$1" desc body
  desc="$(awk 'BEGIN{p=0} /^---$/{p++; next} p==1 && /^description:/ {sub(/^description:[[:space:]]*/,""); print; exit}' "$file")"
  body="$(awk 'BEGIN{p=0} /^---$/{p++; if (p==2){p=3; next}} p>=3{print}' "$file")"
  {
    printf '%s\n' "---"
    case "$mode" in
      always)
        [[ -n "$desc" ]] && printf 'description: %s\n' "$(yaml_quote "$desc")"
        printf '%s\n' "alwaysApply: true"
        ;;
      intelligent)
        [[ -n "$desc" ]] && printf 'description: %s\n' "$(yaml_quote "$desc")"
        printf '%s\n' "alwaysApply: false"
        ;;
      files)
        [[ -n "$desc" ]] && printf 'description: %s\n' "$(yaml_quote "$desc")"
        printf 'globs: %s\n' "$(yaml_quote "$glob")"
        printf '%s\n' "alwaysApply: false"
        ;;
      manual)
        printf '%s\n' "alwaysApply: false"
        ;;
    esac
    printf '%s\n' "---"
    if [[ -n "$body" ]]; then
      printf '%s\n' "$body"
    fi
  } >"$file.tmp"
  mv "$file.tmp" "$file"
}

if [[ -n "$mode" ]]; then
  for id in "${rule_ids[@]}"; do
    while IFS= read -r rel; do
      rewrite_rule "$target/$rel"
    done < <(paths_for "$id")
  done
fi

# architecture template when that rule is selected
for id in "${selected[@]}"; do
  if [[ "$id" == "rule04" ]]; then
    copy_file ".cursor/templates/architecture-doc-template.md" "$target/.cursor/templates/architecture-doc-template.md"
    installed+=(".cursor/templates/architecture-doc-template.md")
    say "  + .cursor/templates/architecture-doc-template.md"
  fi
done

{
  echo "# Production skills package"
  echo
  echo "Before the first edit in a session, read every file listed below. Do not answer a coding question from memory of this index."
  echo
  echo "Installed rules win over skills. A missing path was not installed. Do not invent it."
  echo
  echo "## Installed"
  echo
  for rel in "${installed[@]}"; do
    printf -- '- `%s`\n' "$rel"
  done
} >"$target/AGENTS.md"
say "  + AGENTS.md"

say ""
say "Installed ${#installed[@]} files into $target"
say "Rules apply as: ${mode:-n/a}"
