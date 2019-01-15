provider "aws" {
  region     = "us-west-2"
}
resource "aws_s3_bucket" "state" {
  bucket = "my-tfstate-files"
  acl    = "private"

  tags = {
    Name        = "my-tfstate-files"
  }
}