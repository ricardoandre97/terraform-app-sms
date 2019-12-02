output "ssm_param_arn" {
  description = "SNS ARN"
  value       = aws_ssm_parameter.sns_topic.arn
}

output "ssm_param_name" {
  value = aws_ssm_parameter.sns_topic.name
}
