output "target_group_arn" {
  description = "Arn of the created target group"
  value       = aws_alb_target_group.target_group.id
}

output "lb_url" {
  description = "Url of the created LB"
  value       = aws_alb.lb.dns_name
}
