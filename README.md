Creates an AWS Lambda function to clean up manual RDS snapshots
on a scheduled interval using [truss-aws-tools](https://github.com/trussworks/truss-aws-tools).

Creates the following resources:

* IAM role for Lambda function find and delete expired RDS snapshots for a
  defined RDS instance.
* CloudWatch Event to trigger Lambda function on a schedule.
* AWS Lambda function to actually delete excess manual RDS snapshots.


## Usage

```hcl
module "rds-snapshot-cleaner" {
  source  = "trussworks/rds-snapshot-cleaner/aws"
  version = "1.0.0"

  cleaner_db_instance_identifier = "app-staging"
  cleaner_dry_run                = "false"
  cleaner_max_db_snapshot_count  = "50"
  cleaner_retention_days         = "30"
  cloudwatch_logs_retention_days = "90"
  environment                    = "staging"
  interval_minutes               = "5"
  s3_bucket                      = "lambda-builds-us-east-1"
  version_to_deploy              = "2.6"
}
```

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 0.13.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 3.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 3.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_cloudwatch_event_rule.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_event_rule) | resource |
| [aws_cloudwatch_event_target.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_event_target) | resource |
| [aws_cloudwatch_log_group.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group) | resource |
| [aws_iam_role.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_lambda_function.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_function) | resource |
| [aws_lambda_permission.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_permission) | resource |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_iam_policy_document.assume_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_partition.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/partition) | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_cleaner_db_instance_identifier"></a> [cleaner\_db\_instance\_identifier](#input\_cleaner\_db\_instance\_identifier) | The RDS database instance identifier. | `string` | n/a | yes |
| <a name="input_cleaner_dry_run"></a> [cleaner\_dry\_run](#input\_cleaner\_dry\_run) | Don't make any changes and log what would have happened. | `string` | n/a | yes |
| <a name="input_cleaner_max_db_snapshot_count"></a> [cleaner\_max\_db\_snapshot\_count](#input\_cleaner\_max\_db\_snapshot\_count) | The maximum number of manual snapshots allowed. This takes precedence over -retention-days. | `string` | `""` | no |
| <a name="input_cleaner_retention_days"></a> [cleaner\_retention\_days](#input\_cleaner\_retention\_days) | The maximum retention age in days. | `string` | n/a | yes |
| <a name="input_cloudwatch_kms_key_arn"></a> [cloudwatch\_kms\_key\_arn](#input\_cloudwatch\_kms\_key\_arn) | ARN of the Cloudwatch KMS key used for encrypting Cloudwatch log groups. | `string` | `""` | no |
| <a name="input_cloudwatch_logs_retention_days"></a> [cloudwatch\_logs\_retention\_days](#input\_cloudwatch\_logs\_retention\_days) | Number of days to keep logs in AWS CloudWatch. | `string` | `90` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | Environment tag, e.g prod. | `any` | n/a | yes |
| <a name="input_interval_minutes"></a> [interval\_minutes](#input\_interval\_minutes) | How often to run the Lambda function in minutes. | `string` | `5` | no |
| <a name="input_kms_key_arn"></a> [kms\_key\_arn](#input\_kms\_key\_arn) | ARN of the KMS key used for encrypting environment variables. | `string` | `""` | no |
| <a name="input_s3_bucket"></a> [s3\_bucket](#input\_s3\_bucket) | The name of the S3 bucket used to store the Lambda builds. | `string` | n/a | yes |
| <a name="input_version_to_deploy"></a> [version\_to\_deploy](#input\_version\_to\_deploy) | The version the Lambda function to deploy. | `string` | n/a | yes |

## Outputs

No outputs.
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->