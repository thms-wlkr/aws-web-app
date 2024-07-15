module "network" {
  source = "./network"
}

module "compute" {
  source               = "./compute"
  vpc_id               = module.network.vpc_id
  public_sg_id         = module.network.public_sg
  backend_sg_id        = module.network.backend_sg
  public_subnet_ids    = module.network.public_subnet_ids
  private_subnet_ids_1 = module.network.private_subnet_ids_1
}

module "cdn" {
  source      = "./cdn"
  lb_dns_name = module.compute.lb_dns_name
}

