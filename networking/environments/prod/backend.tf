# TODO: rename key to: networking.prod.tfstate and check S3 bucket to see if network.tfstate is removed
terraform {
  backend "s3" {
    bucket = "my-tfstate-files"
    key    = "network.tfstate"
    region = "us-west-2"
  }
}
