# 10-bun.zsh — Bun JavaScript runtime: PATH + shell completions
if [[ -d "${HOME}/.bun" ]]; then
  export BUN_INSTALL="${HOME}/.bun"
  [[ ":${PATH}:" == *":${BUN_INSTALL}/bin:"* ]] || export PATH="${BUN_INSTALL}/bin:${PATH}"
  # Bun shell completions (generated at install time into ~/.bun/_bun)
  [[ -s "${BUN_INSTALL}/_bun" ]] && source "${BUN_INSTALL}/_bun"
fi
