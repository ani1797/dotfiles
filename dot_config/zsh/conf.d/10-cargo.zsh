# source cargo environment (rustup)
if [[ -r "${HOME}/.cargo/env" ]]; then
  . "${HOME}/.cargo/env"
fi

# Generate rustup + cargo completions once into fpath
if command -v rustup >/dev/null 2>&1; then
  _zfuncdir="${HOME}/.local/share/zsh/site-functions"
  mkdir -p "${_zfuncdir}" 2>/dev/null
  [[ -s "${_zfuncdir}/_rustup" ]] || rustup completions zsh       > "${_zfuncdir}/_rustup" 2>/dev/null
  [[ -s "${_zfuncdir}/_cargo"  ]] || rustup completions zsh cargo > "${_zfuncdir}/_cargo"  2>/dev/null
  unset _zfuncdir
fi
