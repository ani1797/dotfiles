# 20-1password.zsh — 1Password CLI
# Commands:
#   oplog       — sign in (session cached by op CLI)
#   oplogout    — sign out current session
#   oplogoutall — sign out and remove account
#   opload      — load 1Password SSH keys into ssh-agent
#   opload VAULT— load keys from a specific vault only

(( ${+commands[op]} )) || return 0

eval "$(op completion zsh)"
compdef _op op

alias oplog='op signin'
alias oplogout='op signout'
alias oplogoutall='op signout --forget'

opload() {
  op item list --categories "SSH Key" --format json ${1:+--vault "$1"} 2>/dev/null \
    | jq -r '.[] | "\(.vault.id)/\(.id)"' \
    | while IFS= read -r ref; do
        op read "op://${ref}/private_key?ssh-format=openssh" 2>/dev/null | ssh-add - 2>/dev/null
      done
  print "opload: $(ssh-add -l 2>/dev/null | grep -c .) key(s) in agent"
}

# Tab-complete vault names for opload
_opload() {
  local -a vaults=(${(f)"$(op vault list --format json 2>/dev/null | jq -r '.[].name' 2>/dev/null)"})
  (( ${#vaults} )) && _describe 'vault' vaults
}
compdef _opload opload
