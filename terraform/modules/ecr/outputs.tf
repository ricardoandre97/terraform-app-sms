output "ecr_name" {
  description = "ECR Name"
  value       = aws_ecr_repository.ecr.name
}

output "ecr_arn" {
  description = "ECR ARN"
  value       = aws_ecr_repository.ecr.arn
}

output "ecr_url" {
  description = "ECR Url"
  value       = aws_ecr_repository.ecr.repository_url
}
