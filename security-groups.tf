/*
 Notes:

 Firewall settings can be found here: https://docs.solana.com/running-validator/validator-reqs#software
*/

resource "aws_security_group" "this" {
  name        = format("%s-ec2-instance", var.name)
  vpc_id      = var.vpc_id
  tags        = var.tags
  description = format("Security group for %s", title(var.name))

  # validator ports
  dynamic "ingress" {
    for_each = ["tcp", "udp"]
    content {
      description = format("Allow inbound %s on portrange 8000-8010", ingress.value)
      from_port   = 8000
      to_port     = 8010
      protocol    = ingress.value
      cidr_blocks = var.whitelist_ips
    }
  }

  ingress {
    description = "Allow inbound rpc"
    from_port   = 8899
    to_port     = 8899
    protocol    = "tcp"
    cidr_blocks = var.whitelist_ips
  }

  # ssh (optional)
  dynamic "ingress" {
    for_each = var.enable_ssh ? { tcp = 22 } : {}
    content {
      description = "Allow inbound SSH"
      from_port   = ingress.value
      to_port     = ingress.value
      protocol    = ingress.key
      cidr_blocks = var.whitelist_ips
    }
  }

  # allow all outbound traffic
  egress {
    description = "Allow all outbound"
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }
}
