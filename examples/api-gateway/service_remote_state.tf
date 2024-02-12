data "terraform_remote_state" "service_1" {
  backend = "gcs"

  config = {
    bucket = "state-bucket-00"
    prefix = "terraform/state/example-app"
  }
}
