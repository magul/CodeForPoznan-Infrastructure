terraform {
  required_version = "~> 1.12.0"

  backend "s3" {
    bucket  = "codeforpoznan-tfstate"
    key     = "codeforpoznan.tfstate"
    profile = "codeforpoznan"
    region  = "eu-west-1"
  }

  required_providers {
    aws = {
      source                = "hashicorp/aws"
      version               = "5.98.0"
      configuration_aliases = [aws.north_virginia]
    }
    random = {
      source  = "hashicorp/random"
      version = "3.7.2"
    }
    cloudinit = {
      source  = "hashicorp/cloudinit"
      version = "2.3.7"
    }
    postgresql = {
      source  = "cyrilgdn/postgresql"
      version = "1.25.0"
    }
  }
}

provider "aws" {
  region  = "eu-west-1"
  profile = "codeforpoznan"
}

provider "aws" {
  region  = "us-east-1"
  profile = "codeforpoznan"
  alias   = "north_virginia"
}

