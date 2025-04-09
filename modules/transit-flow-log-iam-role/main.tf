resource "aws_iam_role" "transit_flowlog_role" {
  name = var.role_name

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}

data "aws_iam_policy_document" "polices" {
  version = "2012-10-17"
  statement {
    effect = "Allow"
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
      "logs:DescribeLogGroups",
      "logs:DescribeLogStreams"
    ]
    resources = ["*"]
  }
  statement {
    effect = "Allow"
    actions = [
      "s3:*"
    ]
    resources = ["*"]
  }
}

resource "aws_iam_policy" "custom_policy" {
  name        = "transit_flow_log_policy"
  description = "policy for Amazon transit flow log"
  policy      = data.aws_iam_policy_document.polices.json
}

#Attach policy to iam role 
resource "aws_iam_role_policy_attachment" "attach_policy" {
  role       = aws_iam_role.transit_flowlog_role.name
  policy_arn = aws_iam_policy.custom_policy.arn
}
