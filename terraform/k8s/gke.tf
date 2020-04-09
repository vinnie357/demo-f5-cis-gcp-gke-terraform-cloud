resource "google_container_cluster" "primary" {
  name     = "${var.projectPrefix}gke-cluster${var.buildSuffix}"
  location = "${var.gcpZone}"
  node_version = "1.14.10-gke.27"
  min_master_version = "1.14.10-gke.27"
  default_max_pods_per_node = "110"
  ip_allocation_policy {}
# beta db encrypt
#   database_encryption {
#       state = "DECRYPTED"
#   }
#   node_config = {
#       image_type = "COS"
#       preemptible  = true
#       machine_type = "n1-standard-1"
#       disk_type = "pd-standard"
#       disk_size_gb = 100
#       initial_node_count = 3
#       metadata = {
#           disable-legacy-endpoints = "true"
#       }
#       oauth_scopes = [
#         "https://www.googleapis.com/auth/devstorage.read_only",
#         "https://www.googleapis.com/auth/logging.write",
#         "https://www.googleapis.com/auth/monitoring",
#         "https://www.googleapis.com/auth/servicecontrol",
#         "https://www.googleapis.com/auth/service.management.readonly",
#         "https://www.googleapis.com/auth/trace.append" 
#       ]
#   }
  # We can't create a cluster with no node pool defined, but we want to only use
  # separately managed node pools. So we create the smallest possible default
  # node pool and immediately delete it.
  remove_default_node_pool = true
  initial_node_count       = 1
  network = "${var.int_vpc.name}"
  subnetwork = "${var.int_subnet.name}"
  master_auth {
    # username = "${var.adminAccount}"
    # password = "${var.adminPass}"
    client_certificate_config {
      issue_client_certificate = true
    }
  }
}

resource "google_container_node_pool" "primary_preemptible_nodes" {
  name       = "${var.projectPrefix}node-pool${var.buildSuffix}"
  location   = "${var.gcpZone}"
  cluster    = google_container_cluster.primary.name
  node_count = 3

  node_config = {
      image_type = "COS"
      preemptible  = true
      machine_type = "n1-standard-1"
      disk_type = "pd-standard"
      disk_size_gb = 100
      metadata = {
          disable-legacy-endpoints = "true"
      }
      oauth_scopes = [
        "https://www.googleapis.com/auth/devstorage.read_only",
        "https://www.googleapis.com/auth/logging.write",
        "https://www.googleapis.com/auth/monitoring",
        "https://www.googleapis.com/auth/servicecontrol",
        "https://www.googleapis.com/auth/service.management.readonly",
        "https://www.googleapis.com/auth/trace.append" 
      ]
  }
}