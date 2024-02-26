data "terraform_remote_state" "secrets" {
  backend = "gcs"

  config = {
    bucket = "state-bucket-00"
    prefix = "terraform/state/secrets"
  }
}
