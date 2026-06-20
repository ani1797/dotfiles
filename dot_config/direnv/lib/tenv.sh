# direnv stdlib extension: tenv (Terraform/OpenTofu/Terragrunt version manager)
# Replaces tfenv for projects using .terraform-version or .opentofu-version.
#
# Usage in .envrc:
#   use tenv              # use version from .terraform-version
#   use tenv 1.9.5        # pin to specific Terraform version
#   use tofu 1.8.0        # pin to specific OpenTofu version
#   use terragrunt 0.67.0 # pin Terragrunt version
#
# Falls back gracefully if tenv is not on PATH.

use_tenv() {
  if ! has tenv; then
    log_status "tenv not on PATH — skipping use_tenv (install: https://tofuutils.github.io/tenv/)"
    return 0
  fi

  local version="${1:-}"
  if [[ -n "${version}" ]]; then
    tenv tf install "${version}" >/dev/null 2>&1 || {
      log_error "tenv tf install ${version} failed"
      return 1
    }
    tenv tf use "${version}" >/dev/null 2>&1 || {
      log_error "tenv tf use ${version} failed"
      return 1
    }
    log_status "Terraform ${version} (tenv)"
  elif [[ -f .terraform-version ]]; then
    local pinned
    pinned=$(cat .terraform-version)
    tenv tf install >/dev/null 2>&1
    tenv tf use "${pinned}" >/dev/null 2>&1
    log_status "Terraform ${pinned} (tenv, .terraform-version)"
  else
    log_status "tenv: no version specified and no .terraform-version found"
  fi

  watch_file .terraform-version
}

use_tofu() {
  if ! has tenv; then
    log_status "tenv not on PATH — skipping use_tofu"
    return 0
  fi

  local version="${1:-}"
  if [[ -n "${version}" ]]; then
    tenv tofu install "${version}" >/dev/null 2>&1
    tenv tofu use "${version}" >/dev/null 2>&1
    log_status "OpenTofu ${version} (tenv)"
  elif [[ -f .opentofu-version ]]; then
    local pinned
    pinned=$(cat .opentofu-version)
    tenv tofu install >/dev/null 2>&1
    tenv tofu use "${pinned}" >/dev/null 2>&1
    log_status "OpenTofu ${pinned} (tenv, .opentofu-version)"
  fi

  watch_file .opentofu-version
}

use_terragrunt() {
  if ! has tenv; then
    log_status "tenv not on PATH — skipping use_terragrunt"
    return 0
  fi

  local version="${1:-}"
  if [[ -n "${version}" ]]; then
    tenv tg install "${version}" >/dev/null 2>&1
    tenv tg use "${version}" >/dev/null 2>&1
    log_status "Terragrunt ${version} (tenv)"
  fi

  watch_file .terragrunt-version
}
