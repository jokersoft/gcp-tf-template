terraform {
  backend "gcs" {
    bucket = "state-bucket-00"
    prefix = "terraform/state/example-log-bucket"
  }

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.15"
    }
  }
}

provider "google" {
  project = var.project
  region  = var.region
}
