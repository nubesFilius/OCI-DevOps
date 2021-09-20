#!/bin/bash
"sudo apt-get update",
"echo '****************** Installing SSH ******************'"
"sudo apt install -y openssh-server"
"sudo apt install -y openssh-client"
"sudo systemctl status ssh --no-pager"