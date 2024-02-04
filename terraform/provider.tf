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
  credentials = file("/Users/yaroslavsklabinskyi/Downloads/infrastructure-template-413116-295bb37a8c62.json")
  project = var.project
  region  = var.region
}
