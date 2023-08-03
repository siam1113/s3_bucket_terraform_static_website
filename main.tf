# Set up providers
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.10.0"
    }
  }
}

provider "aws" {
  region     = var.aws_region
  access_key = ""
  secret_key = ""
}


# Create S3 bucket
resource "aws_s3_bucket" "s3terraform2023" {
  bucket = var.aws_s3_bucket_name
}

# Set bucket ownership controls
resource "aws_s3_bucket_ownership_controls" "s3_bucket_terraform_2023" {
  bucket = aws_s3_bucket.s3terraform2023.id

  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

# Set public access block
resource "aws_s3_bucket_public_access_block" "s3_bucket_terraform_2023" {
  bucket = aws_s3_bucket.s3terraform2023.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

# Set bucket access-control-policy (acl)
resource "aws_s3_bucket_acl" "s3_bucket_terraform_2023" {
  depends_on = [
    aws_s3_bucket_ownership_controls.s3_bucket_terraform_2023,
    aws_s3_bucket_public_access_block.s3_bucket_terraform_2023,
  ]

  bucket = aws_s3_bucket.s3terraform2023.id
  acl    = "public-read"
}

# Upload the objects ( website files ) to the bucket ( index.and error page is must to upload for website congifuration)
resource "aws_s3_object" "index" {
  bucket       = aws_s3_bucket.s3terraform2023.id
  key          = "index.html"
  source       = "website/index.html"
  acl          = "public-read"
  content_type = "text/html"
}

resource "aws_s3_object" "error" {
  bucket       = aws_s3_bucket.s3terraform2023.id
  key          = "error.html"
  source       = "website/error.html"
  acl          = "public-read"
  content_type = "text/html"
}

# Website configuration
resource "aws_s3_bucket_website_configuration" "s3_bucket_terraform_2023" {
  bucket = aws_s3_bucket.s3terraform2023.id

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "error.html"
  }
  depends_on = [aws_s3_bucket_acl.s3_bucket_terraform_2023]
}
