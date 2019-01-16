provider "aws" {
  region     = "us-west-2"
}

terraform {
  backend "s3" {
    bucket = "my-tfstate-files"
    key    = "aurora.tfstate"
    region = "us-west-2"
  }
}