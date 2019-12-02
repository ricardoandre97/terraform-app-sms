output "codecommit_id" {
  description = "Codecommit ID"
  value       = aws_codecommit_repository.repo.repository_id
}

output "codecommit_arn" {
  description = "Codecommit ARN"
  value       = aws_codecommit_repository.repo.arn
}

output "codecommit_https" {
  description = "Codecommit https url"
  value       = aws_codecommit_repository.repo.clone_url_http
}