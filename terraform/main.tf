/*
Copyright 2018 Google LLC

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    https://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
*/

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

resource "google_container_cluster" "cluster" {
  provider = google-beta

  name    = var.cluster_name
  project = var.project_id
  // Zonal Cluster
  location = var.zones[0]
  // Remove the first zone and list just the remaining zones
  node_locations = slice(var.zones, 1, length(var.zones))

  network    = google_compute_network.network.self_link
  subnetwork = google_compute_subnetwork.subnetwork.self_link

  min_master_version = "latest"
  logging_service    = "logging.googleapis.com/kubernetes"
  monitoring_service = "monitoring.googleapis.com/kubernetes"

  remove_default_node_pool = "true"
  initial_node_count       = 1

  // Disable legacy ABAC. The default is false, but explicitly ensuring it's off
  enable_legacy_abac = false

  // Enable Binary Authorization
  enable_binary_authorization = "true"

  // Default Maximum Pods Per Node for all Node Pools
  // NodePool max_pods_per_node overrides for that node pool
  default_max_pods_per_node = 110

  // Configure various addons
  addons_config {
    // Enable network policy (Calico)
    network_policy_config {
      disabled = false
    }

    // Provide the ability to scale pod replicas based on real-time metrics
    horizontal_pod_autoscaling {
      disabled = true
    }

    istio_config {
      // AUTH_MUTUAL_TLS ensures strict mTLS
      // AUTH_NONE is required for cloud run
      disabled = true
      auth     = "AUTH_MUTUAL_TLS"
    }

    cloudrun_config {
      disabled = true
    }
  }
  // Enable TPU support for the cluster
  enable_tpu = "false"
  // Enable intranode visibility
  // Requires enabling VPC Flow Logging on the subnet first
  enable_intranode_visibility = "false"
  // Enable Kubernetes Alpha support
  // NOTE: This cluster will only live for 30 days
  enable_kubernetes_alpha = "false"

  pod_security_policy_config {
    enabled = "false"
  }

  vertical_pod_autoscaling {
    enabled = "false"
  }

  // Disable basic authentication and cert-based authentication.
  // Empty fields for username and password are how to "disable" the
  // credentials from being generated.
  master_auth {
    username = ""
    password = ""

    client_certificate_config {
      issue_client_certificate = "false"
    }
  }

  // Enable network policy configurations (like Calico) - for some reason this
  // has to be in here twice.
  network_policy {
    enabled = "true"
  }

  // Allocate IPs in our subnetwork
  ip_allocation_policy {
    use_ip_aliases                = true
    cluster_secondary_range_name  = google_compute_subnetwork.subnetwork.secondary_ip_range.0.range_name
    services_secondary_range_name = google_compute_subnetwork.subnetwork.secondary_ip_range.1.range_name
  }

  // Specify the list of CIDRs which can access the master's API
  master_authorized_networks_config {
    cidr_blocks {
      cidr_block   = "10.0.0.0/8"
      display_name = "10/8 IPs"
    }
  }

  // Configure the cluster to have private nodes and private control plane access only
  private_cluster_config {
    enable_private_endpoint = "true"
    enable_private_nodes    = "true"
    master_ipv4_cidr_block  = "172.16.0.16/28"
  }

  lifecycle {
    ignore_changes = [initial_node_count]
  }

  timeouts {
    create = "30m"
    update = "30m"
    delete = "30m"
  }

  depends_on = [
    google_project_service.service,
    google_project_iam_member.service-account,
    google_project_iam_member.service-account-custom,
    google_compute_router_nat.nat,
  ]

}
resource "google_container_node_pool" "my-node-pool-np" {
  provider   = google-beta
  name       = "my-node-pool"
  location   = var.zones[0]
  cluster    = google_container_cluster.cluster.name
  node_count = "1"

  max_pods_per_node = 64

  autoscaling {
    min_node_count = 2
    max_node_count = 10
  }

  management {
    auto_repair  = "true"
    auto_upgrade = "false"
  }

  node_config {
    machine_type    = "n1-standard-1"
    disk_type       = "pd-ssd"
    disk_size_gb    = 50
    image_type      = "COS"
    preemptible     = "true"
    local_ssd_count = 0

    // Use the cluster created service account for this node pool
    service_account = google_service_account.gke-sa.email

    oauth_scopes = [
      "https://www.googleapis.com/auth/devstorage.read_only",
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
      "https://www.googleapis.com/auth/servicecontrol",
      "https://www.googleapis.com/auth/service.management.readonly",
      "https://www.googleapis.com/auth/trace.append",
    ]

    labels = {
      l1    = "v1"
      l2    = "v2"
      seven = "eight"
    }

    tags = [
      "blue",
      "green",
    ]

    // Protect node metadata
    workload_metadata_config {
      node_metadata = "SECURE"
    }

    metadata = {
      // Set metadata on the VM to supply more entropy
      google-compute-enable-virtio-rng = "true"
      // Explicitly remove GCE legacy metadata API endpoint
      disable-legacy-endpoints = "true"
    }
  }

  depends_on = [
    google_container_cluster.cluster,
  ]
}
resource "google_container_node_pool" "my-other-nodepool-np" {
  provider   = google-beta
  name       = "my-other-nodepool"
  location   = var.zones[0]
  cluster    = google_container_cluster.cluster.name
  node_count = "1"

  max_pods_per_node = 110

  autoscaling {
    min_node_count = 1
    max_node_count = 1
  }

  management {
    auto_repair  = "true"
    auto_upgrade = "false"
  }

  node_config {
    machine_type    = "n1-standard-2"
    disk_type       = "pd-ssd"
    disk_size_gb    = 50
    image_type      = "COS"
    preemptible     = "false"
    local_ssd_count = 0

    // Use the cluster created service account for this node pool
    service_account = google_service_account.gke-sa.email

    oauth_scopes = [
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
      "https://www.googleapis.com/auth/trace.append",
    ]

    labels = {
      l1 = "v1"
      l2 = "v2"
    }

    tags = [
      "blue",
      "green",
      "red",
      "white",
    ]
    // Protect node metadata
    workload_metadata_config {
      node_metadata = "SECURE"
    }

    metadata = {
      // Set metadata on the VM to supply more entropy
      google-compute-enable-virtio-rng = "true"
      // Explicitly remove GCE legacy metadata API endpoint
      disable-legacy-endpoints = "true"
    }

  }

  depends_on = [
    google_container_cluster.cluster,
  ]
}
