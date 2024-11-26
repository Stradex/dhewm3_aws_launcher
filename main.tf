provider "aws" {
  region = "us-west-1"
}

resource "tls_private_key" "tf_ec2_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "local_file" "tf_ec2_key" {
  content  = tls_private_key.tf_ec2_key.private_key_pem
  filename = "${path.module}/tf_ec2_key.pem"
}

resource "aws_key_pair" "tf_ec2_key" {
  key_name   = "tf_ec2_key"
  public_key = tls_private_key.tf_ec2_key.public_key_openssh
}

resource "aws_security_group" "ssh_access" {
  name        = "ssh-access"
  description = "Allow SSH inbound traffic"
}

resource "aws_vpc_security_group_ingress_rule" "ssh" {
  security_group_id = aws_security_group.ssh_access.id
  ip_protocol          = "tcp"
  from_port         = 22
  to_port           = 22
  cidr_ipv4	    = "0.0.0.0/0"
}

resource "aws_vpc_security_group_ingress_rule" "dhewm_master_tcp" {
  security_group_id = aws_security_group.ssh_access.id
  ip_protocol       = "tcp"
  from_port         = 27650
  to_port           = 27650
  cidr_ipv4	        = "0.0.0.0/0"
}

resource "aws_vpc_security_group_ingress_rule" "dhewm_master_udp" {
  security_group_id = aws_security_group.ssh_access.id
  ip_protocol       = "udp"
  from_port         = 27650
  to_port           = 27650
  cidr_ipv4	        = "0.0.0.0/0"
}

resource "aws_vpc_security_group_ingress_rule" "dhewm_tcp" {
  security_group_id = aws_security_group.ssh_access.id
  ip_protocol       = "tcp"
  from_port         = 27666
  to_port           = 27666
  cidr_ipv4	        = "0.0.0.0/0"
}

resource "aws_vpc_security_group_ingress_rule" "dhewm_udp" {
  security_group_id = aws_security_group.ssh_access.id
  ip_protocol       = "udp"
  from_port         = 27666
  to_port           = 27666
  cidr_ipv4	        = "0.0.0.0/0"
}

resource "aws_vpc_security_group_egress_rule" "allow_all" {
  security_group_id = aws_security_group.ssh_access.id
  ip_protocol          = "-1"
  from_port         = 0
  to_port           = 0
  cidr_ipv4	    = "0.0.0.0/0"
}

resource "aws_instance" "dhewm3_vps" {
  ami           = "ami-0dc89371e1a59e65f"
  instance_type = "t2.micro"
  vpc_security_group_ids = [aws_security_group.ssh_access.id]
  key_name      = aws_key_pair.tf_ec2_key.key_name
  associate_public_ip_address = true
  tags = {
    Name = "dhewm3_ec2"
  }
}

resource "local_file" "ansible_hosts" {
  content = "[dhewm]\n${aws_instance.dhewm3_vps.public_ip} ansible_ssh_private_key_file=./tf_ec2_key.pem ansible_ssh_user=admin"
  filename = "${path.module}/aws_hosts.ini"
}

resource "null_resource" "key_permissions" {
  depends_on = [aws_key_pair.tf_ec2_key]
  provisioner "local-exec" {
    interpreter = ["/bin/bash", "-c"]
    working_dir = "${path.module}"
    command = "chmod 600 ./tf_ec2_key.pem"
  }
}

resource "null_resource" "wait" {
  depends_on = [null_resource.key_permissions, aws_instance.dhewm3_vps, local_file.ansible_hosts]
  provisioner "local-exec" {
    command = "sleep 10"  # Sleep for 10 seconds
  }
}

resource "null_resource" "run_ansible" {
  depends_on = [null_resource.wait]
  provisioner "local-exec" {
    interpreter = ["/bin/bash", "-c"]
    working_dir = "${path.module}"
    command = "ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -i ./aws_hosts.ini playbook.yaml"
  }
}
