module "minecraft" {
  source = "../../modules/service/"

  bucket_name  = "test-minecraft-syd"
  ssh_key_name = "sydney_hello"
  env_prefix = "test-"
  # instance_type = "t3.nano"
}

output "public_ip" {
  value = module.minecraft.public_ip
}
