provider "aws" {
  region = "${var.aws_region}"
}
# VPC 
resource "aws_vpc" "default" {
  cidr_block = "10.0.0.0/16"
}
# Internet gateway
resource "aws_internet_gateway" "default" {
  vpc_id = "${aws_vpc.default.id}"
}
# Internet access
resource "aws_route" "internet_access" {
  route_table_id         = "${aws_vpc.default.main_route_table_id}"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = "${aws_internet_gateway.default.id}"
}

# Subnet
resource "aws_subnet" "default" {
  vpc_id                  = "${aws_vpc.default.id}"
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
}
# Security group
resource "aws_security_group" "elb" {
  vpc_id      = "${aws_vpc.default.id}"

  # HTTP access from anywhere
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # outbound internet access
  egress {
    from_port   = 0
    to_port     = 0
    # Wildcard allowing any egress protocol
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
# Security Group
# Our default security group to access
# the instances over SSH and HTTP
resource "aws_security_group" "default" {
  name        = "terraform_example"
  vpc_id      = "${aws_vpc.default.id}"

  # SSH access from anywhere
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # HTTP access from the VPC
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]
  }

  # outbound internet access
  egress {
    from_port   = 0
    to_port     = 0
    # Wildcard allowing any egress protocol
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
# Loadbalancer 
resource "aws_elb" "web" {
  name = "elastic-lb"

  subnets         = ["${aws_subnet.default.id}"]
  security_groups = ["${aws_security_group.elb.id}"]
  # This wildcard includes the amount of instances we asked before into the loadbalancer
  instances       = "${aws_instance.web.*.id}"

  listener {
    instance_port     = 80
    instance_protocol = "http"
    lb_port           = 80
    lb_protocol       = "http"
  }
}
# SSH keypair
resource "aws_key_pair" "auth" {
  key_name   = "${var.key_name}"
  public_key = "${file(var.public_key_path)}"
}
# Our instances 
resource "aws_instance" "web" {
  count = 2
  instance_type = "t2.micro"
  ami = "${lookup(var.aws_amis, var.aws_region)}"
  key_name = "${aws_key_pair.auth.id}"
  vpc_security_group_ids = ["${aws_security_group.default.id}"]
  subnet_id = "${aws_subnet.default.id}"
  provisioner "remote-exec" {
    # Those will be ran right after the VM's spin-up, not like the local-exec below.
    # As the ansible playbook also does this "apt update,upgrade", this could be a plain "sleep 10"
    # Although, it is mendatory as the local-exec would fail if this inline is not present
    inline = ["sudo apt update -y && sudo apt upgrade -y"]
    #Connection info
    connection {
      type        = "ssh"
      user        = "ubuntu"
      host = "${self.public_ip}"
      private_key = "${file(var.ssh_key_private)}"
    }
  }
  #Runs a local playbook 
  provisioner "local-exec" {
    command = "cd ../ansible && ansible-playbook -i '${self.public_ip},' --private-key ${var.ssh_key_private} docker_deploy.yml" 
  }
}
