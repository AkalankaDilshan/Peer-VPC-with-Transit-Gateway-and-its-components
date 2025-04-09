terraform {
  cloud {

    organization = "ZeroCloud"
    workspaces {
      name = "Peer-VPC-with-Transit-Gateway-and-its-components"
    }
  }
}
