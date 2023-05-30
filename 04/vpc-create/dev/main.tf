#### (1) provider ####
provider "aws" {
  region = "ap-northeast-2"
}

#### (2) module my-vpc ####
module "my_vpc" {
  source = "../modules/vpc"

  vpc_cidr          = "192.168.0.0/24"
  vpc_id            = module.my_vpc.vpc_id
  subnet_cidr_block = "192.168.0.0/25"
}

module "my_ec2" {
  source = "../modules/ec2"

  ec2_count = 1
  subnet_id = module.my_vpc.subnet_id
}
