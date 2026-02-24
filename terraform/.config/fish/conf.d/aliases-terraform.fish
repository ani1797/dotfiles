# ~/.config/fish/conf.d/aliases-terraform.fish
# Terraform aliases (only if terraform is installed)

if type -q terraform
    alias tf='terraform'
    alias tfplan='terraform plan'
    alias tfapply='terraform apply'
    alias tfdestroy='terraform destroy'
    alias tffmt='terraform fmt -recursive'
end
