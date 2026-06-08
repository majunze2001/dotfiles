#!/bin/sh
# Claude Code status line - mirrors p10k lean prompt style
# Elements: [user@host] dir [git branch+status] | model ctx% time

input=$(cat)

cwd=$(echo "$input" | jq -r '.cwd // empty')
model=$(echo "$input" | jq -r '.model.display_name // empty')
used_pct=$(echo "$input" | jq -r '.context_window.used_percentage // empty')

# Directory: show basename of cwd
if [ -n "$cwd" ]; then
  dir=$(basename "$cwd")
else
  dir=$(basename "$(pwd)")
fi

# Git branch and status (skip locks to avoid contention)
git_part=""
if git -C "${cwd:-$(pwd)}" rev-parse --git-dir > /dev/null 2>&1; then
  branch=$(git -C "${cwd:-$(pwd)}" symbolic-ref --short HEAD 2>/dev/null \
           || git -C "${cwd:-$(pwd)}" rev-parse --short HEAD 2>/dev/null)
  if [ -n "$branch" ]; then
    # Staged, unstaged, untracked counts (fast, no lock needed)
    staged=$(git -C "${cwd:-$(pwd)}" diff --cached --name-only 2>/dev/null | wc -l | tr -d ' ')
    unstaged=$(git -C "${cwd:-$(pwd)}" diff --name-only 2>/dev/null | wc -l | tr -d ' ')
    untracked=$(git -C "${cwd:-$(pwd)}" ls-files --others --exclude-standard 2>/dev/null | wc -l | tr -d ' ')
    status_flags=""
    [ "$staged" -gt 0 ]    && status_flags="${status_flags} +${staged}"
    [ "$unstaged" -gt 0 ]  && status_flags="${status_flags} !${unstaged}"
    [ "$untracked" -gt 0 ] && status_flags="${status_flags} ?${untracked}"
    git_part=" $(printf '\xef\x84\xa6') ${branch}${status_flags}"
  fi
fi

# Model (shortened)
model_part=""
[ -n "$model" ] && model_part=" $model"

# Context usage
ctx_part=""
if [ -n "$used_pct" ]; then
  ctx_part=" ctx:$(printf '%.0f' "$used_pct")%"
fi

# Time
time_part=$(date +%H:%M:%S)

printf '\033[1;34m%s\033[0m\033[32m%s\033[0m\033[33m%s\033[0m\033[0m%s  \033[2m%s\033[0m' \
  "$dir" "$git_part" "$model_part" "$ctx_part" "$time_part"
