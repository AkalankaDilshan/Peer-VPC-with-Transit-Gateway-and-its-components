resource "random_string" "bucket_suffix" {
  length  = 6
  special = false
  upper   = false
  numeric = false
}

resource "aws_s3_bucket" "flow_logs_bucket" {
  bucket        = "${var.bucket_prefix}-${random_string.bucket_suffix.result}"
  force_destroy = true

  tags = {
    Name        = var.bucket_prefix
    Environment = var.environment
  }
}

resource "aws_s3_bucket_policy" "flow_logs_bucket_policy" {
  bucket = aws_s3_bucket.flow_logs_bucket.bucket

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect    = "Allow"
        Principal = { Service = "delivery.logs.amazonaws.com" }
        Action    = "s3:PutObject"
        Resource  = "arn:aws:s3:::${aws_s3_bucket.flow_logs_bucket.bucket}/*"
      }
    ]
  })
}

# resource "aws_s3_bucket_public_access_block" "bucket_access" {
#   bucket = aws_s3_bucket.flow_logs_bucket.id

#   block_public_acls       = false
#   block_public_policy     = false
#   ignore_public_acls      = false
#   restrict_public_buckets = false
# }
