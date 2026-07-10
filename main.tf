resource "aws_s3_bucket" "example" {
  bucket = var.bucket_name
 tags = {
     app = "frontend"
}
}

variable "bucket_name" {
  type = string
  default = "new-bucket-121213"
}

output "bucket_name" {
  value = aws_s3_bucket.example.bucket
}
