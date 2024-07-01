module "network" {
  source = "./network"
}

module "compute" {
  source = "./compute"
}

module "cloudfront" {
  source = "./cloudfront"
}

