# Dhewm3 server launcher for AWS

This tool will allow you to easily host a Dhewm3 dedicated server using Terraform and Ansible. 

This tool was tested in a Debian 12 machine, but it should work in any OS that supports ansible and terraform.

## Requirements

* [Ansible](https://docs.ansible.com/ansible/latest/installation_guide/installation_distros.html)
* [Terraform](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli)
* [Amazon AWS Account](https://aws.amazon.com/resources/create-account/)
* [Configure AWS Console](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-quickstart.html)
* Doom 3 base pk4 files
* [LibreCoop 1.5 for linux](https://www.moddb.com/mods/librecoop-dhewm3-coop/downloads/librecoop-alpha-15-linux-64bit)

## How to use

1. Clone this repository in a folder.
2. Inside the base/ folder put the .pk4 files inside your Doom 3 game folder.
3. In case you want to use Librecoop, put Librecoop_alpha_1.5_linux64.zip file where this project is located.
4. run **terraform init**
5. run **terraform apply**
6. Enjoy your Dhewm3 Server.
