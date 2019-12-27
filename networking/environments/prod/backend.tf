terraform {
  backend "s3" {
    bucket = "my-tfstate-files"
    key    = "networking.prod.tfstate"
    region = "us-west-2"
  }
}
