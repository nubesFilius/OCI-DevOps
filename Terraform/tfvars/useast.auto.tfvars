oci_tenancy     = "ocid1.tenancy.oc1..aaaaaaaarzshiuiwoc22qsupvuwnx32z7i3cpcpvd3j2bsn5ecmd6ca5faqq"
oci_user        = "ocid1.user.oc1..aaaaaaaajsjbmok2k5nkte5szev6adxr4keixkgg3eua3swdhupi4t56j5xq"
oci_fingerprint = "dd:dd:90:7a:52:2b:eb:45:1b:0c:35:03:23:37:92:00"
oci_key         = "/Users/ernie_py/.oci/sessions/ernie_oci/oci_api_key.pem"
oci_region      = "us-ashburn-1"
compartments = {
  "app" = {
    compartment_id = "ocid1.tenancy.oc1..aaaaaaaarzshiuiwoc22qsupvuwnx32z7i3cpcpvd3j2bsn5ecmd6ca5faqq"
    description    = "Compartment for Apps and LBs"
    name           = "Applications"
  },
  "bastion" = {
    compartment_id = "ocid1.tenancy.oc1..aaaaaaaarzshiuiwoc22qsupvuwnx32z7i3cpcpvd3j2bsn5ecmd6ca5faqq"
    description    = "Compartment for Bastions"
    name           = "Bastions"
  }
}

vcns = {
  "app" = {
    cidr_block   = "10.0.0.0/16"
    display_name = "app_vcn"
  },
  "bastion" = {
    cidr_block   = "172.168.0.0/24"
    display_name = "bastion_vcn"
  }
}

igws = {
  "app"     = {},
  "bastion" = {}
}

vcn_rts = {
  "app"     = {},
  "bastion" = {}
}

app_subnets = {
  "app" = {
    display_name               = "app_subnet"
    cidr_block                 = "10.0.0.0/24"
    prohibit_public_ip_on_vnic = false
    prohibit_internet_ingress  = false
  }
}
bastion_subnets = {
  "bastion" = {
    display_name               = "public_bastion_subnet"
    cidr_block                 = "172.168.0.0/29"
    prohibit_public_ip_on_vnic = false
    prohibit_internet_ingress  = false
  }
}

lb_subnets = {
  "lb" = {
    display_name               = "public_lb_subnet"
    cidr_block                 = "10.0.1.0/24"
    prohibit_public_ip_on_vnic = false
    prohibit_internet_ingress  = false
  }
}

ssh_keys = {
  "app" = {
    algorithm = "RSA"
  },
  "bastion" = {
    algorithm = "RSA"
  }
}


vms = {
  "app" = {
    is_management_disabled = false
    is_monitoring_disabled = false
    logs_monitoring = {
      desired_state = "ENABLED"
      name          = "Custom Logs Monitoring"
    },
    instance_monitoring = {
      desired_state = "ENABLED"
      name          = "Compute Instance Monitoring"
    },
    bastion = {
      desired_state = "ENABLED"
      name          = "Bastion"
    }
    recovery_action                     = "RESTORE_INSTANCE"
    assign_private_dns_record           = true
    assign_public_ip                    = true
    is_pv_encryption_in_transit_enabled = true
    inline = [
      "sudo apt-get update",
      "echo '****************** Installing Docker ******************'",
      "sudo apt-get install -y apt-transport-https ca-certificates curl gnupg software-properties-common lsb-release",
      "curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --batch --yes --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg",
      "echo 'deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu bionic stable' | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null",
      "sudo apt-get update",
      "sudo apt-get install -y docker-ce docker-ce-cli containerd.io",
      "echo '******************Testing Docker******************'",
      "sudo docker version",
      "sudo systemctl status docker --no-pager",
      "echo '****************** Installing Apache ******************'",
      "sudo apt install -y apache2",
      "sudo systemctl start apache2",
      "sudo systemctl status apache2 --no-pager",
      "*************** Pulling Image and Running Container **************",
      "docker pull erniepy/dwgettingstarted_web",
      "sudo chown -R ubuntu /var/run/docker.sock",
      "docker run -p 8080:8080 -d erniepy/dwgettingstarted_web",
      "echo '****************** Adding index.html ******************'",
      "sudo chown -R ubuntu /var/www/html/",
      "echo 'AppServer' >/var/www/html/index.html",
    ],
    connection = {
      type = "ssh",
      user = "ubuntu"
    }
  }
  "grafana" = {
    is_management_disabled = false
    is_monitoring_disabled = false
    recovery_action                     = "RESTORE_INSTANCE"
    assign_private_dns_record           = true
    assign_public_ip                    = true
    is_pv_encryption_in_transit_enabled = true
    inline = [
      "sudo apt update",
      "sudo apt-get install -y apt-transport-https",
      "sudo apt-get install -y software-properties-common wget",
      "wget -q -O - https://packages.grafana.com/gpg.key | sudo apt-key add -",
      "echo 'deb https://packages.grafana.com/oss/deb stable main' | sudo tee -a /etc/apt/sources.list.d/grafana.list",
      "sudo apt-get update",
      "sudo apt-get install -y grafana",
      "sudo systemctl daemon-reload",
      "sudo grafana-cli plugins install oci-datasource",
      "sudo systemctl start grafana-server",
      "sudo systemctl status grafana-server --no-pager",
      "sudo systemctl enable grafana-server.service",
      "echo '****************** Installing SSH ******************'",
      "sudo apt install -y openssh-server",
      "sudo systemctl status ssh --no-pager",
    ],
    connection = {
      type = "ssh",
      user = "ubuntu"
    }
  }
}

bastions = {
  "bastion" = {
    is_management_disabled = false
    is_monitoring_disabled = false
    logs_monitoring = {
      desired_state = "ENABLED"
      name          = "Custom Logs Monitoring"
    },
    instance_monitoring = {
      desired_state = "ENABLED"
      name          = "Compute Instance Monitoring"
    },
    bastion = {
      desired_state = "ENABLED"
      name          = "Bastion"
    }
    recovery_action                     = "RESTORE_INSTANCE"
    assign_private_dns_record           = false
    assign_public_ip                    = true
    is_pv_encryption_in_transit_enabled = true
    inline = [
      "sudo apt-get update",
      "echo '****************** Installing SSH ******************'",
      "sudo apt install -y openssh-server",
      "sudo apt install -y openssh-client",
      "sudo systemctl status ssh --no-pager",
      "eval `ssh-agent -s`"
    ],
    connection = {
      type = "ssh",
      user = "ubuntu"
    }
  }
}
