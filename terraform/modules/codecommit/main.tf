resource "aws_codecommit_repository" "repo" {
  repository_name = var.name
  tags   = {
    Name    = "${var.project}-codecommit"
    Project = "${var.project}"
  }
}