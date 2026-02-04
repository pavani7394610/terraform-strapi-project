module "ec2" {
  source        = "./modules/ec2"
  instance_type = var.instance_type
  ec2_key_name  = var.ec2_key_name
  aws_region    = var.aws_region
}
