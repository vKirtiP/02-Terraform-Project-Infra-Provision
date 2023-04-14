terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region     = "us-east-1"
  access_key = "**INSERT_YOUR_OWN_ACCESS_KEY"
  secret_key = "**INSERT_YOUR_OWN_SECRET_KEY"
}
