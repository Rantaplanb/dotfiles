#!/usr/bin/env zsh
# functions.zsh - Custom shell functions

# Extract almost any archive
extract() {
  if [ -f "$1" ]; then
    case "$1" in
    *.tar.bz2) tar xjf "$1" ;;
    *.tar.gz) tar xzf "$1" ;;
    *.bz2) bunzip2 "$1" ;;
    *.rar) unrar e "$1" ;;
    *.gz) gunzip "$1" ;;
    *.tar) tar xf "$1" ;;
    *.tbz2) tar xjf "$1" ;;
    *.tgz) tar xzf "$1" ;;
    *.zip) unzip "$1" ;;
    *.Z) uncompress "$1" ;;
    *.7z) 7z x "$1" ;;
    *) echo "'$1' cannot be extracted via extract()" ;;
    esac
  else
    echo "'$1' is not a valid file"
  fi
}

# Find process by name and kill it
killname() {
  ps aux | grep "$1" | grep -v grep | awk '{print $2}' | xargs kill -9
}

# Make directory and enter it.
take() {
  mkdir "$1"
  cd "$1" || return
}

# Show directory contents after changing directories.
autoload -Uz add-zsh-hook
_dotfiles_auto_ls_after_cd() {
  emulate -L zsh
  [[ -t 1 ]] || return 0

  if (( ${+aliases[ls]} )); then
    eval "${aliases[ls]}"
  else
    command ls
  fi
}
add-zsh-hook -d chpwd _dotfiles_auto_ls_after_cd 2>/dev/null || true
add-zsh-hook chpwd _dotfiles_auto_ls_after_cd

# Yazi
function y() {
  local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
  yazi "$@" --cwd-file="$tmp"
  IFS= read -r -d '' cwd <"$tmp"
  [ -n "$cwd" ] && [ "$cwd" != "$PWD" ] && cd -- "$cwd"
  rm -f -- "$tmp"
}

# Publish all current changes from main as an auto-merge pull request.
prm() {
  emulate -L zsh

  local message="${*:-}"
  if [[ -z "$message" ]]; then
    echo 'prm: commit message required (for example: prm "fix: rename label")' >&2
    return 1
  fi

  local required_command
  for required_command in git gh sed tr cut; do
    if ! command -v "$required_command" &>/dev/null; then
      echo "prm: required command not found: $required_command" >&2
      return 1
    fi
  done

  if ! git rev-parse --is-inside-work-tree &>/dev/null; then
    echo "prm: not inside a Git repository" >&2
    return 1
  fi

  local current_branch
  current_branch=$(git branch --show-current) || return 1
  if [[ "$current_branch" != "main" ]]; then
    echo "prm: expected branch 'main', found '${current_branch:-detached HEAD}'" >&2
    return 1
  fi

  if [[ -z "$(git status --porcelain)" ]]; then
    echo "prm: no changes to publish" >&2
    return 1
  fi

  git remote get-url origin &>/dev/null || {
    echo "prm: remote 'origin' is not configured" >&2
    return 1
  }
  gh auth status &>/dev/null || {
    echo "prm: GitHub CLI is not authenticated; run 'gh auth login'" >&2
    return 1
  }

  echo "prm: checking origin/main..."
  git fetch --quiet origin main || return 1
  if ! git merge-base --is-ancestor HEAD origin/main; then
    echo "prm: local main is ahead of or diverged from origin/main; reconcile it before publishing" >&2
    return 1
  fi

  if ! git diff --check; then
    echo "prm: whitespace errors found; fix them before publishing" >&2
    return 1
  fi

  local slug branch
  slug=$(printf '%s' "$message" |
    tr '[:upper:]' '[:lower:]' |
    sed -E 's/[^a-z0-9]+/-/g; s/^-+//; s/-+$//; s/-+/-/g' |
    cut -c1-60)
  if [[ -z "$slug" ]]; then
    echo "prm: commit message cannot be converted to a branch name" >&2
    return 1
  fi

  branch="feat/$slug"
  if git show-ref --verify --quiet "refs/heads/$branch" ||
    git ls-remote --exit-code --heads origin "$branch" &>/dev/null; then
    branch="${branch}-$(date +%Y%m%d-%H%M%S)"
  fi

  echo "prm: creating $branch"
  git switch -c "$branch" origin/main || return 1
  git add -A || return 1
  if git diff --cached --quiet; then
    echo "prm: no staged changes after 'git add -A'" >&2
    return 1
  fi
  git commit -m "$message" || return 1
  git push -u origin "$branch" || return 1

  local pr_url
  pr_url=$(gh pr create \
    --base main \
    --head "$branch" \
    --title "$message" \
    --body 'Created with `prm`.') || return 1
  gh pr merge --auto --squash "$pr_url" || return 1

  echo "prm: auto-merge enabled: $pr_url"
}

# Helper to open file in editor at specific line
_ftext_open_editor() {
  local file="$1" line="$2"
  if [[ -n "$VISUAL" ]]; then
    if [[ "$VISUAL" == *"cursor"* ]]; then
      eval "$VISUAL --goto \"${file}:${line}\""
    elif [[ "$VISUAL" == *"code"* ]]; then
      eval "$VISUAL --goto \"${file}:${line}\""
    else
      eval "$VISUAL \"+${line}\" \"${file}\""
    fi
  else
    echo "VISUAL editor not set. File: ${file}:${line}"
  fi
}

ftext() {
  # Interactive ripgrep search with fzf
  local selected
  selected=$(rg --color=always --line-number --no-heading --smart-case "${*:-}" 2>/dev/null |
    fzf --ansi "${_ftext_fzf_opts[@]}")

  if [[ -n "$selected" ]]; then
    local file=$(echo "$selected" | cut -d: -f1)
    local line=$(echo "$selected" | cut -d: -f2)
    _ftext_open_editor "$file" "$line"
  fi
}

# ZLE widget version of ftext for CTRL-F keybinding
ftext-widget() {
  local original_buffer="$BUFFER"
  local original_cursor="$CURSOR"

  local result
  result=$(rg --color=always --line-number --no-heading --smart-case "" 2>/dev/null |
    fzf --ansi "${_ftext_fzf_opts[@]}" \
      --expect=tab)

  local key=$(echo "$result" | head -n1)
  local selected=$(echo "$result" | tail -n1)

  if [[ -n "$selected" ]]; then
    local file=$(echo "$selected" | cut -d: -f1)
    local line=$(echo "$selected" | cut -d: -f2)

    if [[ "$key" == "tab" ]]; then
      BUFFER="${original_buffer:0:$original_cursor}${file}${original_buffer:$original_cursor}"
      CURSOR=$((original_cursor + ${#file}))
      zle reset-prompt
    else
      BUFFER=""
      zle reset-prompt
      zle -I
      _ftext_open_editor "$file" "$line"
      zle reset-prompt
    fi
  else
    BUFFER="$original_buffer"
    CURSOR="$original_cursor"
    zle reset-prompt
  fi
}

# Update brew
function brew_update() {
  brew update
  brew upgrade
  brew cleanup
  brew doctor
  brew missing
  brew outdated
  brew autoremove
  echo "Homebrew update complete."
}

function reset_internet() {
  sudo killall -HUP mDNSResponder && echo macOS DNS Cache Reset
  sudo pfctl -f /etc/pf.conf
  sudo ifconfig en0 down && sudo ifconfig en0 up
}
