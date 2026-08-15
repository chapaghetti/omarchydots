#!/usr/bin/env bash
set -euo pipefail

BACKUP_ROOT="${BACKUP_ROOT:-$HOME/.dotbackups}"
MAX_BACKUPS=3

SOURCES=(
  "$HOME/.config/hypr"
  "$HOME/.config/omarchy"
  "$HOME/.bashrc.d"
  "$HOME/.bashrc"
)

RED=$'\033[31m'
GREEN=$'\033[32m'
YELLOW=$'\033[33m'
BOLD=$'\033[1m'
RESET=$'\033[0m'

fatal() { echo "${RED}error: $*${RESET}" >&2; exit 1; }

list_backups() {
  local i label newest
  echo "${BOLD}Existing backups:${RESET}"
  for ((i = 1; i <= MAX_BACKUPS; i++)); do
    if [[ -d "$BACKUP_ROOT/$i" ]]; then
      newest=$(find "$BACKUP_ROOT/$i" -type f -not -name .timestamp -printf '%T@ %p\n' 2>/dev/null |
        sort -nr | awk 'NR == 1 { print $2 }')
      newest="${newest#"$BACKUP_ROOT/$i"/}"
      label=$(stat -c %y "$BACKUP_ROOT/$i" 2>/dev/null | cut -d. -f1)
      echo "  ${GREEN}$i${RESET}) $label  [last change: $newest]"
    else
      echo "  ${GREEN}$i${RESET}) (empty)"
    fi
  done
}

select_slot() {
  local prompt=$1 choice
  while :; do
    read -rp "$prompt " choice
    [[ "$choice" == "q" || "$choice" == "Q" ]] && { echo "Aborted."; exit 1; }
    if [[ "$choice" =~ ^[1-9]$ ]] && ((choice >= 1 && choice <= MAX_BACKUPS)); then
      echo "$choice"
      return
    fi
    echo "${YELLOW}Invalid choice; pick 1-$MAX_BACKUPS or q.${RESET}" >&2
  done
}

restore_from() {
  local slot=$1
  local prefix="$BACKUP_ROOT/$slot/${HOME#/}"
  local src rel from

  [[ -d "$prefix" ]] || fatal "backup #$slot has no data at $prefix"

  read -rp "Restore backup #$slot to its destinations, overwriting conflicts? [y/N] " confirm
  [[ "$confirm" =~ ^[yY]$ ]] || { echo "Aborted."; exit 1; }

  for src in "${SOURCES[@]}"; do
    rel="${src#"$HOME"/}"
    from="$prefix/$rel"
    if [[ -d "$from" ]]; then
      mkdir -p "$src"
      rsync -a --delete "$from/" "$src/"
      echo "  restored $src"
    elif [[ -f "$from" ]]; then
      mkdir -p "$(dirname "$src")"
      cp -a "$from" "$src"
      echo "  restored $src"
    else
      echo "${YELLOW}  warning: $from missing in backup, skipping${RESET}" >&2
    fi
  done

  echo "${GREEN}Restore complete. Reloading ~/.bashrc...${RESET}"
  # shellcheck disable=SC1090
  source "$HOME/.bashrc" || echo "${YELLOW}warning: sourcing ~/.bashrc failed${RESET}" >&2
}

do_backup() {
  local slot=$1 dest="$BACKUP_ROOT/$1"
  local src exists=0

  rm -rf "$dest"
  mkdir -p "$dest"
  for src in "${SOURCES[@]}"; do
    if [[ -e "$src" ]]; then
      rsync -a --relative "$src" "$dest/" 2>/dev/null ||
        cp -a --parents "$src" "$dest/" 
      exists=1
    else
      echo "${YELLOW}warning: $src does not exist, skipping${RESET}" >&2
    fi
  done

  [[ $exists -eq 1 ]] || fatal "no sources found; nothing to back up"
  date > "$dest/.timestamp"
  echo "${GREEN}Backup written to $dest${RESET}"
}

used_slots() {
  local i c=0
  for ((i = 1; i <= MAX_BACKUPS; i++)); do
    [[ -d "$BACKUP_ROOT/$i" ]] && c=$((c + 1))
  done
  echo "$c"
}

usage() {
  echo "Usage: $0 [backup|restore]"
  echo "  backup  - snapshot current config into a slot (default)"
  echo "  restore - copy a slot back over current config"
  exit 1
}

main() {
  command -v rsync >/dev/null 2>&1 || echo "${YELLOW}rsync not found, falling back to cp${RESET}" >&2

  local mode="${1:-backup}"
  case "$mode" in
    backup) ;;
    restore) ;;
    -h | --help) usage ;;
    *) usage ;;
  esac

  if [[ ! -d "$BACKUP_ROOT" ]]; then
    mkdir -p "$BACKUP_ROOT"
    echo "No backups yet; creating $BACKUP_ROOT"
    do_backup 1
    exit 0
  fi

  list_backups
  echo

  local choice
  if [[ "$mode" == "restore" ]]; then
    choice=$(select_slot "${BOLD}Restore which slot?${RESET}")
    [[ -d "$BACKUP_ROOT/$choice" ]] || fatal "backup #$choice is empty"
    restore_from "$choice"
  else
    echo "${BOLD}Which slot should this new backup overwrite?${RESET}"
    echo "  Enter a number 1-$MAX_BACKUPS"
    [[ $(used_slots) -lt $MAX_BACKUPS ]] && echo "  (or an empty slot to keep your history)"
    echo "  q = quit"
    choice=$(select_slot ">")
    if [[ -d "$BACKUP_ROOT/$choice" ]]; then
      read -rp "Overwrite backup #$choice? [y/N] " confirm
      [[ "$confirm" =~ ^[yY]$ ]] || { echo "Aborted."; exit 1; }
    fi
    do_backup "$choice"
  fi
}

main "$@"
