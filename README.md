# terraform

#### IaC has two parts:

**Configuartion Mangement:**

They help configure and test machines to a specific state.
Systems - Puppet, Chef and ansible

**Orchestration:**

These tools focus on networking and architecture rather than the configuration of individual machines.
Terraform, Ansible

### What is Terraform
- Terraform is an open-source infrastructure as code software tool.

- It is a tool for building, changing and versioning infrastructure safely and efficiently.

- Terraform enables developers to use a high-level configuration language called HCL (HashiCorp Configuration Language) to describe the desired “end-state”

- Terraform files are created with a .tf extention

- Terraform allows for rapid create of instances using AMIs

### Why Terraform

There are a few key reasons developers choose to use Terraform over other Infrastructure as Code tools:

- **Open source:** Terraform is backed by large communities of contributors who build plugins to the platform.

- **Platform agnostic:** Meaning you can use it with any cloud services provider. Most other IaC tools are designed to work with single cloud provider.

- **Immutable infrastructure:** Terraform provisions immutable infrastructure, which means that with each change to the environment, the current configuration is replaced with a new one that accounts for the change, and the infrastructure is reprovisioned. Even better, previous configurations can be retained as versions to enable rollbacks if necessary or desired.

## Installations

On mac

    brew tap hashicorp/tap
    brew install hashicorp/tap/terraform
On linux

    curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add -
    sudo apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main"
    sudo apt-get update && sudo apt-get install terraform

**Step 1:** 
- Create env variable

    sudo echo "export AWS_ACCESS_KEY_ID=<Your access key>" >> ~/.bashrc
    sudo echo "export AWS_SECRET_ACCESS_KEY=<Your secret key>" >> ~/.bashrc
    source ~/.bashrc

- from the terminal run `aws configure` it will prompt for AWS_ACCESS_KEY_ID and AWS_SECRET_KEY
![](/images/aws_config.png)

 
**Create main.tf folder**

**Create variable.tf folder**

**Run terraform commands** 
- terraform init
- terraform plan
- terraform apply
- terraform destroy

**Step 2:** 
- Set provider

provider "aws" {
    region = var.region
    # This will allow terraform to create services on eu-west-1
    # Lets start with launching ec2 instance using terraform script
}

- Initialize terraform: `terraform init`

**Step 3:** 
- Launch EC2 instance with Resources
- web_instance

        resource "aws_instance" "app_instance" {
        # Add the ami id for 18.06LTS
        ami = var.app_ami_id
        instance_type = var.type_of_machine
        vpc_security_group_ids = ["sg-0840085c222a117d2"] # add this id after terraform plan
        subnet_id              = "subnet-0a9f2eb7a31d6e2cd" # add this id after terraform plan
        # Enable IP as it's our app instance
        associate_public_ip_address = true
        
        # add tags for Name
        tags = {
            Name = var.app_instance
        }
        key_name = var.aws_key_name # ensure that we have this key in .ssh folder
        }

- db_Instcance  

        resource "aws_instance" "db_instance" {
        # Add the ami id for 18.06LTS
        ami = var.db_ami_id
        instance_type = var.type_of_machine
        #subnet_id = var.private_subnet
        vpc_security_group_ids = ["sg-0840085c222a117d2"] # add this id after terraform plan
        subnet_id              = "subnet-02613dd257ab4f308" # add this id after terraform plan
        # Enable IP as it's our app instance
        associate_public_ip_address = true
        # add tags for Name
        tags = {
            Name = var.db_instance
            }
        key_name = var.aws_key_name # ensure that we have this key in .ssh folder
        }

- Creating VPC

        resource "aws_vpc" "eng99_ali_terraform_VPC" {
        cidr_block = var.cidr_block
        #instance_tenancy = "default"
        tags = {
            Name = "eng99_ali_terraform_VPC"
        }
        }

- Creating public subnet

        resource "aws_subnet" "eng99_ali_terraform_public_SN" {
        vpc_id     = aws_vpc.eng99_ali_terraform_VPC.id
        cidr_block = "10.0.1.0/24"
        map_public_ip_on_launch = true
        availability_zone = "eu-west-1a"

        tags = {
            Name = "eng99_ali_terraform_public_SN"
        }
        }

- Creating private subnet

        resource "aws_subnet" "eng99_ali_terraform_private_SN" {
        vpc_id     = aws_vpc.eng99_ali_terraform_VPC.id
        cidr_block = "10.0.2.0/24"
        map_public_ip_on_launch = false
        availability_zone = "eu-west-1a"

        tags = {
            Name = "eng99_ali_terraform_private_SN"
        }
        }

- Internet gateway

        resource "aws_internet_gateway" "eng99_ali_terraform_igw" {
        vpc_id = aws_vpc.eng99_ali_terraform_VPC.id

        tags = {
            Name = "eng99_ali_terraform_igw"
        }
        }

- Routing table

        resource "aws_route_table" "eng99_ali_terraform_rt" {
        vpc_id = aws_vpc.eng99_ali_terraform_VPC.id

        route  {
            cidr_block = "0.0.0.0/0"
            gateway_id = aws_internet_gateway.eng99_ali_terraform_igw.id
            }

        tags = {
            Name = "eng99_ali_terraform_rt"
        }
        }


- Their associations

        resource "aws_route_table_association" "eng99_ali_terraform_subnet_associate" {
        route_table_id = aws_route_table.eng99_ali_terraform_rt.id
        subnet_id = aws_subnet.eng99_ali_terraform_public_SN.id
        }

- Creating Security groups

            resource "aws_security_group" "allow_tls" {
            name        = "eng99_ali_terraform_sg"
            description = "Allow TLS inbound traffic"
            vpc_id = var.vpc_id
            
            ingress {
                description      = "access to the app"
                from_port        = "80"
                to_port          = "80"
                protocol         = "tcp"
                cidr_blocks      = ["0.0.0.0/0"]
                
            }
            # ssh access
            ingress {
                description      = "ssh access"
                from_port        = "22"
                to_port          = "22"
                protocol         = "tcp"
                cidr_blocks      = ["0.0.0.0/0"]
            
            }
            # Allow port 3000 from anywhere
            ingress {
                from_port        = "3000"
                to_port          = "3000"
                protocol         = "tcp"
                cidr_blocks      = ["0.0.0.0/0"]
                
            }
            ingress {
                description      = "ENTER THROUGH ANYWHERE VERY UNSECURE!!!!!"
                from_port        = 0
                to_port          = 0
                protocol         = "-1"
                cidr_blocks      = ["0.0.0.0/0"]
                
            }

            # Outbound rules
            
            egress {
                from_port        = 0
                to_port          = 0
                protocol         = "-1" # Allow all
                cidr_blocks      = ["0.0.0.0/0"]
            }

            tags = {
                Name = "eng99_ali_terraform_sg"
            }
            }  


