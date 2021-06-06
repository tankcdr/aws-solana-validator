resource "aws_iam_role" "this" {
  name               = format("%s-%s-ec2", var.name, var.environment)
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

resource "aws_iam_policy_attachment" "this" {
  name       = format("%s-%s-instance-ssm", var.name, var.environment)
  roles      = [aws_iam_role.this.name]
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "this" {
  name = format("%s-%s-ec2", var.name, var.environment)
  role = aws_iam_role.this.name
}

data "aws_iam_policy_document" "assume_role" {
  statement {
    sid     = "AllowECSTasksToAssumeRole"
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}
