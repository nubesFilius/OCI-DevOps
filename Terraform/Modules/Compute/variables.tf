variable "app_subnets_output" {}
variable "bastion_subnets_output" {}
variable "lb_subnets_output" {}
variable "ad" {}
variable "oci_tenancy" {}
variable "instance_image_ocid" {
  type = map(string)
  default = {
    #us-ashburn-1
    Ubuntu = "ocid1.image.oc1.iad.aaaaaaaakdybjqysepqx2iwne24uxdx4apzdcn2ll7kd66a52fgs7w4mz3vq"
  }
}
variable "compartments_output" {}
variable "vms" {}
variable "ssh_keys" {}
variable "bastions" {}
