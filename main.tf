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

data "aws_iam_policy_document" "codeforpoznan_public_policy" {
  version = "2012-10-17"

  statement {
    sid    = "PublicListBucket"
    effect = "Allow"
    principals {
      identifiers = ["*"]
      type        = "*"
    }
    actions   = ["s3:ListBucket"]
    resources = ["arn:aws:s3:::codeforpoznan-public"]
  }

  statement {
    sid    = "PublicGetObject"
    effect = "Allow"
    principals {
      identifiers = ["*"]
      type        = "*"
    }
    actions   = ["s3:GetObject"]
    resources = ["arn:aws:s3:::codeforpoznan-public/*"]
  }
}

// shared public bucket (we will push here all static assets in separate directories)
resource "aws_s3_bucket" "codeforpoznan_public" {
  bucket = "codeforpoznan-public"

  cors_rule {
    allowed_methods = ["GET", "HEAD"]
    allowed_origins = ["*"]
  }

  policy = data.aws_iam_policy_document.codeforpoznan_public_policy.json
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
