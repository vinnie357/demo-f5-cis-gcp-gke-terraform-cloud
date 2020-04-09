output "device_mgmt_ips" {
  # Result is a map from instance id to private IP address, such as:
  #  {"i-1234" = "192.168.1.2", "i-5678" = "192.168.1.5"}
  value = {
    for instance in google_compute_instance.vm_instance:
    instance.name => "https://${instance.network_interface.1.access_config.0.nat_ip}"
  }
}

output "appAddress" {
  value = {
    for instance in google_compute_instance.vm_instance:
    instance.name => "https://${instance.network_interface.0.access_config.0.nat_ip}"
  }
}