terraform {
  backend "s3" {
    bucket  = "codeforpoznan-tfstate"
    key     = "codeforpoznan.tfstate"
    profile = "codeforpoznan"
    region  = "eu-west-1"
  }

  required_providers {
    aws = {
      source                = "hashicorp/aws"
      version               = "4.31.0"
      configuration_aliases = [aws.north_virginia]
    }
    random = {
      source  = "hashicorp/random"
      version = "3.4.3"
    }
    cloudinit = {
      source  = "hashicorp/cloudinit"
      version = "2.2.0"
    }
    postgresql = {
      source  = "cyrilgdn/postgresql"
      version = "1.17.1"
    }
  }

  required_version = ">= 1.2.6"
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

