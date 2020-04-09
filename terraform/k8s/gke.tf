resource "google_container_cluster" "primary" {
  name     = "${var.projectPrefix}gke-cluster${var.buildSuffix}"
  location = "${var.gcpZone}"

  # We can't create a cluster with no node pool defined, but we want to only use
  # separately managed node pools. So we create the smallest possible default
  # node pool and immediately delete it.
  remove_default_node_pool = true
  initial_node_count       = 1

  master_auth {
    username = "${var.admin_user}"
    password = "${var.admin_password}"

    client_certificate_config {
      issue_client_certificate = false
    }
  }
}