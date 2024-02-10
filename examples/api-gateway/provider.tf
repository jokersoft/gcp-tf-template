terraform {
  backend "gcs" {
    bucket = "state-bucket-00"
    prefix = "terraform/state/example-gateway"
  }

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.15"
    }
    google-beta = {
      source  = "hashicorp/google-beta"
      version = "~> 5.15"
    }
  }
}

provider "google" {
  project = var.project
  region  = var.region
}
