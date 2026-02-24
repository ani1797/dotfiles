# Guard against double-sourcing
[[ -n "${__BASH_ALIASES_TERRAFORM_LOADED+x}" ]] && return
__BASH_ALIASES_TERRAFORM_LOADED=1

# ~/.config/bash/52-aliases-terraform.bash
# Terraform aliases (only if terraform is installed)

if command -v terraform &>/dev/null; then
  alias tf="terraform"
  alias tfplan="terraform plan"
  alias tfapply="terraform apply"
  alias tfdestroy="terraform destroy"
  alias tffmt="terraform fmt -recursive"
fi
