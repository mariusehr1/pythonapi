
variable "public_key_path" {
  description = <<DESCRIPTION
Enter the PATH of your public SSH key (e.g. '/home/marius/.ssh/id_rsa_aws.pub')
DESCRIPTION
}
variable "ssh_key_private" {
  description = <<DESCRIPTION
Enter the path of your private SSH key (it will only be used to run the playbook from your local machine (e.g. '/home/marius/.ssh/id_rsa_aws')
DESCRIPTION
}
variable "key_name" {
  description = "Keyname (has to match the username)"
  default = "ubuntu"
}
variable "aws_region" {
  description = "AWS region to launch servers."
  default     = "eu-west-3"
}

# Ubuntu 19.04 
variable "aws_amis" {
  default = {
    eu-west-3 = "ami-0af99c435917a4a7a"
  }
}