#############################################################################
#                                                                           #
# This file contains the main aws infrastructures needed by each state      #
# in the HumanGov organization.                                             #
#                                                                           #
# PRE-REWUISITES:                                                           #
#   Configure Cloud 9 with non-temporary credentials                        #
#       - Create a new user on IAM with Admin privilege                     #
#       - Disable the temporary credentials on Cloud9 by clicking on        #
#         Settings > AWS Settings > Credentials > Turning Off the option    #
#         “AWS managed temporary credentials”                               #
#       - Configure the new IAM user credentials by running the             #
#         `aws configure` command                                           #
#############################################################################


# Resource to create security group
resource "aws_security_group" "state_ec2_sg" {
  name        = "humangov-${var.state_name}-ec2-sg"
  description = "Allow traffic on ports 22 and 80"

  
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  ingress { // optional port for troubleshooting. Can be removed if wanted
    from_port   = 5000
    to_port     = 5000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    security_groups = ["<YOUR_CLOUD9_SECGROUP>"] // replace this with your acture security group id
  }
  
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "humangov-${var.state_name}"
  }
}

# Resource to create an EC2 instance
resource "aws_instance" "state_ec2" {
  ami                    = "ami-007855ac798b5175e"
  instance_type          = "t2.micro"
  key_name               = "humangov-ec2-key"
  vpc_security_group_ids = [aws_security_group.state_ec2_sg.id]
  iam_instance_profile = aws_iam_instance_profile.s3_dynamodb_full_access_instance_profile.name

  tags = {
    Name = "humangov-${var.state_name}"
  }
}

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

resource "aws_iam_role" "s3_dynamodb_full_access_role" {
  name = "humangov-${var.state_name}-s3_dynamodb_full_access_role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF

  tags = {
        Name = "humangov-${var.state_name}"
  }  
  
}

resource "aws_iam_role_policy_attachment" "s3_full_access_role_policy_attachment" {
  role       = aws_iam_role.s3_dynamodb_full_access_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
  
}

resource "aws_iam_role_policy_attachment" "dynamodb_full_access_role_policy_attachment" {
  role       = aws_iam_role.s3_dynamodb_full_access_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonDynamoDBFullAccess"

}

resource "aws_iam_instance_profile" "s3_dynamodb_full_access_instance_profile" {
  name = "humangov-${var.state_name}-s3_dynamodb_full_access_instance_profile"
  role = aws_iam_role.s3_dynamodb_full_access_role.name

  tags = {
      Name = "humangov-${var.state_name}"
  }  
}