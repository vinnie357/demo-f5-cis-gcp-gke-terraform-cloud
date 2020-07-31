output device_mgmt_ips {
  value = module.cis.device_mgmt_ips
}
output appAddress {
  value = module.cis.appAddress
}

output adminPass {
    value = var.adminPass != "" ? var.adminPass : random_password.password.result
}

output adminAccountName {
    value = var.adminAccountName
}