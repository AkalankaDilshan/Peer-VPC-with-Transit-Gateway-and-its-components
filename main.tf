provider "aws" {
  region = "eu-west-1"
}

# provider "aws" {
#   alias = "eu-south-1"

#   region = "eu-south-1"
# }

module "vpc_A" {
  source = "./modules/vpc"
  # providers = {
  #   aws = aws.eu-west-1
  # }
  vpc_name   = "VPC-A"
  cidr_block = "192.173.0.0/16"
  # aws_region           = "eu-north-1" // default region 
  availability_zones   = "eu-west-1a"
  public_subnet_cidr   = "192.173.1.0/24"
  private_subnet_cidrs = "192.173.3.0/24"
}

module "vpc_B" {
  source = "./modules/vpc"
  # providers  = { aws = aws.region2 }
  vpc_name   = "VPC-B"
  cidr_block = "172.16.0.0/16"
  # aws_region           = "eu-west-1"
  availability_zones   = "eu-west-1b"
  public_subnet_cidr   = "172.16.1.0/24"
  private_subnet_cidrs = "172.16.3.0/24"
}

module "public_security_group" {
  source              = "./modules/ec2-sg"
  security_group_name = "public_security_group"
  vpc_id              = module.vpc_A.vpc_id
  is_allow_http       = true
  is_allow_https      = true
}

module "private_security_group" {
  source              = "./modules/ec2-sg"
  security_group_name = "private_security_group"
  vpc_id              = module.vpc_B.vpc_id
  is_allow_http       = false
  is_allow_https      = false
}

module "public_instance" {
  source             = "./modules/ec2"
  instance_name      = "public_instance"
  instance_type      = "t3.micro"
  subnet_id          = module.vpc_A.public_subnet_id
  ec2_security_group = module.public_security_group.security_group_id
  is_allow_public_ip = true
  ebs_volume_type    = "gp2"
  ebs_volume_size    = 8
  key_pair_name      = "moba-key"
  depends_on         = [module.public_security_group, module.vpc_A]
}

module "private_instance" {
  source             = "./modules/ec2"
  instance_name      = "private_instance"
  instance_type      = "t3.micro"
  subnet_id          = module.vpc_B.private_subnet_id
  ec2_security_group = module.private_security_group.security_group_id
  is_allow_public_ip = true
  ebs_volume_type    = "gp2"
  ebs_volume_size    = 8
  key_pair_name      = "moba-key"
  depends_on         = [module.private_security_group, module.vpc_B]
}
