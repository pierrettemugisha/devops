#############################################################################
#                                                                           #
# This file contains the main aws infrastructures needed by each state      #
# in the HumanGov organization.                                             #
#                                                                           #
#############################################################################


#Resource to create a DynamoDB
resource "aws_dynamodb_table" "state_dynamodb" {
  name         = "humangov-${var.state_name}-dynamodb"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "id"

  attribute {
    name = "id"
    type = "S"
  }

  tags = {
    Name = "humangov-${var.state_name}"
  }
}

# Resource to create a random string.
# This will be used to generate a unique S3 name, as S3 names are unique worldwide.
resource "random_string" "bucket_suffix" {
  length  = 4
  special = false
  upper   = false
}

# Resource to create an S3 bucket
resource "aws_s3_bucket" "state_s3" {
  bucket = "humangov-${var.state_name}-s3-${random_string.bucket_suffix.result}"
  acl    = "private"

  tags = {
    Name = "humangov-${var.state_name}"
  }
}
