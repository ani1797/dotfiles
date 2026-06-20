# 11-paru.zsh — paru (AUR helper) aliases and shell completion
# paru is a Rust-based AUR helper that wraps pacman and is a drop-in
# replacement for yay. All pacman flags work; paru adds AUR support.

command -v paru &>/dev/null || return 0

# --- Completion ---------------------------------------------------------------
# paru ships its own zsh completion; source it if available
if [[ -f /usr/share/zsh/site-functions/_paru ]]; then
  autoload -Uz _paru
fi

# --- Aliases ------------------------------------------------------------------
# Package operations
alias p='paru'
alias pi='paru -S'            # install (repo or AUR)
alias pu='paru -Syu'          # full system upgrade (repo + AUR)
alias pr='paru -Rns'          # remove package + unneeded deps + config
alias pss='paru -Ss'          # search repos + AUR
alias psi='paru -Si'          # show package info (remote)
alias pqi='paru -Qi'          # show package info (installed)
alias pql='paru -Ql'          # list files owned by package
alias pqo='paru -Qo'          # which package owns a file
alias pqe='paru -Qe'          # list explicitly installed packages
alias pqm='paru -Qm'          # list AUR / foreign packages
alias pclean='paru -Sc'       # clean package cache

# porphan — show orphaned packages and confirm before removing
porphan() {
  local orphans
  orphans=$(paru -Qtdq 2>/dev/null)
  if [[ -z "${orphans}" ]]; then
    echo "No orphaned packages."
    return 0
  fi
  echo "Orphaned packages:"
  echo "${orphans}" | sed 's/^/  /'
  echo ""
  read -r "?Remove all orphans? [y/N] " _ans
  [[ "${_ans:l}" == "y" ]] && echo "${orphans}" | paru -Rns - || echo "Aborted."
}
