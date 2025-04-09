# iam role for vpc-flow logs 
resource "aws_iam_role" "vpc_flow_log_role" {
  name = var.role_name

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "vpc-flow-logs.amazonaws.com"
        }
      }
    ]
  })
}

# create Iam role police data 
data "aws_iam_policy_document" "polices" {
  version = "2012-10-17"

  # allow log group 
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
  name        = "vpc_flow_log_policy"
  description = "Policy for vpc flow log role"
  policy      = data.aws_iam_policy_document.polices.json
}

# Attach policy to Iam role 
resource "aws_iam_role_policy_attachment" "attach_policy" {
  role       = aws_iam_role.vpc_flow_log_role.name
  policy_arn = aws_iam_policy.custom_policy.arn
}
