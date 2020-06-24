variable projectPrefix {
  description = "prefix for resources"
}
variable gcpZone {
  description = "zone where gke is deployed"
}

variable buildSuffix {
  description = "resource suffix"
}
variable adminAccount  { 
    description = "admin account" 
}
variable adminPass { 
    description = "admin password"
 }

 variable int_vpc {
  
}
variable int_subnet {
  
}

variable gkeVersion {
    default = "1.16.9-gke.6"
}