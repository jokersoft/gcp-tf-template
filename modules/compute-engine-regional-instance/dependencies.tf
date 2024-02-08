terraform {
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
