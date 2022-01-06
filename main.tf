provider "aws" {
    region = "eu-west-1"
    # This will allow terraform to create services on eu-west-1
 # Lets start with launching ec2 instance using terraform script
}
resource "aws_instance" "app_instance" {
  # Add the ami id for 18.06LTS
  ami = "ami-082fbd334da28e5ec"
  instance_type = "t2.micro"
  # Enable IP as it's our app instance
  associate_public_ip_address = true
  # add tags for Name
  tags = {
    Name = "eng99_ali_terrafom_app"
  }
  key_name = "eng99" # ensure that we have this key in .ssh folder
}
resource "aws_vpc" "eng99_terraform_vpc" {
  cidr_block       = var.cidr_block 
  #"10.0.0.0/16"
  instance_tenancy = "default"
  
  tags = {
    Name = var.vpc_name
  }
} 
# apply DRY  do not repeat yourself