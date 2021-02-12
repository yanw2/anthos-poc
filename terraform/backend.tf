terraform {
  backend "gcs" {
    bucket      = "wenjing-poc-terraform-state"
    prefix      = "anthos-poc"
    credentials = "~/.gcp/wenjing-sandbox.json"
  }
}
