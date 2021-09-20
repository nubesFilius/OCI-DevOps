# Uncomment if SSH Keys will be generated and managed by TF
# resource "tls_private_key" "public_private_key_pair" {
#   for_each  = var.ssh_keys
#   algorithm = each.value.algorithm
# }

resource "oci_core_instance" "servers" {
  for_each            = var.vms
  display_name        = format("%sServer", each.key)
  availability_domain = var.ad.name
  compartment_id      = var.compartments_output["app"].id
  agent_config {
    plugins_config {
      desired_state = "DISABLED"
      name          = "Vulnerability Scanning"
    }
    plugins_config {
      desired_state = "ENABLED"
      name          = "Compute Instance Monitoring"
    }
    plugins_config {
      desired_state = "ENABLED"
      name          = "Bastion"
    }
  }
  create_vnic_details {
    assign_private_dns_record = true
    assign_public_ip          = true
    subnet_id                 = var.app_subnets_output["app"].id
  }
  is_pv_encryption_in_transit_enabled = "true"
  metadata = {

    ## Uncomment if keys will be mangaged by TF
    # ssh_authorized_keys = tls_private_key.public_private_key_pair[each.key].public_key_openssh

    ## SSH Keys managed locally, comment out if TF will be used for SSH Keys
    ssh_authorized_keys = file("/Users/ernie_py/.ssh/id_rsa.pub")

    ## Uncomment to provision VMs using local .sh script file
    # user_data = each.key == "app" ? base64encode(file("/Users/ernie_py/Documents/SRE Oracle Assessment/Terraform/ubuntuAppProvisioner.sh")) : base64encode(file("/Users/ernie_py/Documents/SRE Oracle Assessment/Terraform/ubuntuGrafanaProvisioner.sh"))
  }
  shape = each.key == "app" ? "VM.Standard.E2.1.Micro" : "VM.Standard2.1"
  source_details {
    source_id   = var.instance_image_ocid["Ubuntu"]
    source_type = "image"
  }

  #TIME OUT - Connection issues
  connection {
    type        = each.value.connection.type
    host        = each.value.assign_public_ip == true ? self.public_ip : self.private_ip
    user        = each.value.connection.user
    private_key = file("/Users/ernie_py/.ssh/id_rsa")
    timeout     = "10m"
  }
  provisioner "remote-exec" {
    inline = each.value.inline
  }
}

resource "oci_core_instance" "bastions" {
  for_each            = var.bastions
  display_name        = format("%sServer", each.key)
  availability_domain = var.ad.name
  compartment_id      = var.compartments_output[each.key].id
  agent_config {
    is_management_disabled = each.value.is_management_disabled
    is_monitoring_disabled = each.value.is_monitoring_disabled
    plugins_config {
      desired_state = "ENABLED"
      name          = "Custom Logs Monitoring"
    }
    plugins_config {
      desired_state = "ENABLED"
      name          = "Compute Instance Monitoring"
    }
    plugins_config {
      desired_state = "ENABLED"
      name          = "Bastion"
    }
  }
  availability_config {
    recovery_action = each.value.recovery_action
  }
  create_vnic_details {
    assign_private_dns_record = each.value.assign_private_dns_record
    assign_public_ip          = each.value.assign_public_ip
    subnet_id                 = var.bastion_subnets_output[each.key].id
  }
  is_pv_encryption_in_transit_enabled = each.value.is_pv_encryption_in_transit_enabled
  metadata = {

    ## Uncomment if keys will be mangaged by TF
    # ssh_authorized_keys = tls_private_key.public_private_key_pair[each.key].public_key_openssh

    ## SSH Keys managed locally, comment out if TF will be used for SSH Keys
    ssh_authorized_keys = file("/Users/ernie_py/.ssh/id_rsa.pub")

    ## Uncomment to provision VMs using local .sh script file
    # user_data = base64encode(file("/Users/ernie_py/Documents/SRE Oracle Assessment/Terraform/ubuntuBastionProvisioner.sh"))
  }
  connection {
    type        = each.value.connection.type
    host        = each.value.assign_public_ip == true ? self.public_ip : self.private_ip
    user        = each.value.connection.user
    private_key = file("/Users/ernie_py/.ssh/id_rsa")
  }
  provisioner "remote-exec" {
    inline = each.value.inline
  }
  shape = "VM.Standard.E2.1.Micro"
  source_details {
    source_id   = var.instance_image_ocid["Ubuntu"]
    source_type = "image"
  }
}