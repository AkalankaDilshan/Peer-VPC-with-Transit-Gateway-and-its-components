resource "aws_security_group" "ec2_sg" {
  name        = var.security_group_name
  description = "allow SSH,HTTP,HTTPS"
  vpc_id      = var.vpc_id
  tags = {
    Name = var.security_group_name
  }
}

resource "aws_security_group_rule" "allow_ssh" {
  type              = "ingress"
  description       = "allow SSH ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.ec2_sg.id
}

resource "aws_security_group_rule" "allow_HTTP" {
  type              = "ingress"
  description       = "allow HTTP ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.ec2_sg.id
}

resource "aws_security_group_rule" "allow_HTTPS" {
  type              = "ingress"
  description       = "allow HTTPS ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.ec2_sg.id
}

resource "aws_security_group_rule" "public_allow_all_outbound" {
  type              = "egress"
  description       = "Allow ALl outbound traffic"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.ec2_sg.id
}
