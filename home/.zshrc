# ============================================================
# ~/.zshrc - interactive shell config
# Convenzione: .zshenv -> env, .zprofile -> login one-shot, .zshrc -> interactive
# Versionato in ~/Home/DEV/Brewfile/home/.zshrc (symlink)
# ============================================================

# -- History ----------------------------------------------------
HISTSIZE=1000000
SAVEHIST=1000000
HISTFILE=~/.zsh_history
setopt EXTENDED_HISTORY INC_APPEND_HISTORY SHARE_HISTORY
setopt HIST_IGNORE_DUPS HIST_IGNORE_ALL_DUPS HIST_FIND_NO_DUPS HIST_SAVE_NO_DUPS
setopt HIST_REDUCE_BLANKS HIST_VERIFY HIST_IGNORE_SPACE

# -- Completion (sicuro + cached) -------------------------------
# Rigenera il dump solo se più vecchio di 24h. Il qualifier (#q...) dentro
# [[ ]] richiede EXTENDED_GLOB: senza, la condizione è sempre vera.
FPATH="$HOME/.docker/completions:$FPATH"
autoload -Uz compinit
() {
  setopt local_options extended_glob
  if [[ -n ${ZDOTDIR:-$HOME}/.zcompdump(#qN.mh+24) ]]; then
    compinit -i
  else
    compinit -C -i
  fi
}

# -- Runtime version manager ------------------------------------
eval "$(mise activate zsh)"

# -- Productivity tools -----------------------------------------
eval "$(zoxide init zsh)"
source <(fzf --zsh) 2>/dev/null

# -- Aliases (non sovrascrivono comandi POSIX) ------------------
alias l='eza -lh --git --icons'
alias la='eza -lah --git --icons'
alias lt='eza --tree --icons --level=2'

# -- Cheatsheet: `cheat`, `cheat <sezione>`, `cheat <termine>` ----
# Il comando è ~/.local/bin/cheat; qui solo il completamento delle sezioni.
_cheat() { compadd -- ${(f)"$(cheat --list 2>/dev/null)"} }
compdef _cheat cheat

# -- iTerm2 shell integration (attivato se installato) ----------
[[ -e "${HOME}/.iterm2_shell_integration.zsh" ]] && \
  source "${HOME}/.iterm2_shell_integration.zsh"

# -- Prompt (deve restare l'ultimo eval) ------------------------
eval "$(starship init zsh)"
