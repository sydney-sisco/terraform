module "networking" {
  source = "../../modules/service/"

  cidr_block = "10.0.0.0/16"

}

output "vpc_id" {
  value = module.networking.vpc_id
}

output "public_subnet_ids" {
  value = module.networking.public_subnet_ids
}

output "private_subnet_ids" {
  value = module.networking.private_subnet_ids
}
