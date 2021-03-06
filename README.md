Local Machine needs:
- Terraform requirements:
  - Terraform v1.0.6
  - on darwin_amd64
  - + provider registry.terraform.io/hashicorp/null v3.1.0
  - + provider registry.terraform.io/hashicorp/oci v4.43.0
  - + provider registry.terraform.io/hashicorp/tls v3.1.0
- Oracle Cloud Infrastructure 3.0.4 with Root permissions
- SSH Generated in RSA format (if local SSH keys are the prefered method of authentication, another method was left commented for use)

**Terraform**
```
.
├── Modules
│   ├── Compute
│   │   ├── main.tf
│   │   ├── output.tf
│   │   └── variables.tf
│   ├── Identity
│   │   ├── main.tf
│   │   ├── output.tf
│   │   └── variables.tf
│   ├── LoadBalancer
│   │   ├── main.tf
│   │   ├── output.tf
│   │   └── variables.tf
│   └── Networking
│       ├── main.tf
│       ├── output.tf
│       └── variables.tf
├── main.tf
├── terraform.tfstate
├── terraform.tfstate.1631726711.backup
├── terraform.tfstate.backup
├── tfvars
│   └── useast.auto.tfvars
├── ubuntuAppProvisioner.sh
├── ubuntuBastionProvisioner.sh
├── ubuntuGrafanaProvisioner.sh
└── variables.tf
```

- A modularized approach was used. Feeding the tfvars, feeds the root variables.tf, which feeds the main.tf(our template), which feeds the child modules where specific module components(logical grouping of resources) is found.
- Use this as an example to run the tfvars ```terraform apply -var-file="tfvars/useast.auto.tfvars"```

**Dropwizard App**
The app will add resource path ```@/fibonacci-members``` in port 8080 of the machine running the app. (Docker port binding of 8080:8080 was introduced in the scripts that provision the VMs).

**VM Provisioning**
VMs version: Ubuntu18.04 bionical
Provisioning methods:
- We can either: 
    - [STABLE] Deploy using ```remote-exec``` from within Terraform -> (Uncomment user_data block)
    - [NOT-STABLE] Deploy using local .sh scripts that will be invoked by metadata in ```module.Compute``` inside ```user_data``` -> (Uncomment user_data block)

**SSH Note**
- We heve the possibility to use local or Terraform managed SSH Keys. If we want to manage keys in TF simply uncomment the TLS block at the top of Compute module.
- Managing through TF the SSH keys makes it difficult to retrieve for further troubleshooting (extract from state and convert).
- If keys are to be managed locally follow these steps to create your own ssh keys into terraform

**Bastion**
Our implementation suggestes that bastion is accessible only from our ip and is the only way to SSH into our AppServer.
Update the variable ```source=``` in Terraform with path ```module.Networking.oci_core_security_list.bastion_sec_lists``` with ```[bastion]``` index.
- SSH to Bastion and AppServer from Bastion:
  - ssh-add -K /Users/ernie_py/.ssh/id_rsa (your private key)
  - check it was stored in auth by doing ssh-add -L
  - ssh into bastion by -A: ssh -A ubuntu@bastionPublicIp (ssh-add -L to make sure the private ky was passed along)
  - to ssh into app_server do ssh ubuntu@appServerPublicIp

*Docker Image*
Docker Image: erniepy/dwgettingstarted_web
- We are using a ```maven``` base image which only requires our pom file to run. Might be better than installing jdk in VM to run.

**Grafana**
The script installed grafana but it's unsigned.
We need to navigate to ```etc/grafana/``` and modify ```grafana.ini```.
[Need Root permissions] Steps:
- ```sudo vim grafan.ini```
- /.allow_loading
- set ```allow_loading_unsigned_plugins``` to ```true```
-Install oci resource ```sudo grafana-cli plugins install oci-datasource```
- Restart service with init.d ```sudo service grafana-server restart```
- Alternatively restart server ```sudo systemctl restart grafana-server```
- ```sudo systemctl status grafana-server``` to check is running
- If not working install these instead:
  - sudo grafana-cli plugins install oci-logs-datasource
  - sudo grafana-cli plugins install oci-metrics-datasource
  - sudo service grafana-server restart

***Manual Step Post Deployment***
Security list were created for each Subnet, but they need to be manually attached to the VMs post-deployment in order to remove the one that is auto-generated by OCI and will need to remove and de-allocate manually if TF destroy is run.


