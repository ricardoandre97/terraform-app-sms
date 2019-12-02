output "cluster_arn" {
  description = "Cluster arn"
  value       = aws_ecs_cluster.cluster.arn
}

output "cluster_name" {
  value = "${var.project}-ecs_cluster"
}
