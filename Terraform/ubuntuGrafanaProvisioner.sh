#!/bin/bash
"sudo apt update"
"sudo apt-get install -y apt-transport-https"
"sudo apt-get install -y software-properties-common wget"
"wget -q -O - https://packages.grafana.com/gpg.key | sudo apt-key add -"
"echo 'deb https://packages.grafana.com/oss/deb stable main' | sudo tee -a /etc/apt/sources.list.d/grafana.list"
"sudo apt-get update"
"sudo apt-get install -y grafana"
"sudo systemctl daemon-reload"
"sudo grafana-cli plugins install oci-datasource"
"sudo systemctl start grafana-server"
"sudo systemctl status grafana-server --no-pager"
"sudo systemctl enable grafana-server.service"

# For testing only
# sudo apt install -y stress