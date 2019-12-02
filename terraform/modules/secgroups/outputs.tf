output "lb_secgroup" {
  description = "LB Security Group"
  value       = aws_security_group.lb.id
}

output "web_secgroup" {
  description = "Web Security Group"
  value       = aws_security_group.web.id
}
