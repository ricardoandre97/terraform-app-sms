resource "aws_ecs_cluster" "cluster" {
  name = "${var.project}-ecs_cluster"

  tags = {
    Name    = "${var.project}-ecs_cluster"
    Project = "${var.project}"
  }
}