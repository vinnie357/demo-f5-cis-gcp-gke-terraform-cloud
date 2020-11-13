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

#gcloud container get-server-config --region us-east1
variable gkeVersion {
  description = "GKE release version"
  default     = "1.16.15-gke.1600"
}

# k8s
variable podCidr {
    description = "k8s pod cidr"
    default = "10.56.0.0/14"
}