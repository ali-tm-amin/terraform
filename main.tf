provider "aws" {
    region = "eu-west-1"
    # This will allow terraform to create services on eu-west-1
 # Lets start with launching ec2 instance using terraform script
}
resource "aws_instance" "app_instance" {
  # Add the ami id for 18.06LTS
  ami = var.app_ami_id
  instance_type = var.type_of_machine
  # Enable IP as it's our app instance
  associate_public_ip_address = true
  # add tags for Name
  tags = {
    Name = var.name
  }
  key_name = var.aws_key_name # ensure that we have this key in .ssh folder
}

# resource "aws_vpc" "eng99_terraform_vpc" {
#   cidr_block = var.cidr_block 
#   # "10.0.0.0/16"
#   instance_tenancy = "default"
  
#   tags = {
#     Name = var.vpc_name
#   }
# } 
# apply DRY  do not repeat yourself

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"
  
  name = var.vpc_name
  cidr = var.vpc_cidr

  azs             = ["eu-west-1a", "eu-west-1b", "eu-west-1c"]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]

  enable_nat_gateway = false
  enable_vpn_gateway = false

  tags = {
    Terraform = "true"
    Environment = "dev"
  }
}