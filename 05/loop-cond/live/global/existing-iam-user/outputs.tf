output "all-arns" {
  value = values(aws_iam_user.existing_user)[*].arn
}