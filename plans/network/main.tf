provider "aws" {
  region     = "us-west-2"
}

terraform {
  backend "s3" {
    bucket = "my-tfstate-files"
    key    = "networkg.tfstate"
    region = "us-west-2"
  }
}