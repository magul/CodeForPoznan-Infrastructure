terraform {
  backend "s3" {
    bucket  = "codeforpoznan-tfstate"
    key     = "codeforpoznan.tfstate"
    profile = "codeforpoznan"
    region  = "eu-west-1"
  }

  # backend "local" {
  #   path = "./state.tfstate"
  # }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 2.70.1"
      # version = "~> 4.8.0"
      # version = "~> 2.36.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 2.2.1"
    }
    template = {
      source  = "hashicorp/template"
      version = "~> 2.1.2"
    }
    postgresql = {
      source  = "cyrilgdn/postgresql"
      version = "~> 1.15.0"
      # version = "~> 1.7.2"
    }
  }

  required_version = ">= 0.13"
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

