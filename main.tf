provider "aws" {
  region = "eu-north-1"
}

module "transit_gateway" {
  source       = "./modules/transit-gateway"
  gateway_name = "test-tgw"
}
module "vpc_A" {
  source               = "./modules/vpc"
  vpc_name             = "VPC-A"
  cidr_block           = "192.173.0.0/16"
  availability_zones   = ["eu-north-1a"]
  public_subnet_cidr   = ["192.173.1.0/24"]
  private_subnet_cidrs = ["192.173.3.0/24"]
  enable_NAT_gateway   = true
  transit_gateway_id   = module.transit_gateway.transit_gateway_id
  tgw_destination_cidr = ["172.16.0.0/16"]
  depends_on           = [module.transit_gateway]
}
module "vpc_B" {
  source               = "./modules/vpc"
  vpc_name             = "VPC-B"
  cidr_block           = "172.16.0.0/16"
  availability_zones   = ["eu-north-1a"]
  public_subnet_cidr   = ["172.16.1.0/24"]
  private_subnet_cidrs = ["172.16.3.0/24"]
  enable_NAT_gateway   = true
  transit_gateway_id   = module.transit_gateway.transit_gateway_id
  tgw_destination_cidr = ["192.173.0.0/16"]
  depends_on           = [module.transit_gateway]
}

module "public_security_group_vpc_a" {
  source              = "./modules/ec2-sg"
  security_group_name = "public_security_group_vpc_a"
  vpc_id              = module.vpc_A.vpc_id
  is_allow_http       = true
  is_allow_https      = true
}

module "public_security_group_vpc_b" {
  source              = "./modules/ec2-sg"
  security_group_name = "public_security_group_vpc_b"
  vpc_id              = module.vpc_B.vpc_id
  is_allow_http       = true
  is_allow_https      = true
}

# module "private_security_group" {
#   source              = "./modules/ec2-sg"
#   security_group_name = "private_security_group"
#   vpc_id              = module.vpc_B.vpc_id
#   is_allow_http       = false
#   is_allow_https      = false
# }

module "public_instance_vpc_a" {
  source             = "./modules/ec2"
  instance_name      = "public_instance_vpc_a"
  instance_type      = "t3.micro"
  subnet_id          = module.vpc_A.public_subnet_id[0]
  ec2_security_group = module.public_security_group_vpc_a.security_group_id
  is_allow_public_ip = true
  ebs_volume_type    = "gp2"
  ebs_volume_size    = 8
  key_pair_name      = "server-key"
  depends_on         = [module.public_security_group_vpc_a, module.vpc_A]
}

module "public_instance_vpc_b" {
  source             = "./modules/ec2"
  instance_name      = "public_instance_vpc_b"
  instance_type      = "t3.micro"
  subnet_id          = module.vpc_B.public_subnet_id[0]
  ec2_security_group = module.public_security_group_vpc_b.security_group_id
  is_allow_public_ip = true
  ebs_volume_type    = "gp2"
  ebs_volume_size    = 8
  key_pair_name      = "server-key"
  depends_on         = [module.public_security_group_vpc_b, module.vpc_B]
}

# VPC flow log section 
module "vpc_flowlog_s3_bucket" {
  source        = "./modules/s3"
  bucket_prefix = "vpc-flow-logs-bucket"
}

module "vpc_flowlog_cloudwatch_logs_group" {
  source         = "./modules/cloudWatch_logs"
  log_group_name = "vpc-flow-logs"
}

module "vpc_flow_log_iam_role" {
  source    = "./modules/vpc-flow-log-iam-role"
  role_name = "vpc-flow-log-role"
}

module "vpc_flow_log" {
  source                   = "./modules/vpc-flow-log"
  vpc_ids                  = [module.vpc_A.vpc_id, module.vpc_B.vpc_id]
  cloudwatch_log_group_arn = module.vpc_flowlog_cloudwatch_logs_group.cloudwatch_log_group_arn
  iam_role_arn             = module.vpc_flow_log_iam_role.vpc_iam_role_arn
  s3_bucket_arn            = module.vpc_flowlog_s3_bucket.bucket_arn
}

# Transit flow log section 
module "transit_flowlog_s3_bucket" {
  source        = "./modules/s3"
  bucket_prefix = "tgw_flow_logs_bucket"
}

module "transit_flowlog_cloudwatch_logs_group" {
  source         = "./modules/cloudWatch_logs"
  log_group_name = "tgw-flow-logs"
}

module "transit_flow_log_iam_role" {
  source    = "./modules/transit-flow-log-iam-role"
  role_name = "tgw-flow-log-role"
}

module "transit_flow_log" {
  source                   = "./modules/transit-flow-log"
  transit_gateway_id       = module.transit_gateway.transit_gateway_id
  cloudwatch_log_group_arn = module.transit_flowlog_cloudwatch_logs_group.cloudwatch_log_group_arn
  s3_bucket_arn            = module.vpc_flowlog_s3_bucket.bucket_arn
  iam_role_arn             = module.transit_flow_log_iam_role.vpc_iam_role_arn
}


# create sns 
module "sns" {
  source         = "./modules/sns"
  email_endpoint = "akalankadilshan98@gmail.com" #add your email here
}

#create cloudwatch metrics 
module "cloudwatch_metric" {
  source                     = "./modules/cloudWatch"
  vpc_flow_logs_name         = module.vpc_flowlog_cloudwatch_logs_group.cloudwatch_log_group_name
  sns_security_alerts_arn    = module.sns.sns_security_alerts_arn
  sns_performance_alerts_arn = module.sns.sns_performance_alerts_arn
}
