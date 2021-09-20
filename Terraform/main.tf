
# Similar to a Service Principal
/*
provider "oci" {
   auth = "InstancePrincipal"
   region = "${var.region}"
}
*/


# Auth for quick testing
provider "oci" {
  #API Key Auth
  /*
  tenancy_ocid     = var.oci_tenancy
  user_ocid        = var.oci_user
  fingerprint      = var.oci_fingerprint
  private_key_path = var.oci_key
  region           = var.oci_region
  */

  # STS Auth
  auth                = "SecurityToken"
  config_file_profile = "ernie_oci"
}


data "oci_identity_availability_domains" "ads" {
  compartment_id = var.oci_tenancy
}

module "Compute" {
  source                 = "./Modules/Compute"
  ad                     = data.oci_identity_availability_domains.ads.availability_domains[2]
  app_subnets_output     = module.Networking.app_subnets_output
  bastion_subnets_output = module.Networking.bastion_subnets_output
  lb_subnets_output      = module.Networking.lb_subnets_output
  oci_tenancy            = var.oci_tenancy
  compartments_output    = module.Identity.compartments_output
  vms                    = var.vms
  bastions               = var.bastions
  ssh_keys               = var.ssh_keys
  # ngw                    = module.Networking.ngw
}

module "Identity" {
  source       = "./Modules/Identity"
  compartments = var.compartments
}

module "LoadBalancer" {
  source                 = "./Modules/LoadBalancer"
  app_subnets_output     = module.Networking.app_subnets_output
  bastion_subnets_output = module.Networking.bastion_subnets_output
  lb_subnets_output      = module.Networking.lb_subnets_output
  compute_servers_output = module.Compute.compute_servers_output
  oci_tenancy            = var.oci_tenancy
  vcn_output             = module.Networking.vcn_output
  compartments_output    = module.Identity.compartments_output
}

module "Networking" {
  source                  = "./Modules/Networking"
  oci_tenancy             = var.oci_tenancy
  app_subnets             = var.app_subnets
  bastion_subnets         = var.bastion_subnets
  lb_subnets              = var.lb_subnets
  lb_output               = module.LoadBalancer.lb_output
  compartments_output     = module.Identity.compartments_output
  compute_bastions_output = module.Compute.compute_bastions_output
  vcns                    = var.vcns
  vcn_rts                 = var.vcn_rts
  igws                    = var.igws

}

# output "bastion_ssh_keys" {
#   value     = module.Compute.bastion_ssh_keys
#   sensitive = true
# }

# output "app_ssh_keys" {
#   value     = module.Compute.app_ssh_keys
#   sensitive = true
# }

# output "ssh_keys" {
#   value     = module.Compute.public_private_key_pair
#   sensitive = true
# }
