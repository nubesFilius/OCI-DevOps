output "app_subnets_output" {
  value = oci_core_subnet.app_subnets
}

output "bastion_subnets_output" {
  value = oci_core_subnet.bastion_subnets
}

output "lb_subnets_output" {
  value = oci_core_subnet.lb_subnets
}

output "vcn_output" {
  value = oci_core_vcn.vcns
}
