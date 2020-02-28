terraform {
  backend "s3" {
    bucket  = "codeforpoznan-tfstate"
    key     = "codeforpoznan.tfstate"
    profile = "codeforpoznan"
    region  = "eu-west-1"
  }
}

provider "aws" {
  region  = "eu-west-1"
  profile = "codeforpoznan"
}

// shared public bucket (we will push here all static assets in separate directories)
resource "aws_s3_bucket" "codeforpoznan_public" {
  bucket = "codeforpoznan-public"

  cors_rule {
    allowed_methods = ["GET", "HEAD"]
    allowed_origins = ["*"]
  }

  policy = <<POLICY
{
  "Version":"2012-10-17",
  "Statement":[{
    "Sid":"PublicListBucket",
    "Effect":"Allow",
    "Principal": "*",
    "Action":["s3:ListBucket"],
    "Resource":["arn:aws:s3:::codeforpoznan-public"]
  }, {
    "Sid":"PublicGetObject",
    "Effect":"Allow",
    "Principal": "*",
    "Action":["s3:GetObject"],
    "Resource":["arn:aws:s3:::codeforpoznan-public/*"]
  }]
}
    POLICY
}

// shared private bucket for storing zipped projects and lambdas code
resource "aws_s3_bucket" "codeforpoznan_lambdas" {
  bucket = "codeforpoznan-lambdas"
  acl    = "private"
}

// shared private bucket for storing terraform state in one place
resource "aws_s3_bucket" "codeforpoznan_tfstate" {
  bucket = "codeforpoznan-tfstate"
  acl    = "private"
}

// DNS zone for codeforpoznan.pl
resource "aws_route53_zone" "codeforpoznan_pl" {
  name = "codeforpoznan.pl"
}
