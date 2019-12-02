output "loadbalancer_dns" {
  description = "DNS for LoadBalancer"
  value       = "http://${module.lb.lb_url}"
}

output "codecommit_clone" {
  description = "https url to clone repo"
  value       = module.codecommit.codecommit_https
}

output "codepipeline_url" {
  value = "https://console.aws.amazon.com/codesuite/codepipeline/pipelines/${var.project}-pipeline/view?region=${var.region}"
}
