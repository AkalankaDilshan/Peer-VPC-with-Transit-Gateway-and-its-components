resource "aws_security_group" "server_sg" {
  name        = var.security_group_name
  description = "omly allow SSH"
  vpc_id      = var.vpc_id
  tags = {
    Name = var.security_group_name
  }
}

resource "aws_security_group_rule" "allow_ssh" {
  type                     = "ingress"
  description              = "allow SSH ingress"
  from_port                = 22
  to_port                  = 22
  protocol                 = "tcp"
  source_security_group_id = var.source_sg_id
  security_group_id        = aws_security_group.server_sg.id
}

resource "aws_security_group_rule" "public_allow_all_outbound" {
  type              = "egress"
  description       = "Allow ALl outbound traffic"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.server_sg.id
}
