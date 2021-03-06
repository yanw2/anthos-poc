// GCP project

variable "project_id" {
  description = <<-EOF
  GCP Project ID where all components will be deployed.
  EOF
  default     = "wenjing-sandbox"
}

variable "project_services" {
  type = list(string)

  default = [
    "cloudresourcemanager.googleapis.com",
    "container.googleapis.com",
    "compute.googleapis.com",
    "iam.googleapis.com",
    "logging.googleapis.com",
    "monitoring.googleapis.com",
  ]

  description = <<-EOF
  The GCP APIs that should be enabled in this project.
  EOF
}

variable "region" {
  description = <<-EOF
  GCP Region where the components will be deployed.
  EOF
  default     = "australia-southeast1"
}

variable "zones" {
  description = ""
  default     = ["australia-southeast1-a", "australia-southeast1-b", "australia-southeast1-c"]
}

// GKE

variable "cluster_name" {
  description = "The name of the GKE cluster"
  default     = "my-cluster"
}

variable "service_account_iam_roles" {
  type = list(string)

  default = [
    "roles/logging.logWriter",
    "roles/monitoring.metricWriter",
    "roles/monitoring.viewer",
  ]

  description = <<-EOF
  List of the default IAM roles to attach to the service account on the
  GKE Nodes.
  EOF
}

variable "service_account_custom_iam_roles" {
  type    = list(string)
  default = []

  description = <<-EOF
  List of arbitrary additional IAM roles to attach to the service account on
  the GKE nodes.
  EOF
}
