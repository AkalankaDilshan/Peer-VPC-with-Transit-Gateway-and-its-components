terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
  cloud {

    organization = "ZeroCloud"
    workspaces {
      name = "Peer-VPC-with-Transit-Gateway-and-its-components"
    }
  }
}
