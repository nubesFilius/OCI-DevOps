resource "oci_load_balancer_load_balancer" "app_lb" {
  compartment_id = var.compartments_output["app"].id
  display_name   = "app_lb"
  shape          = "100Mbps"
  subnet_ids     = [var.lb_subnets_output["lb"].id]
}

resource "oci_load_balancer_backend_set" "app_lb" {
  health_checker {
    protocol = "HTTP"
    port     = 8080
    url_path = "/fibonacci-members"
  }
  load_balancer_id = oci_load_balancer_load_balancer.app_lb.id
  name             = format("%s-backendset", oci_load_balancer_load_balancer.app_lb.display_name)
  policy           = "LEAST_CONNECTIONS"
}

resource "oci_load_balancer_backend" "app8080" {
  backendset_name  = oci_load_balancer_backend_set.app_lb.name
  ip_address       = var.compute_servers_output["app"].public_ip
  load_balancer_id = oci_load_balancer_load_balancer.app_lb.id
  port             = 8080
}

resource "oci_load_balancer_listener" "app_lb" {
  default_backend_set_name = oci_load_balancer_backend_set.app_lb.name
  load_balancer_id         = oci_load_balancer_load_balancer.app_lb.id
  name                     = format("%s-listener", oci_load_balancer_load_balancer.app_lb.display_name)
  port                     = 80
  protocol                 = "HTTP"
}
