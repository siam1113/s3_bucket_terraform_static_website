# Project steps

 1. [Create](https://aws.amazon.com/free/) an AWS Account
 2. [Install](<https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli>) **terraform** in your machine
 3. Create your project folder `mkdir <project_name>` and navigate to the project folder `cd <project_name>`
 4. Configure provider and run `terraform init`

    ```hcl
        terraform {
        required_providers {
          aws = {
            source  = "hashicorp/aws"
            version = "~> 5.10.0"
          }
        }
      }

      provider "aws" {
        region = "<region_name>"
        access_key = ""
        secret_key = ""
      }
    ```

 5. Create a S3 bucket by running `terraform apply`

    ```hcl
      resource "aws_s3_bucket" "<resource_name>" {
      bucket = "your_bucket_name"
      }
    ```

 6. Set bucket ownership controls
  
    ```hcl
      resource "aws_s3_bucket_ownership_controls" "<resource_name>" {
        bucket = aws_s3_bucket.your_bucket_name.id

        rule {
          object_ownership = "BucketOwnerPreferred"
        }
      }
    ```

 7. Set public access block and Set public access-control-policy (acl) to make the bucket public
  
    ```hcl
        resource "aws_s3_bucket_public_access_block" "<resource_name>" {

        bucket = aws_s3_bucket.your_bucket_name.id

        block_public_acls       = false
        block_public_policy     = false
        ignore_public_acls      = false
        restrict_public_buckets = false
       }
    ```  

    ```hcl
        resource "aws_s3_bucket_acl" "<resource_name>" {

        depends_on = [
          aws_s3_bucket_ownership_controls.<resource_name>,
          aws_s3_bucket_public_access_block.<resource_name>,
        ]

        bucket = aws_s3_bucket.your_bucket_name.id
        acl    = "public-read"
       }
    ```  

 8. Upload required index and error pages as S3 objects
  
    ```hcl
        resource "aws_s3_object" "<resource_name>" {
          bucket = "your_bucket_name"
          key    = "index.html"
          source = "path/to/your/file"
          acl    = "public-read"
          content_type = "text/html"
        }

        resource "aws_s3_object" "<resource_name>" {
          bucket = "your_bucket_name"
          key    = "error.html"
          source = "path/to/your/file"
          acl    = "public-read"
          content_type = "text/html"
        }
    ```

 9. Complete Website configuration
  
    ```hcl
        resource "aws_s3_bucket_website_configuration" "s3_bucket_terraform-2023" {

        bucket = aws_s3_bucket.your_bucket_name.id

        index_document {
          suffix = "index.html"
        }

        error_document {
          key = "error.html"
        }
        depends_on = [aws_s3_bucket_acl.<resource_name>]
      }
    ```

10. Run `terraform plan` to see the outcome and Run `terraform apply` to implement the plan
11. Now if you login to your AWS account and navigate `S3 Bucket > Buckets` you will see the newly created bucket there
12. Click on the bucket and Go to **Properties** and Scroll down to the bottom to **Static website hosting** section
13. You will see the website endpoint there and by navigating to that endpoint you can visit your website
