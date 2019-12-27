module "minecraft" {
  source = "../../modules/service/"

  bucket_name  = "minecraft-syd"
  ssh_key_name = "sydney_hello"
}
