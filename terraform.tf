terraform {
  cloud {

    organization = "ZeroCloud"
    workspaces {
      name = "Peer-VPC-with-Transit-Gateway-and-its-components"
    }
  }
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0"
    }
  }
}
