resource "aws_ssm_parameter" "sns_topic" {
  name  = "${var.project}-sns_topic"
  type  = "String"
  value = var.sns_arn
}