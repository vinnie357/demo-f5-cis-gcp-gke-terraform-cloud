output device_mgmt_ips {
  value = module.cis.device_mgmt_ips
}
output appAddress {
  value = module.cis.appAddress
}

output adminPass {
    value = random_password.password.result
}