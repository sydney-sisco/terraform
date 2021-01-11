terraform {
  backend "s3" {
    bucket = "my-tfstate-files"
    key    = "minecraft.stag.tfstate"
    region = "us-west-2"
  }
}
