resource "oci_identity_compartment" "compartments" {
  for_each       = var.compartments
  compartment_id = each.value.compartment_id
  description    = each.value.description
  name           = each.value.name
}
