resource "aws_s3_bucket" "example" {
  bucket = var.bucket_name
}

variable "bucket_name" {
  type = string
}

output "bucket_name" {
  value = aws_s3_bucket.example.bucket
}