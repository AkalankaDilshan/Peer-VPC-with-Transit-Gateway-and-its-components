data "aws_ami" "ubuntu" {
  owners      = ["amazon"]
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "state"
    values = ["available"]
  }
}

resource "aws_instance" "server_instance" {
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = var.instance_type
  subnet_id                   = var.subnet_id
  vpc_security_group_ids      = [var.ec2_security_group]
  associate_public_ip_address = var.is_allow_public_ip
  disable_api_termination     = false
  ebs_optimized               = false
  root_block_device {
    volume_type = var.ebs_volume_type
    volume_size = var.ebs_volume_size
    encrypted   = true
  }

  key_name = var.key_pair_name

  tags = {
    Name = var.instance_name
  }
}

//disable_api_termination = false setting is used in AWS EC2 instances to control whether the instance can be accidentally or intentionally terminated 
// through the AWS API, CLI, or Console

// disable_api_termination = false → Instance CAN be terminated (default behavior).
// disable_api_termination = true → Prevents termination unless explicitly disabled first.

// Set to true (protection ON)
// For critical servers (e.g., databases, production apps) that should not be deleted by mistake.

//Set to false (protection OFF)
// For temporary/test instances that should be easily removable.
