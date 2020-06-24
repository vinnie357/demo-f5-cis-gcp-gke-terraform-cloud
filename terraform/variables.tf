#project
variable projectPrefix {
    description = "prefix for resources"
    default = "cis-demo-"
}
variable gcpProjectId {
  description = "project where resources are created"
}
# env
variable gcpRegion {
  description = "default region"
  default = "us-east1"
}
variable gcpZone {
  description = "default zone"
  default = "us-east1-b"
}
variable gcpServiceAccounts {
  type = map
  default = {
      storage = "default-compute@developer.gserviceaccount.com"
      compute = "default-compute@developer.gserviceaccount.com"
    }
}
# admin 
variable adminSrcAddr {
  description = "admin source range in CIDR x.x.x.x/24"
}

variable adminAccountName {
  description = "admin account name"
}
variable adminPass {
  description = "admin account password"
  default = ""
}
variable gceSshPubKey {
  description = "ssh public key for instances"
}

# cis
variable instanceCount {
  description = "number of instances"
  default = 1
}
variable appName {
  description = "app name"
  default = "cis"
}
# Custom image
variable customImage {
  description = "custom build image name"
  default = ""
}
variable bigipLicense1 {
  description = " bigip license for BYOL"
  default = ""
}