
variable service_accounts {
  type = map
}
# networks
variable int_vpc {
  
}
variable ext_vpc {
  
}
variable mgmt_vpc {
  
}
variable mgmt_subnet {
  
}
variable int_subnet {
  
}
variable ext_subnet {
  
}



# device
variable projectPrefix {
  description = "prefix for resources"
}
variable buildSuffix {
  description = "resource suffix"
}
variable name {
  description = "device name"
  default = "cis"
}
# Custom image
variable customImage {
  description = "custom build image name"
  default = ""
}
variable bigipImage {
 description = " bigip gce image name"
 #default = "projects/f5-7626-networks-public/global/images/f5-bigip-15-0-1-1-0-0-3-byol-all-modules-2boot-loc-191118"
 #default = "projects/f5-7626-networks-public/global/images/f5-bigip-15-0-1-1-0-0-3-payg-best-1gbps-191118"
 default = "projects/f5-7626-networks-public/global/images/f5-bigip-15-1-0-4-0-0-6-payg-best-1gbps-200618231635"
}
variable bigipLicense1 {
  description = " bigip license for BYOL"
  default = ""
}

variable bigipMachineType {
    description = "bigip gce machine type/size"
    default = "n1-standard-8"
}

variable vm_count {
    description = " number of devices"
    default = 1
}

variable adminSrcAddr {
  description = "admin source range in CIDR"

}

variable gce_ssh_pub_key_file {
    description = "path to public key for ssh access"
    default = "/root/.ssh/key.pub"
}

# bigip stuff

variable adminAccountName { default = "admin" }
variable adminPass { 
    description = "bigip admin password"
    default = "admin"
 }
variable license1 { default = "" }
variable license2 { default = "" }
variable host1_name { default = "f5vm01" }
variable host2_name { default = "f5vm02" }
variable dns_server { default = "8.8.8.8" }
variable ntp_server { default = "0.us.pool.ntp.org" }
variable timezone { default = "UTC" }

variable libs_dir { default = "/config/cloud/gcp/node_modules" }
variable onboard_log { default = "/var/log/startup-script.log" }