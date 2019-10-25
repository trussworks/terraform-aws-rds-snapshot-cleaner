/**
 * Creates an AWS Lambda function to clean up manual RDS snapshots
 * on a scheduled interval using [truss-aws-tools](https://github.com/trussworks/truss-aws-tools).
 *
 * Creates the following resources:
 *
 * * IAM role for Lambda function find and delete expired RDS snapshots for a
 *   defined RDS instance.
 * * CloudWatch Event to trigger Lambda function on a schedule.
 * * AWS Lambda function to actually delete excess manual RDS snapshots.
 *
 * ## Usage
 *
 * ```hcl
 * module "rds-snapshot-cleaner" {
 *   source  = "trussworks/rds-snapshot-cleaner/aws"
 *   version = "1.0.0"
 *
 *   cleaner_db_instance_identifier = "app-staging"
 *   cleaner_dry_run                = "false"
 *   cleaner_max_db_snapshot_count  = "50"
 *   cleaner_retention_days         = "30"
 *   cloudwatch_logs_retention_days = "90"
 *   environment                    = "staging"
 *   interval_minutes               = "5"
 *   s3_bucket                      = "lambda-builds-us-east-1"
 *   version_to_deploy              = "2.6"
 * }
 * ```
 */

locals {
  pkg  = "truss-aws-tools"
  name = "rds-snapshot-cleaner"
}

data "aws_region" "current" {}
data "aws_caller_identity" "current" {}

#
# IAM
#

data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"

    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

# Allow creating and writing CloudWatch logs for Lambda function.
data "aws_iam_policy_document" "main" {
  statement {
    sid = "WriteCloudWatchLogs"

    effect = "Allow"

    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]

    resources = ["arn:aws:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:log-group:/aws/lambda/${local.name}-${var.cleaner_db_instance_identifier}:*"]
  }

  # Allow describing RDS snapshots for a particular RDS instance and RDS
  # matching the name "$db_instance_identifier-*" (e.g., app-staging-12345676).
  statement {
    sid    = "DescribeDBSnapshots"
    effect = "Allow"

    actions = [
      "rds:DescribeDBSnapshots",
    ]

    resources = [
      "arn:aws:rds:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:db:${var.cleaner_db_instance_identifier}",
      "arn:aws:rds:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:snapshot:${var.cleaner_db_instance_identifier}-*",
    ]
  }

  # Allow deleting RDS snapshots matching the name "$db_instance_identifier-*" (e.g., app-staging-12345676).
  statement {
    sid    = "DeleteDBSnapshots"
    effect = "Allow"

    actions = [
      "rds:DeleteDBSnapshot",
    ]

    resources = [
      "arn:aws:rds:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:snapshot:${var.cleaner_db_instance_identifier}-*",
    ]
  }
}

resource "aws_iam_role" "main" {
  name               = "lambda-${local.name}-${var.cleaner_db_instance_identifier}"
  assume_role_policy = "${data.aws_iam_policy_document.assume_role.json}"
}

resource "aws_iam_role_policy" "main" {
  name = "lambda-${local.name}-${var.cleaner_db_instance_identifier}"
  role = "${aws_iam_role.main.id}"

  policy = "${data.aws_iam_policy_document.main.json}"
}

#
# CloudWatch Scheduled Event
#

resource "aws_cloudwatch_event_rule" "main" {
  name                = "${local.name}-${var.cleaner_db_instance_identifier}"
  description         = "scheduled trigger for ${local.name}"
  schedule_expression = "rate(${var.interval_minutes} minutes)"
}

resource "aws_cloudwatch_event_target" "main" {
  rule = "${aws_cloudwatch_event_rule.main.name}"
  arn  = "${aws_lambda_function.main.arn}"
}

#
# CloudWatch Logs
#

resource "aws_cloudwatch_log_group" "main" {
  # This name must match the lambda function name and should not be changed
  name              = "/aws/lambda/${local.name}-${var.cleaner_db_instance_identifier}"
  retention_in_days = "${var.cloudwatch_logs_retention_days}"

  tags = {
    Name        = "${local.name}-${var.cleaner_db_instance_identifier}"
    Environment = "${var.environment}"
  }
}

#
# Lambda Function
#

resource "aws_lambda_permission" "main" {
  statement_id = "${local.name}-${var.cleaner_db_instance_identifier}"

  action        = "lambda:InvokeFunction"
  function_name = "${aws_lambda_function.main.function_name}"

  principal  = "events.amazonaws.com"
  source_arn = "${aws_cloudwatch_event_rule.main.arn}"
}

resource "aws_lambda_function" "main" {
  depends_on = ["aws_cloudwatch_log_group.main"]

  s3_bucket = "${var.s3_bucket}"
  s3_key    = "${local.pkg}/${var.version_to_deploy}/${local.pkg}.zip"

  function_name = "${local.name}-${var.cleaner_db_instance_identifier}"
  role          = "${aws_iam_role.main.arn}"
  handler       = "${local.name}"
  runtime       = "go1.x"
  memory_size   = "128"
  timeout       = "60"

  # Default AWS managed key for lambda functions
  kms_key_arn = "arn:aws:kms:us-west-2:923914045601:key/1408a5f1-c280-4e54-9276-f68169fbf165"

  environment {
    variables = {
      DB_INSTANCE_IDENTIFIER = "${var.cleaner_db_instance_identifier}"
      DRY_RUN                = "${var.cleaner_dry_run}"
      LAMBDA                 = "true"
      MAX_DB_SNAPSHOT_COUNT  = "${var.cleaner_max_db_snapshot_count}"
      RETENTION_DAYS         = "${var.cleaner_retention_days}"
    }
  }

  tags = {
    Name        = "${local.name}-${var.cleaner_db_instance_identifier}"
    Environment = "${var.environment}"
  }
}
