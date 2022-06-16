resource "random_string" "random" {
  length      = 3
  numeric     = true
  min_numeric = 3
}

locals {
  random_string    = "${module.this.id}-lb-logs-${random_string.random.result}"
  no_random_string = "${module.this.id}-lb-logs"
}

resource "aws_s3_bucket" "alb_logs" {
  bucket        = var.random_string ? local.random_string : local.no_random_string
  force_destroy = var.log_bucket_force_destroy

  tags = merge(
    module.this.tags,
    {
      Name = var.random_string ? local.random_string : local.no_random_string
    },
  )
}

resource "aws_s3_bucket_acl" "bucket-acl" {
  bucket = aws_s3_bucket.alb_logs.id
  acl    = "log-delivery-write"
}

resource "aws_s3_bucket_server_side_encryption_configuration" "bucket-encryption" {
  bucket = aws_s3_bucket.alb_logs.id
  rule {
    bucket_key_enabled = false

    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_versioning" "bucket-versioning" {
  bucket = aws_s3_bucket.alb_logs.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_public_access_block" "block" {
  bucket                  = aws_s3_bucket.alb_logs.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
