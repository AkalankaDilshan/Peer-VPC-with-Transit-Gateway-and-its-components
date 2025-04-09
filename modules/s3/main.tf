resource "random_string" "bucket_suffix" {
  length  = 6
  special = false
  upper   = false
  numeric = false
}

resource "aws_s3_bucket" "flow_logs_bucket" {
  bucket        = "${var.bucket_prefix}_${random_string.bucket_suffix.result}"
  force_destroy = true

  tags = {
    Name        = "${var.bucket_prefix}"
    Environment = var.environment
  }
}

# resource "aws_s3_bucket_public_access_block" "bucket_access" {
#   bucket = aws_s3_bucket.flow_logs_bucket.id

#   block_public_acls       = false
#   block_public_policy     = false
#   ignore_public_acls      = false
#   restrict_public_buckets = false
# }
