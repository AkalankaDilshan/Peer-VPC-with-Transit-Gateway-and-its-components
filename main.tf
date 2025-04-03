provider "aws" {
  region = var.region
}


module "vpc" {
  source               = "./modules/vpc"
  vpc_name             = "VPC-A"
  cidr_block           = "192.173.0.0/16"
  aws_region           = "eu-north-1" // default region 
  availability_zones   = "eu-north-1a"
  public_subnet_cidr   = "192.173.1.0/24"
  private_subnet_cidrs = "192.173.3.0/24"
}
