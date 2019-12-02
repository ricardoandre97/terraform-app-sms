terraform {
  required_version = ">= 0.12.15"
  required_providers {
    aws = ">= 2.38"
  }
}

provider "aws" {
  region = "us-east-1"
}

module "networking" {
  source = "./modules/networking"

  cidr_block = "10.100.0.0/16"
  subnet1_cidr = "10.100.1.0/24"
  subnet2_cidr = "10.100.2.0/24"
  project  = var.project
  region = var.region
}

module "secgroups" {
  source = "./modules/secgroups"
  vpc_id = module.networking.vpc_id
  project  = var.project
}

module "ecr" {
  source = "./modules/ecr"
  name = var.app_name
  project  = var.project
}

module "codecommit" {
  source = "./modules/codecommit"
  name = var.app_name
  project  = var.project
}

module "sns" {
  source = "./modules/sns"
  project = var.project
  cellphone_number = var.cellphone_number
}

module "sns_parameter_store" {
  source = "./modules/ssm"
  project = var.project
  sns_arn = module.sns.sns_arn
}

module "lb" {
  source = "./modules/lb"

  internal = false
  health_check_path = "/"
  app_port = var.app_port

  vpc_id = module.networking.vpc_id
  subnets = module.networking.subnets
  secgroups = [module.secgroups.lb_secgroup]

  project = var.project
}

module "ecs-cluster" {
  source = "./modules/cluster"
  project = var.project
}

module "pipeline" {
  source = "./modules/pipeline"
  project = var.project

  codecommit_arn = module.codecommit.codecommit_arn
  repo_name = var.app_name
  app_name = var.app_name
  branch = var.pipeline_branch
  ecr_arn = module.ecr.ecr_arn
  ecr_url = module.ecr.ecr_url
  app_port = var.app_port

  ssm_param_name = module.sns_parameter_store.ssm_param_name
  # Fargate deployment
  desired_count = 2
  cluster = module.ecs-cluster.cluster_name
  target_group = module.lb.target_group_arn
  fargate_secgroup = module.secgroups.web_secgroup
  subnet1 = module.networking.subnet1_id
  subnet2 = module.networking.subnet2_id
}