#
# MAINTAINER Vitaliy Natarov "vitaliy.natarov@yahoo.com"
#
terraform {
  required_version = "~> 0.13.5"
}

provider "aws" {
  region                  = "us-west-2"
  profile                 = "default"
  shared_credentials_file = pathexpand("~/.aws/credentials")
}

module "s3_private_bucket" {
  source      = "../../modules/s3"
  name        = "TEST"
  environment = "dev"

  # AWS S3 bucket
  enable_s3_bucket = true
  s3_bucket_name   = "natarov-test-bucket1"
  s3_bucket_acl    = "private"

  tags = map("Env", "stage", "Orchestration", "Terraform")
}


module "s3" {
  source      = "../../modules/s3"
  name        = "TEST"
  environment = "dev"

  # AWS S3 bucket
  enable_s3_bucket = true
  s3_bucket_name   = "natarov-test-bucket2"
  s3_bucket_acl    = "private"

  s3_bucket_grant = []
  s3_bucket_website = {
    index_document = "index.tml"
    error_document = "error.tml"
    routing_rules = jsonencode([{
      Condition : {
        KeyPrefixEquals : "docs/"
      },
      Redirect : {
        ReplaceKeyPrefixWith : "documents/"
      }
    }])

  }

  s3_bucket_cors_rule = [
    {
      allowed_headers = ["*"]
      allowed_methods = ["PUT", "POST"]
      allowed_origins = ["https://s3-website-test.hashicorp.com"]
      expose_headers  = ["ETag"]
      max_age_seconds = 3000
    },
    {
      allowed_headers = ["tmp"]
      allowed_methods = ["PUT", "POST"]
      allowed_origins = ["https://s3-website.hashicorp.com"]
      expose_headers  = ["ETag"]
      max_age_seconds = 300
    }
  ]

  s3_bucket_versioning = {
    enabled = true
  }

  s3_bucket_logging = {
    target_bucket = module.s3_private_bucket.s3_bucket_arn
    target_prefix = "log/"
  }

  s3_bucket_lifecycle_rule = [
    {
      enabled = true

      id     = "log"
      prefix = "log/"
      tags   = map("rule", "log", "autoclean", "true")

      expiration = {
        days = 90
      }

      transition = [
        {
          days          = 30
          storage_class = "ONEZONE_IA"
        },
        {
          days          = 60
          storage_class = "GLACIER"
        }
      ]

      noncurrent_version_expiration = {
        days = 30
      }
    },
    {
      enabled = true

      id                                     = "log1"
      prefix                                 = "log1/"
      abort_incomplete_multipart_upload_days = 7

      noncurrent_version_transition = [
        {
          days          = 60
          storage_class = "STANDARD_IA"
        },
        {
          days          = 90
          storage_class = "ONEZONE_IA"
        },
        {
          days          = 180
          storage_class = "GLACIER"
        },
      ]

      noncurrent_version_expiration = {
        days = 365
      }
    }
  ]

  s3_bucket_server_side_encryption_configuration = {
    //rule = {
    //  apply_server_side_encryption_by_default = {
    //    kms_master_key_id = module.kms_key.kms_key_arn
    //    sse_algorithm     = "aws:kms"
    //  }
    //}
  }

  s3_bucket_object_lock_configuration = {
    //object_lock_enabled = "Enabled"
    //rule = {
    //  default_retention = {
    //    mode = "GOVERNANCE"
    //    days = 1
    //  }
    //}
  }


  # Add files to bucket
  enable_s3_bucket_object = true
  s3_bucket_object_source = ["additional_files/test.txt", "additional_files/test2.txt"]

  tags = map("Env", "stage", "Orchestration", "Terraform")
}


module "s3_bucket_public_access_block" {
  source      = "../../modules/s3"
  name        = "TEST"
  environment = "dev"

  # AWS S3 bucket
  enable_s3_bucket = true
  s3_bucket_name   = "natarov-test-bucket3"
  s3_bucket_acl    = "private"

  # AWS S3 bucket public access block
  enable_s3_bucket_public_access_block = true

  s3_bucket_public_access_block_block_public_acls       = true
  s3_bucket_public_access_block_block_public_policy     = true
  s3_bucket_public_access_block_ignore_public_acls      = true
  s3_bucket_public_access_block_restrict_public_buckets = true

  tags = map("Env", "stage", "Orchestration", "Terraform")
}