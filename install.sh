#!/usr/bin/env bash
set -euo pipefail

# ---------------------------------------------------------------------------
# skill.sh — install / uninstall local VS Code Copilot skills
# Compatible with bash 3.2+ (macOS default)
# ---------------------------------------------------------------------------

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TARGET_DIR="${VSCODE_USER_PROMPTS_FOLDER:-$HOME/Library/Application Support/Code/User/prompts}"

# Collect skill directories (any dir that contains a SKILL.md)
# Prints one name per line
discover_skills() {
  for d in "$SCRIPT_DIR"/*/; do
    [[ -f "${d}SKILL.md" ]] && echo "$(basename "$d")"
  done
}

install_skill() {
  local name="$1"
  local src="$SCRIPT_DIR/$name"
  local dst="$TARGET_DIR/$name"

  if [[ ! -d "$src" || ! -f "$src/SKILL.md" ]]; then
    echo "  ✗ Skill '$name' not found in this repository." >&2
    return 1
  fi

  mkdir -p "$TARGET_DIR"

  if [[ -e "$dst" ]]; then
    echo "  ~ '$name' already installed, updating..."
    rm -rf "$dst"
  fi

  cp -r "$src" "$dst"
  echo "  ✓ Installed '$name'  ->  $dst"
}

uninstall_skill() {
  local name="$1"
  local dst="$TARGET_DIR/$name"

  if [[ ! -e "$dst" ]]; then
    echo "  ~ '$name' is not installed, skipping."
    return 0
  fi

  rm -rf "$dst"
  echo "  ✓ Uninstalled '$name'"
}

list_skills() {
  local found=0
  echo "Available skills:"
  while IFS= read -r s; do
    found=1
    local dst="$TARGET_DIR/$s"
    if [[ -e "$dst" ]]; then
      echo "  [installed]  $s"
    else
      echo "  [ missing ]  $s"
    fi
  done < <(discover_skills)
  if [[ $found -eq 0 ]]; then
    echo "  (none found)"
  fi
}

install_all() {
  while IFS= read -r s; do install_skill "$s"; done < <(discover_skills)
}

uninstall_all() {
  while IFS= read -r s; do uninstall_skill "$s"; done < <(discover_skills)
}

interactive_select() {
  local action="$1"   # "install" or "uninstall"

  # Load skills into indexed array
  local skills=()
  while IFS= read -r s; do skills+=("$s"); done < <(discover_skills)

  if [[ ${#skills[@]} -eq 0 ]]; then
    echo "No skills found in this repository." >&2
    exit 1
  fi

  echo "Select a skill to $action (enter number, 'a' for all, 'q' to quit):"
  echo ""

  local i=1
  for s in "${skills[@]}"; do
    local dst="$TARGET_DIR/$s"
    if [[ -e "$dst" ]]; then
      echo "  $i) $s  [installed]"
    else
      echo "  $i) $s"
    fi
    ((i++)) || true
  done
  echo "  a) all"
  echo "  q) quit"
  echo ""

  while true; do
    read -rp "Choice: " choice
    case "$choice" in
      q|Q)
        echo "Aborted."
        exit 0
        ;;
      a|A|all)
        for s in "${skills[@]}"; do
          "${action}_skill" "$s"
        done
        return
        ;;
      ''|*[!0-9]*)
        echo "  Invalid choice, try again."
        ;;
      *)
        local idx=$((choice - 1))
        if (( idx >= 0 && idx < ${#skills[@]} )); then
          "${action}_skill" "${skills[$idx]}"
          return
        else
          echo "  Number out of range, try again."
        fi
        ;;
    esac
  done
}

usage() {
  cat <<EOF
Usage: $(basename "$0") <command> [skill-name|all]

Commands:
  install   [<name>|all]   Install a skill (omit name for interactive mode)
  uninstall [<name>|all]   Uninstall a skill (omit name for interactive mode)
  list                     List all available skills and their status
  help                     Show this help message

Examples:
  $(basename "$0") install                 # interactive selection
  $(basename "$0") install my-todo-skill   # install specific skill
  $(basename "$0") install all             # install all skills
  $(basename "$0") uninstall my-todo-skill
  $(basename "$0") uninstall all
  $(basename "$0") list

Target directory: ${TARGET_DIR}
EOF
}

# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------
main() {
  local cmd="${1:-}"
  local target="${2:-}"

  case "$cmd" in
    install)
      if [[ -z "$target" ]]; then
        interactive_select "install"
      elif [[ "$target" == "all" ]]; then
        install_all
      else
        install_skill "$target"
      fi
      ;;
    uninstall)
      if [[ -z "$target" ]]; then
        interactive_select "uninstall"
      elif [[ "$target" == "all" ]]; then
        uninstall_all
      else
        uninstall_skill "$target"
      fi
      ;;
    list)
      list_skills
      ;;
    help|--help|-h|"")
      usage
      ;;
    *)
      echo "Unknown command: '$cmd'" >&2
      echo "" >&2
      usage >&2
      exit 1
      ;;
  esac
}

main "$@"
