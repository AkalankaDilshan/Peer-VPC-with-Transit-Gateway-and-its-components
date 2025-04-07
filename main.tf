provider "aws" {
  region = "eu-north-1"
}
module "vpc_A" {
  source               = "./modules/vpc"
  vpc_name             = "VPC-A"
  cidr_block           = "192.173.0.0/16"
  availability_zones   = "eu-north-1a"
  public_subnet_cidr   = "192.173.1.0/24"
  private_subnet_cidrs = "192.173.3.0/24"
}

module "vpc_B" {
  source               = "./modules/vpc"
  vpc_name             = "VPC-B"
  cidr_block           = "172.16.0.0/16"
  availability_zones   = "eu-north-1b"
  public_subnet_cidr   = "172.16.1.0/24"
  private_subnet_cidrs = "172.16.3.0/24"
}

# module "transit_gateway" {
#   source              = "./modules/transit-gateway"
#   vpc_a_id            = module.vpc_A.vpc_id
#   vpc_b_id            = module.vpc_B.vpc_id
#   vpc_a_cidr          = module.vpc_A.vpc_cidr
#   vpc_b_cidr          = module.vpc_B.vpc_cidr
#   vpc_a_subnet_ids    = [module.vpc_A.public_subnet_id]
#   vpc_b_subnet_ids    = [module.vpc_B.private_subnet_id]
#   vpc_a_public_rt_id  = module.vpc_A.public_rt_id
#   vpc_a_private_rt_id = module.vpc_A.private_rt_id
#   vpc_b_public_rt_id  = module.vpc_B.public_rt_id
#   vpc_b_private_rt_id = module.vpc_B.private_rt_id
#   depends_on          = [module.vpc_A, module.vpc_B]
# }
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
  key_pair_name      = "server-key"
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
  key_pair_name      = "server-key"
  depends_on         = [module.private_security_group, module.vpc_B]
}



