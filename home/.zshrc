# ============================================================
# ~/.zshrc - interactive shell config
# Convenzione: .zshenv -> env, .zprofile -> login one-shot, .zshrc -> interactive
# ============================================================

# -- History ----------------------------------------------------
HISTSIZE=1000000
SAVEHIST=1000000
HISTFILE=~/.zsh_history
setopt EXTENDED_HISTORY INC_APPEND_HISTORY SHARE_HISTORY
setopt HIST_IGNORE_DUPS HIST_IGNORE_ALL_DUPS HIST_FIND_NO_DUPS HIST_SAVE_NO_DUPS
setopt HIST_REDUCE_BLANKS HIST_VERIFY HIST_IGNORE_SPACE

# -- Completion (sicuro + cached) -------------------------------
FPATH="$HOME/.docker/completions:$FPATH"
autoload -Uz compinit
if [[ -n ${ZDOTDIR:-$HOME}/.zcompdump(#qN.mh+24) ]]; then
  compinit -i
else
  compinit -C -i
fi

# -- Runtime version manager ------------------------------------
eval "$(mise activate zsh)"

# -- Productivity tools -----------------------------------------
eval "$(zoxide init zsh)"
source <(fzf --zsh) 2>/dev/null

# -- Aliases (non sovrascrivono comandi POSIX) ------------------
alias l='eza -lh --git --icons'
alias la='eza -lah --git --icons'
alias lt='eza --tree --icons --level=2'

# -- Cheatsheet (`cheat`, `cheat <sezione>`) --------------------
cheat() {
  local sheet="${HOME}/.config/cheatsheet.md"
  [[ ! -f "$sheet" ]] && { echo "no cheatsheet at $sheet" >&2; return 1; }

  local content
  if [[ -z "$1" ]]; then
    content=$(<"$sheet")
  else
    content=$(awk -v s="$1" '
      BEGIN { p=0; want=tolower(s) }
      /^## / {
        title=tolower($0); sub(/^## /, "", title)
        p = (title == want) ? 1 : 0
      }
      p { print }
    ' "$sheet")
  fi

  if command -v glow >/dev/null 2>&1; then
    print -r -- "$content" | glow -p -
  elif command -v bat >/dev/null 2>&1; then
    print -r -- "$content" | bat --paging=auto --style=plain --language=md
  else
    print -r -- "$content" | less -R
  fi
}
_cheat() {
  local sheet="${HOME}/.config/cheatsheet.md"
  [[ -f "$sheet" ]] && compadd -- ${(f)"$(awk '/^## / {sub(/^## /,""); print}' "$sheet")"}
}
compdef _cheat cheat

# -- iTerm2 shell integration (attivato se installato) ----------
[[ -e "${HOME}/.iterm2_shell_integration.zsh" ]] && \
  source "${HOME}/.iterm2_shell_integration.zsh"

# -- Prompt (deve restare l'ultimo eval) ------------------------
eval "$(starship init zsh)"
