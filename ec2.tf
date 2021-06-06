data "aws_ami" "this" {
  most_recent = true
  owners      = ["099720109477"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"] # Ubuntu 20.04
  }
}

resource "aws_instance" "this" {
  ami                    = var.ami == "" ? data.aws_ami.this.image_id : var.ami
  instance_type          = var.instance_type
  subnet_id              = var.subnet_id
  tags                   = var.tags
  iam_instance_profile   = aws_iam_instance_profile.this.name
  key_name               = var.key_name
  vpc_security_group_ids = [aws_security_group.this.id]
  user_data              = file(format("%s/files/user-data.sh", path.module))
  ebs_optimized          = true
  monitoring             = true

  root_block_device {
    volume_size = var.volume_size_gb
    tags        = var.tags
    encrypted   = true
    kms_key_id  = aws_kms_key.this["ebs"].arn
    volume_type = "gp3"
  }

  # https://docs.bridgecrew.io/docs/bc_aws_general_31
  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "required"
  }
}
