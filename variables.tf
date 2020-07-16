variable "cleaner_db_instance_identifier" {
  description = "The RDS database instance identifier."
  type        = string
}

variable "cleaner_dry_run" {
  description = "Don't make any changes and log what would have happened."
  type        = string
}

variable "cleaner_max_db_snapshot_count" {
  description = "The maximum number of manual snapshots allowed. This takes precedence over -retention-days."
  type        = string
  default     = ""
}

variable "cleaner_retention_days" {
  description = "The maximum retention age in days."
  type        = string
}

variable "cloudwatch_logs_retention_days" {
  default     = 90
  description = "Number of days to keep logs in AWS CloudWatch."
  type        = string
}

variable "environment" {
  description = "Environment tag, e.g prod."
}

variable "interval_minutes" {
  default     = 5
  description = "How often to run the Lambda function in minutes."
  type        = string
}

variable "kms_key_arn" {
  description = "ARN of the KMS key used for encrypting environment variables."
  type        = string
  default     = ""
}

variable "s3_bucket" {
  description = "The name of the S3 bucket used to store the Lambda builds."
  type        = string
}

variable "version_to_deploy" {
  description = "The version the Lambda function to deploy."
  type        = string
}
