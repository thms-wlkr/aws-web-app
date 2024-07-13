module "network" {
  source = "./network"
}

module "compute" {
  source = "./compute"
  public_sg_id = module.network.public_sg
  backend_sg_id = module.network.backend_sg
  public_subnet_ids = module.network.public_subnet
}

module "cloudfront" {
  source = "./cloudfront"
  lb_dns_name = module.compute.lb_dns_name
}

