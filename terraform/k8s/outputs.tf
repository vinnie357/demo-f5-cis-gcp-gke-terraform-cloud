#
output podCidr {
  value = google_container_cluster.primary.ip_allocation_policy.0.cluster_ipv4_cidr_block
}

output podSubnet {
  value = google_container_cluster.primary.ip_allocation_policy.0.cluster_secondary_range_name
}
