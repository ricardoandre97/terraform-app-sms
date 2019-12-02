resource "aws_sns_topic" "topic" {
  name = "${var.project}-sns"

  tags = {
    Name    = "${var.project}-sns"
    Project = "${var.project}"
  }
}

resource "aws_sns_topic_subscription" "subscription" {
  topic_arn = aws_sns_topic.topic.arn
  protocol  = "sms"
  endpoint  = var.cellphone_number
}