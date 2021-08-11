
################################################################################
# Supporting Resources
################################################################################

provider "aws" {
  region = local.region
}


locals {
  name   = "bastion"
  region = "eu-central-1"

  tags = [
    {
      key                 = "Project"
      value               = "megasecret"
      propagate_at_launch = true
    },
    {
      key                 = "Team"
      value               = "xyz"
      propagate_at_launch = true
    },
  ]

  tags_as_map = {
    Owner       = "user"
    Environment = "dev"
  }

}

# Data to use AMI built with packer
data "aws_ami" "bh_ami" {
  most_recent = true
  owners      = ["self"]

  filter {
    name = "name"

    values = [
      "bastion-ubuntu-20.04-eu-central-1*",
    ]
  }
}

################################################################################
# Bastion related resources
################################################################################

# Launch template
module "bh_lt" {
  source  = "terraform-aws-modules/autoscaling/aws"
  version = "~> 4.0"

  # Autoscaling group
  name = "${local.name}-asg-${local.region}"

  availability_zone = var.availability_zones
  min_size          = 0
  max_size          = 1
  desired_capacity  = var.servers_count

  #security group
  security_groups = [module.bh_ssh_sg.security_group_id]

  #register with target group
  target_group_arns = module.bh_nlb.target_group_arns

  # Launch template
  use_lt    = true
  create_lt = true

  image_id      = data.aws_ami.bh_ami.id
  instance_type = "t3.micro"

  key_name = var.keypair_name

  tags        = local.tags
  tags_as_map = local.tags_as_map
}

# Security Group
module "bh_ssh_sg" {
  source  = "terraform-aws-modules/security-group/aws//modules/ssh"
  version = "~> 4.0"

  name        = "${local.name}-ssh"
  vpc_id      = var.vpc_id
  description = "Security group for ${local.name} access"

  # VPC cidr is used since NLB does not suppor attaching security groups
  ingress_cidr_blocks = ["172.31.0.0/16"]

  tags = local.tags_as_map
}

# Network Loadbalancer
module "bh_nlb" {
  source  = "terraform-aws-modules/alb/aws"
  version = "~> 6.0"

  name = "${local.name}-nlb-${local.region}"

  # create network loadbalancer
  load_balancer_type = "network"

  vpc_id  = var.vpc_id
  subnets = var.public_subnets

  http_tcp_listeners = [
    {
      port               = 22
      protocol           = "TCP"
      target_group_index = 0
    }
  ]

  target_groups = [
    {
      name             = "${local.name}-tg-${local.region}"
      backend_protocol = "TCP"
      backend_port     = 22
      target_type      = "instance"
    },
  ]

  tags = local.tags_as_map
}

################################################################################
# Monitoring
################################################################################

resource "aws_cloudwatch_metric_alarm" "bh_nlb_healthyhosts" {
  alarm_name          = "${local.name}-nlb-${local.region}-healthy-hosts"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "HealthyHostCount"
  namespace           = "AWS/NetworkELB"
  period              = "60"
  statistic           = "Average"
  threshold           = var.servers_count
  alarm_description   = "Number of healthy nodes in Target Group"
  actions_enabled     = "true"
  treat_missing_data  = "breaching"
  dimensions = {
    TargetGroup  = module.bh_nlb.target_group_arn_suffixes[0]
    LoadBalancer = module.bh_nlb.lb_arn_suffix
  }
}
