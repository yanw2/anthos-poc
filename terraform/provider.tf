terraform {
  required_providers {
    google = {
      version = "~> 2.20.0"
    }
    google-beta = {
      version = "~> 2.20.0"
    }
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
}

provider "google-beta" {
  project = var.project_id
  region  = var.region
}
