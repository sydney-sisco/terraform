terraform {
  backend "s3" {
    bucket = "my-tfstate-files"
    key    = "statefiles-bucket.tfstate"
    region = "us-west-2"
  }
}