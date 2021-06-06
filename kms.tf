locals {
  kms = { for key in ["ebs", "ssm"] :
    key => {
      alias       = format("%s-%s-%s", var.name, var.environment, key)
      description = format("Key to be used to encrypt/decrypt AWS %s", upper(key))
    }
  }
}

resource "aws_kms_key" "this" {
  for_each = local.kms

  description             = each.value.description
  deletion_window_in_days = 10
  enable_key_rotation     = true
  policy                  = data.aws_iam_policy_document.kms.json
  tags                    = var.tags
}

resource "aws_kms_alias" "this" {
  for_each = aws_kms_key.this

  name          = format("alias/%s", local.kms[each.key].alias)
  target_key_id = each.value.id
}

data "aws_iam_policy_document" "kms" {
  statement {
    sid       = "CurrentAccountKmsKeyPolicy"
    actions   = ["kms:*"]
    resources = ["*"]
    principals {
      type        = "AWS"
      identifiers = [format("arn:aws:iam::%s:root", data.aws_caller_identity.this.account_id)]
    }
    principals {
      type        = "Service"
      identifiers = ["logs.amazonaws.com"]
    }
  }
}
