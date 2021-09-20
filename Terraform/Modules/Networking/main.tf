resource "oci_core_vcn" "vcns" {
  for_each       = var.vcns
  cidr_block     = each.value.cidr_block
  compartment_id = var.compartments_output[each.key].id
  display_name   = each.value.display_name
}

resource "oci_core_subnet" "app_subnets" {
  for_each                   = var.app_subnets
  cidr_block                 = each.value.cidr_block
  compartment_id             = var.compartments_output["app"].id
  display_name               = each.value.display_name
  vcn_id                     = oci_core_vcn.vcns["app"].id
  prohibit_internet_ingress  = each.value.prohibit_internet_ingress == true ? true : null
  prohibit_public_ip_on_vnic = each.value.prohibit_public_ip_on_vnic == true ? true : null
}

resource "oci_core_subnet" "bastion_subnets" {
  for_each                   = var.bastion_subnets
  cidr_block                 = each.value.cidr_block
  compartment_id             = var.compartments_output["bastion"].id
  display_name               = each.value.display_name
  route_table_id             = oci_core_vcn.vcns["bastion"].default_route_table_id
  vcn_id                     = oci_core_vcn.vcns["bastion"].id
  prohibit_internet_ingress  = each.value.prohibit_internet_ingress == true ? true : null
  prohibit_public_ip_on_vnic = each.value.prohibit_public_ip_on_vnic == true ? true : null
}

resource "oci_core_subnet" "lb_subnets" {
  for_each                   = var.lb_subnets
  cidr_block                 = each.value.cidr_block
  compartment_id             = var.compartments_output["app"].id
  display_name               = each.value.display_name
  route_table_id             = oci_core_vcn.vcns["app"].default_route_table_id
  vcn_id                     = oci_core_vcn.vcns["app"].id
  prohibit_internet_ingress  = each.value.prohibit_internet_ingress == true ? true : null
  prohibit_public_ip_on_vnic = each.value.prohibit_public_ip_on_vnic == true ? true : null
}

resource "oci_core_internet_gateway" "igws" {
  for_each       = var.igws
  compartment_id = var.compartments_output[each.key].id
  vcn_id         = oci_core_vcn.vcns[each.key].id
}

resource "oci_core_default_route_table" "vcn_rts" {
  for_each = var.vcn_rts
  route_rules {
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
    network_entity_id = oci_core_internet_gateway.igws[each.key].id
  }
  manage_default_resource_id = oci_core_vcn.vcns[each.key].default_route_table_id
}

#NON DYNAMIC
resource "oci_core_security_list" "app_sec_lists" {
  compartment_id = var.compartments_output["app"].id
  vcn_id         = oci_core_vcn.vcns["app"].id
  display_name   = format("%s-security_list", oci_core_subnet.app_subnets["app"].display_name)

  ingress_security_rules {
    protocol    = "6"
    source      = format("%s/32", var.compute_bastions_output["bastion"].public_ip)
    source_type = "CIDR_BLOCK"
    stateless   = false
    tcp_options {
      max = 22
      min = 22
    }
  }
  ingress_security_rules {
    protocol    = "6"
    source      = format("%s/32", var.lb_output.ip_address_details[0].ip_address)
    source_type = "CIDR_BLOCK"
    stateless   = false

    tcp_options {
      max = 8080
      min = 8080
      source_port_range {
        max = 80
        min = 80
      }
    }
  }
  depends_on = [oci_core_subnet.app_subnets]
}

resource "oci_core_security_list" "bastion_sec_lists" {
  compartment_id = var.compartments_output["bastion"].id
  vcn_id         = oci_core_vcn.vcns["bastion"].id
  display_name   = format("%s-security_list", oci_core_subnet.bastion_subnets["bastion"].display_name)

  ingress_security_rules {
    protocol    = "6"
    source      = "162.199.218.101/32"
    source_type = "CIDR_BLOCK"
    stateless   = false

    tcp_options {
      max = 22
      min = 22
    }
  }
}

resource "oci_core_security_list" "lb_sec_lists" {
  compartment_id = var.compartments_output["app"].id
  vcn_id         = oci_core_vcn.vcns["app"].id
  display_name   = format("%s-security_list", oci_core_subnet.lb_subnets["lb"].display_name)

  ingress_security_rules {
    protocol    = "6"
    source      = "0.0.0.0/0"
    source_type = "CIDR_BLOCK"
    stateless   = false

    tcp_options {
      max = 80
      min = 80
    }
  }
}


#DYNAMIC
# resource "oci_core_security_list" "app_sec_lists" {
#   for_each       = var.sec_lists
#   compartment_id = var.compartments_output[each.key].id
#   vcn_id         = oci_core_vcn.vcns[each.key].id
#   display_name   = format("%s-security_list", oci_core_subnet.subnets[each.key].display_name)

#   dynamic "ingress_security_rules" {
#     content {
#       protocol    = each.value.protocol
#       source      = each.value.source
#       source_type = each.value.source_type
#       tcp_options {
#         max = each.value.tcp_options_max
#         min = each.value.tcp_options_min
#       }
#     }
#   }
# }


