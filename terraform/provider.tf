terraform {
  backend "gcs" {
    bucket = "state-bucket-00"
    prefix = "terraform/state/template-app"
  }

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.14"
    }
  }
}

provider "google" {
  project = var.project
  region  = var.region
}
