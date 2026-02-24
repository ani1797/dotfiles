# Guard against double-sourcing
[[ -n "${__ZSH_ALIASES_TERRAFORM_LOADED+x}" ]] && return
__ZSH_ALIASES_TERRAFORM_LOADED=1

# ~/.config/zsh/52-aliases-terraform.zsh
# Terraform aliases (only if terraform is installed)

if command -v terraform &>/dev/null; then
  alias tf="terraform"
  alias tfplan="terraform plan"
  alias tfapply="terraform apply"
  alias tfdestroy="terraform destroy"
  alias tffmt="terraform fmt -recursive"
fi
