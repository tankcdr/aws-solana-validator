# AWS Solana Validator

Terraform module to create an AWS EC2 running a full Solana validator node with RPC.

## Assumptions

- You want to run a Solana Validator in the AWS public cloud
- You've created an AWS Virtual Private Cloud (VPC) and public subnets where you intend to put the Solana validator resources.

## Node management

For security reasons port 22 is not open for SSH, in the firewall.
Instead, the module leverage AWS SSM.
Use [session manager](https://docs.aws.amazon.com/systems-manager/latest/userguide/session-manager-getting-started-enable-ssh-connections.html)
to access the instance.
Use you AWS User or assumed role, with sufficient permissions, to access the node.
Find the `INSTANCE_ID` in the AWS console, or via cli.

```shell
aws ssm start-session --target ${INSTANCE_ID}

# open bash shell and switch to sol user 
sudo bash && su - sol
```

To open port 22, set `var.enable_ssh` to `true`.

## Usage example

```terraform
resource "tls_private_key" "this" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "this" {
  key_name   = format("%s-key", var.name)
  public_key = tls_private_key.this.public_key_openssh
}

module "validator_node" {
  source = "github.com/solanium-io/aws-solana-validator?ref=v1.0.0"

  # meta
  environment = "dev"
  tags        = merge(local.tags, { Name = "SolanaValidatorNode" })

  # network
  vpc_id    = module.vpc.vpc_id
  subnet_id = module.vpc.public_subnets[1]

  # security
  whitelist_ips = var.whitelist_ips
  enable_ssh    = false
  
  # machine
  ami           = "ami-0a8e758f5e873d1c1" # ubuntu 20.04
  instance_type = "m5ad.8xlarge"
  key_name      = aws_key_pair.this.key_name
}
```

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 0.15 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | 3.38.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 3.38.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_iam_instance_profile.this](https://registry.terraform.io/providers/hashicorp/aws/3.38.0/docs/resources/iam_instance_profile) | resource |
| [aws_iam_policy_attachment.this](https://registry.terraform.io/providers/hashicorp/aws/3.38.0/docs/resources/iam_policy_attachment) | resource |
| [aws_iam_role.this](https://registry.terraform.io/providers/hashicorp/aws/3.38.0/docs/resources/iam_role) | resource |
| [aws_instance.this](https://registry.terraform.io/providers/hashicorp/aws/3.38.0/docs/resources/instance) | resource |
| [aws_kms_alias.this](https://registry.terraform.io/providers/hashicorp/aws/3.38.0/docs/resources/kms_alias) | resource |
| [aws_kms_key.this](https://registry.terraform.io/providers/hashicorp/aws/3.38.0/docs/resources/kms_key) | resource |
| [aws_security_group.this](https://registry.terraform.io/providers/hashicorp/aws/3.38.0/docs/resources/security_group) | resource |
| [aws_ami.this](https://registry.terraform.io/providers/hashicorp/aws/3.38.0/docs/data-sources/ami) | data source |
| [aws_caller_identity.this](https://registry.terraform.io/providers/hashicorp/aws/3.38.0/docs/data-sources/caller_identity) | data source |
| [aws_iam_policy_document.assume_role](https://registry.terraform.io/providers/hashicorp/aws/3.38.0/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.kms](https://registry.terraform.io/providers/hashicorp/aws/3.38.0/docs/data-sources/iam_policy_document) | data source |
| [aws_region.this](https://registry.terraform.io/providers/hashicorp/aws/3.38.0/docs/data-sources/region) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_ami"></a> [ami](#input\_ami) | AMI to be used in EC2, leave empty to use the newest | `string` | `""` | no |
| <a name="input_enable_ssh"></a> [enable\_ssh](#input\_enable\_ssh) | Open port 22 in the security group | `bool` | `false` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | Environment for the deployment | `string` | n/a | yes |
| <a name="input_instance_type"></a> [instance\_type](#input\_instance\_type) | Instance type to be used in EC2 | `string` | `"m5ad.8xlarge"` | no |
| <a name="input_key_name"></a> [key\_name](#input\_key\_name) | SSH Keyname | `string` | `null` | no |
| <a name="input_name"></a> [name](#input\_name) | Name (prefix) of to assign to the stack | `string` | `"validator-node"` | no |
| <a name="input_subnet_id"></a> [subnet\_id](#input\_subnet\_id) | Subnet to deploy the EC2 | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | tags to attach to resources | `map(string)` | `{}` | no |
| <a name="input_volume_size_gb"></a> [volume\_size\_gb](#input\_volume\_size\_gb) | Size of block device in GB | `number` | `2048` | no |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | ID of VPC to deploy resources in | `string` | n/a | yes |
| <a name="input_whitelist_ips"></a> [whitelist\_ips](#input\_whitelist\_ips) | List of IPs that are whitelisted to the security group | `list(string)` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_instance_id"></a> [instance\_id](#output\_instance\_id) | Instance ID of the created EC2 |
| <a name="output_public_ip"></a> [public\_ip](#output\_public\_ip) | Instance ID of the created EC2 |
<!-- END_TF_DOCS -->
