# cis
resource google_compute_firewall mgmt {
  name    = "${var.projectPrefix}mgmt-cis${var.buildSuffix}"
  network = var.mgmt_vpc.name

  allow {
    protocol = "icmp"
  }

  allow {
    protocol = "tcp"
    ports    = [ "22", "443"]
  }

  source_ranges = [var.adminSrcAddr]
}
resource google_compute_firewall app {
  name    = "${var.projectPrefix}app-cis${var.buildSuffix}"
  network = var.ext_vpc.name

  allow {
    protocol = "icmp"
  }

  allow {
    protocol = "tcp"
    ports    = ["80", "443", "22"]
  }

  allow {
    protocol = "udp"
    ports    = ["4433"]
  }


  source_ranges = [var.adminSrcAddr]
}
# Setup Onboarding scripts
data template_file vm_onboard {
  template = "${file("${path.root}/cis/templates/onboard_baseline.tpl")}"

  vars = {
    uname        	      = var.adminAccountName
    upassword        	  = var.adminPass
    doVersion             = "latest"
    #example version:
    #as3Version            = "3.16.0"
    as3Version            = "latest"
    tsVersion             = "latest"
    cfVersion             = "latest"
    fastVersion           = "0.2.0"
    doExternalDeclarationUrl = "https://example.domain.com/do.json"
    as3ExternalDeclarationUrl = "https://example.domain.com/as3.json"
    tsExternalDeclarationUrl = "https://example.domain.com/ts.json"
    cfExternalDeclarationUrl = "https://example.domain.com/cf.json"
    libs_dir		        = var.libs_dir
    onboard_log		      = var.onboard_log
    DO1_Document        = data.template_file.vm01_do_json.rendered
    DO2_Document        = data.template_file.vm02_do_json.rendered
    projectPrefix       = var.projectPrefix
    buildSuffix         = var.buildSuffix
  }
}
#Declarative Onboarding template 01
data template_file vm01_do_json {
  template = "${file("${path.root}/cis/templates/${var.vm_count >= 2 ? "cluster" : "${var.bigipLicense1 != "" ? "standalone_byol" : "standalone"}"}.json")}"

  vars = {
    #Uncomment the following line for BYOL
    #local_sku	    = "${var.license1}"

    host1	    = var.host1_name
    host2	    = var.host2_name
    local_host      = var.host1_name
    remote_host	    = var.host2_name
    dns_server	    = var.dns_server
    ntp_server	    = var.ntp_server
    timezone	    = var.timezone
    admin_user      = var.adminAccountName
    admin_password  = var.adminPass
    bigipLicense1  = var.bigipLicense1
  }
}
#Declarative Onboarding template 02
data template_file vm02_do_json {
  template = "${file("${path.root}/cis/templates/${var.vm_count >= 2 ? "cluster" : "standalone"}.json")}"

  vars = {
    #Uncomment the following line for BYOL
    #local_sku      = "${var.license2}"

    host1           = var.host1_name
    host2           = var.host2_name
    local_host      = var.host2_name
    remote_host     = var.host1_name
    dns_server      = var.dns_server
    ntp_server      = var.ntp_server
    timezone        = var.timezone
    admin_user      = var.adminAccountName
    admin_password  = var.adminPass
  }
}

# bigips
resource google_compute_instance vm_instance {
  count            = var.vm_count
  name             = "${var.projectPrefix}${var.name}-${count.index + 1}-instance${var.buildSuffix}"
  machine_type = var.bigipMachineType
  tags = ["allow-health-checks"]
  boot_disk {
    initialize_params {
      image = "${var.customImage != "" ? "${var.customImage}" : "${var.bigipImage}"}"
      size = "128"
    }
  }
  metadata = {
    ssh-keys = "${var.adminAccountName}:${var.gce_ssh_pub_key_file}"
    block-project-ssh-keys = true
    # this is best for a long running instance as it is only evaulated and run once, changes to the template do NOT destroy the running instance.
    #startup-script = "${data.template_file.vm_onboard.rendered}"
    deviceId = "${count.index + 1}"
 }
 # this is best for dev, as it runs ANY time there are changes and DESTROYS the instances
  metadata_startup_script = data.template_file.vm_onboard.rendered

  network_interface {
    # external
    # A default network is created for all GCP projects
    network       = var.ext_vpc.name
    subnetwork = var.ext_subnet.name
    # network = "${google_compute_network.vpc_network.self_link}"
    access_config {
    }
  }
  network_interface {
    # mgmt
    # A default network is created for all GCP projects
    network       = var.mgmt_vpc.name
    subnetwork = var.mgmt_subnet.name
    # network = "${google_compute_network.vpc_network.self_link}"
    access_config {
    }
  }
    network_interface {
    # internal
    # A default network is created for all GCP projects
    network       = var.int_vpc.name
    subnetwork = var.int_subnet.name
    # network = "${google_compute_network.vpc_network.self_link}"
    # access_config {
    # }
  }
    service_account {
    # https://cloud.google.com/sdk/gcloud/reference/alpha/compute/instances/set-scopes#--scopes
    # email = "${var.service_accounts.compute}"
    scopes = [ "storage-ro", "logging-write", "monitoring-write", "monitoring", "pubsub", "service-management" , "service-control" ]
    # scopes = [ "storage-ro"]
  }
#     provisioner "local-exec" {
#     command = <<-EOF
#       ansible-playbook  --version
#     EOF
#   }
# # Copies the script file to /tmp/script.sh
#   provisioner "file" {
#     source      = "script.sh"
#     destination = "/tmp/script.sh"
#   }

#   provisioner "remote-exec" {
#     inline = [
#       "chmod +x /tmp/script.sh",
#       "/tmp/script.sh args",
#     ]
#   }
}
# resource "google_storage_bucket" "instance-store-1" {
#   name     = "${google_compute_instance.vm_instance.0.name}-storage"
#   location = "US"

#   website {
#     main_page_suffix = "index.html"
#     not_found_page   = "404.html"
#   }
# }
# resource "google_storage_bucket" "instance-store-2" {
#   name     = "${google_compute_instance.vm_instance.1.name}-storage"
#   location = "US"

#   website {
#     main_page_suffix = "index.html"
#     not_found_page   = "404.html"
#   }
# }
resource google_storage_bucket bigip-ha {
  name     = "${var.projectPrefix}bigip-storage${var.buildSuffix}"
  location = "US"

  website {
    main_page_suffix = "index.html"
    not_found_page   = "404.html"
  }
}

resource google_storage_bucket_object bigip-1 {
name = "bigip-1"
content = google_compute_instance.vm_instance.0.network_interface.2.network_ip
bucket = google_storage_bucket.bigip-ha.name
}
resource google_storage_bucket_object bigip-2 {
name = "bigip-2"
content = "${var.vm_count >= 2 ? "${google_compute_instance.vm_instance.1.network_interface.2.network_ip}" : "none" }"
bucket = google_storage_bucket.bigip-ha.name
}

resource null_resource wait {
   #https://ilhicas.com/2019/08/17/Terraform-local-exec-run-always.html
   triggers = {
    always_run = "${timestamp()}"
  }
  provisioner "local-exec" {
    command = <<-EOF
        checks=0
        while [[ "$checks" -lt 4 ]]; do
            echo "waiting on: https://${google_compute_instance.vm_instance.0.network_interface.1.access_config.0.nat_ip}" 
            curl -sk --retry 15 --retry-connrefused --retry-delay 10 https://${google_compute_instance.vm_instance.0.network_interface.1.access_config.0.nat_ip}
        if [ $? == 0 ]; then
            echo "mgmt ready"
            break
        fi
        echo "mgmt not ready yet"
        let checks=checks+1
        sleep 10
        done
    EOF
    interpreter = ["bash", "-c"]
  }
}
##
# # revoke licenses
# data "template_file" "revokefile" {
#   template = "${file("${path.root}/cis/templates/revoke.sh")}"
#   vars ={
#       ip = "${google_compute_instance.vm_instance.0.network_interface.1.access_config.0.nat_ip}"
#       adminAccount = "${var.adminAccountName}"
#   }
# }
# resource "local_file" "revoke_license" {
#   content     = "${data.template_file.revokefile.rendered}"
#   filename    = "${path.module}/revokeLicense.sh"
# }
##
# gcloud compute instances describe afm-1-instance --format='get(networkInterfaces[0].accessConfigs[0].natIP)'

#output "f5vm01_mgmt_public_ip" { value = "${google_compute_instance.afm-1-instance.access_config[0].natIP}" }

# // A variable for extracting the external ip of the instance
# output "ip" {
#  value = "${google_compute_instance.default.network_interface.0.access_config.0.nat_ip}"
# }

# // A variable for extracting the external ip of the instance
# output "ip" {
#  value = "${google_compute_instance.default.network_interface.0.access_config.0.nat_ip}"
# }

# as3
# provider "bigip" {
#     address = "${google_compute_instance.vm_instance.0.network_interface.0.access_config.0.nat_ip}"
#     #address = "34.73.208.201"
#     username = "${var.adminAccountName}"
#     password = "${var.adminPass}"
# }

# data "template_file" "as3" {
#   template = "${file("${path.module}/templates/scca_gcp.json")}"
#   vars ={
#       uuid = "uuid()"
#       virtualIP = "${google_compute_instance.vm_instance.0.network_interface.1.network_ip}"
#   }
# }
# resource "bigip_as3"  "as3-example" {
#      as3_json = "${data.template_file.as3.rendered}"
#      config_name = "Example"
# }