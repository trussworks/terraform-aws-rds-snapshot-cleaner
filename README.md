Creates an AWS Lambda function to clean up manual RDS snapshots
on a scheduled interval using [truss-aws-tools](https://github.com/trussworks/truss-aws-tools).

Creates the following resources:

  IAM role for Lambda function find and delete expired RDS snapshots for a
  defined RDS instance.
* CloudWatch Event to trigger Lambda function on a schedule.
* AWS Lambda function to actually delete excess manual RDS snapshots.

## Terraform Versions

Terraform 0.12: Pin module version to ~> 2.0.0. Submit pull requests to master branch.
Terraform 0.11: Pin module version to ~> 1.0.0. Submit pull requests to terraform011 branch.

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
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| cleaner\_db\_instance\_identifier | The RDS database instance identifier. | string | n/a | yes |
| cleaner\_dry\_run | Don't make any changes and log what would have happened. | string | n/a | yes |
| cleaner\_max\_db\_snapshot\_count | The maximum number of manual snapshots allowed. This takes precedence over -retention-days. | string | n/a | yes |
| cleaner\_retention\_days | The maximum retention age in days. | string | n/a | yes |
| cloudwatch\_logs\_retention\_days | Number of days to keep logs in AWS CloudWatch. | string | `"90"` | no |
| environment | Environment tag, e.g prod. | string | n/a | yes |
| interval\_minutes | How often to run the Lambda function in minutes. | string | `"5"` | no |
| s3\_bucket | The name of the S3 bucket used to store the Lambda builds. | string | n/a | yes |
| version\_to\_deploy | The version the Lambda function to deploy. | string | n/a | yes |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
