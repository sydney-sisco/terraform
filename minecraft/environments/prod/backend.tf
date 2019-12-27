terraform {
  backend "s3" {
    bucket = "my-tfstate-files"
    key    = "minecraft.prod.tfstate"
    region = "us-west-2"
  }
}
