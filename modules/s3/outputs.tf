output "bucket_name" {
  value = aws_s3_bucket.flow_logs_bucket.bucket
}

output "bucket_arn" {
  value = aws_s3_bucket.flow_logs_bucket.arn
}
