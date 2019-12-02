output "vpc_id" {
  description = "cidr block for subnet1"
  value       = aws_vpc.vpc.id
}

output "subnet1_id" {
  description = "cidr block for subnet1"
  value       = aws_subnet.subnet1.id
}

output "subnet2_id" {
  description = "cidr block for subnet2"
  value       = aws_subnet.subnet2.id
}

output "subnets" {
  value = [aws_subnet.subnet1.id, aws_subnet.subnet2.id]
}