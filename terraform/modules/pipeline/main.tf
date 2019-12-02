###########################
######## CodeBuild ########
###########################

resource "aws_iam_role" "codebuild_role" {
  name = "${var.project}-codebuild_role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "codebuild.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "codebuild_policy" {
  role = aws_iam_role.codebuild_role.name

  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Resource": "*",
      "Effect": "Allow",
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents",
        "ecr:GetAuthorizationToken"
      ]
    },
    {
      "Resource": "${var.ecr_arn}",
      "Effect": "Allow",
      "Action": [
        "ecr:GetDownloadUrlForLayer",
        "ecr:BatchGetImage",
        "ecr:BatchCheckLayerAvailability",
        "ecr:PutImage",
        "ecr:InitiateLayerUpload",
        "ecr:UploadLayerPart",
        "ecr:CompleteLayerUpload"
      ]
    },
    {
      "Effect":"Allow",
      "Action": [
        "s3:GetObject",
        "s3:GetObjectVersion",
        "s3:GetBucketVersioning",
        "s3:PutObject"
      ],
      "Resource": [
        "${aws_s3_bucket.codepipeline_bucket.arn}",
        "${aws_s3_bucket.codepipeline_bucket.arn}/*"
      ]
    }
  ]
}
POLICY
}

resource "aws_codebuild_project" "codebuild_project" {
  name          = "${var.project}-codebuild_project"
  service_role  = aws_iam_role.codebuild_role.arn

  artifacts {
    type = "CODEPIPELINE"
  }

  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "aws/codebuild/standard:2.0"
    type                        = "LINUX_CONTAINER"
    privileged_mode             = true

    environment_variable {
      name = "REPOSITORY_URI"
      value = var.ecr_url
    }

    environment_variable {
      name = "CLUSTER"
      value = var.cluster
    }

    environment_variable {
      name = "DESIRED_COUNT"
      value = var.desired_count
    }

    environment_variable {
      name = "SECURITY_GROUP"
      value = var.fargate_secgroup
    }

    environment_variable {
      name = "TARGET_GROUP_ARN"
      value = var.target_group
    }

    environment_variable {
      name = "SUBNET1"
      value = var.subnet1
    }

    environment_variable {
      name = "SUBNET2"
      value = var.subnet2
    }

    environment_variable {
      name = "APP_NAME"
      value = var.app_name
    }

    environment_variable {
      name = "APP_PORT"
      value = var.app_port
    }

    environment_variable {
      name = "SSM_PARAM_NAME"
      value = var.ssm_param_name
    }
  
  }

  source {
    type = "CODEPIPELINE"
  }

  tags   = {
    Name    = "${var.project}-ecr"
    Project = "${var.project}"
  }
}

#################################
# CloudFormation Execution Role #
#################################

resource "aws_iam_role" "cloudformation_role" {
  name = "cloudformation-role-terraform-codepipeline"
  assume_role_policy = <<EOF
{
    "Statement": [{
        "Effect": "Allow",
        "Principal": { "Service": [ "cloudformation.amazonaws.com" ]},
        "Action": [ "sts:AssumeRole" ]
    }]
}
EOF
}

resource "aws_iam_role_policy" "cloudformation_policy" {
  name = "cloudformation_policy"
  role = aws_iam_role.cloudformation_role.id

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect":"Allow",
      "Action": [
        "ecs:*",
        "ecr:*",
        "iam:*",
        "logs:*",
        "cloudformation:*"
      ],
      "Resource": "*"
    }
  ]
}
EOF
}
##############################
######## Codepipeline ########
##############################
resource "aws_s3_bucket" "codepipeline_bucket" {
  tags   = {
    Name    = "${var.project}-s3_artifact"
    Project = "${var.project}"
  }
}

resource "aws_iam_role" "codepipeline_role" {

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "codepipeline.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "codepipeline_policy" {
  name = "codepipeline_policy"
  role = aws_iam_role.codepipeline_role.id

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect":"Allow",
      "Action": [
        "s3:GetObject",
        "s3:GetObjectVersion",
        "s3:GetBucketVersioning",
        "s3:PutObject"
      ],
      "Resource": [
        "${aws_s3_bucket.codepipeline_bucket.arn}",
        "${aws_s3_bucket.codepipeline_bucket.arn}/*"
      ]
    },
    {
      "Effect": "Allow",
      "Action": [
        "codebuild:BatchGetBuilds",
        "codebuild:StartBuild",
        "cloudformation:*",
        "iam:PassRole"
      ],
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "codecommit:*"
      ],
      "Resource": "${var.codecommit_arn}"
    }
  ]
}
EOF
}

resource "aws_codepipeline" "codepipeline" {
  name     = "${var.project}-pipeline"
  role_arn = aws_iam_role.codepipeline_role.arn

  artifact_store {
    location = aws_s3_bucket.codepipeline_bucket.bucket
    type     = "S3"
  }

  stage {
    name = "Source"

    action {
      name             = "Source"
      category         = "Source"
      owner            = "AWS"
      provider         = "CodeCommit"
      version          = "1"
      output_artifacts = ["source_output"]

      configuration = {
        RepositoryName   = var.repo_name
        BranchName = var.branch
      }

      run_order = 1
    }
  }

  stage {
    name = "Build"

    action {
      name             = "Build"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      input_artifacts  = ["source_output"]
      output_artifacts = ["build_output"]
      version          = "1"

      configuration = {
        ProjectName = aws_codebuild_project.codebuild_project.id
      }

      run_order = 2
    }
  }

  stage {
    name = "Deploy"

    action {
      name            = "Deploy"
      category        = "Deploy"
      owner           = "AWS"
      provider        = "CloudFormation"
      input_artifacts = ["build_output"]
      version         = "1"

      configuration = {
        ActionMode     = "CREATE_UPDATE"
        RoleArn        = aws_iam_role.cloudformation_role.arn
        Capabilities   = "CAPABILITY_IAM,CAPABILITY_NAMED_IAM"
        StackName      = "${var.project}-ecs-fargate-${var.app_name}"
        TemplatePath   = "build_output::aws/app.yml"
        TemplateConfiguration = "build_output::params.json"
      }
      run_order = 3
    }
  }

}

