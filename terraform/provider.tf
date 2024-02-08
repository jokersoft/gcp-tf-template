terraform {
  backend "gcs" {
    bucket = "state-bucket-00"
    prefix = "terraform/state/template-app"
  }

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.15"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.0"
    }
  }
}

provider "google" {
  project = var.project
  region  = var.region
}
