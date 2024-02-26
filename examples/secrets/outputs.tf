output "atlantis_gh_user" {
  value     = local.atlantis_secrets.ATLANTIS_GH_USER
  sensitive = true
}

output "atlantis_gh_token" {
  value     = local.atlantis_secrets.ATLANTIS_GH_TOKEN
  sensitive = true
}

output "atlantis_gh_webhook_secret" {
  value     = local.atlantis_secrets.ATLANTIS_GH_WEBHOOK_SECRET
  sensitive = true
}

output "atlantis_repo_allowlist" {
  value     = local.atlantis_secrets.ATLANTIS_REPO_ALLOWLIST
  sensitive = true
}
