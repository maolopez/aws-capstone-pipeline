provider "aws" {
  region = "us-east-1"
}

data "aws_partition" "current" {}

data "aws_region" "current" {}

data "aws_caller_identity" "current" {}

locals {
  project_name = "SimplePythonBuildProject"
}

resource "aws_iam_role" "code_build_role" {
  name = "CodeBuildRole"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = { Service = "codebuild.amazonaws.com" }
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_policy" "code_build_default_policy" {
  name   = "CodeBuildDefaultPolicy"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = ["logs:CreateLogGroup", "logs:CreateLogStream", "logs:PutLogEvents"]
        Resource = [
          "arn:${data.aws_partition.current.partition}:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:log-group:/aws/codebuild/${local.project_name}*"
        ]
      },
      {
        Effect = "Allow"
        Action = ["codebuild:BatchPutCodeCoverages", "codebuild:BatchPutTestCases", "codebuild:CreateReport", "codebuild:CreateReportGroup", "codebuild:UpdateReport"]
        Resource = "arn:${data.aws_partition.current.partition}:codebuild:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:report-group/${local.project_name}-*"
      },
      {
        Effect = "Allow"
        Action = ["s3:GetBucket*", "s3:GetObject*", "s3:List*"]
        Resource = "${aws_s3_bucket.code_pipeline_artifacts_bucket.arn}/*"
      }
    ]
  })
  roles = [aws_iam_role.code_build_role.name]
}

resource "aws_codebuild_project" "code_build_project" {
  name          = "${local.project_name}"
  description   = "Build python source code"
  service_role  = aws_iam_role.code_build_role.arn
  artifacts     = { type = "NO_ARTIFACTS" }
  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "aws/codebuild/amazonlinux2-x86_64-standard:5.0"
    type                        = "LINUX_CONTAINER"
    image_pull_credentials_type = "CODEBUILD"
    privileged_mode             = false
  }
  source {
    type     = "NO_SOURCE"
    buildspec = var.ci_code_build_spec
  }
  cache {
    type = "NO_CACHE"
  }
  encryption_key = "alias/aws/s3"
}

resource "aws_s3_bucket" "code_pipeline_artifacts_bucket" {
  bucket = "code-pipeline-artifacts-bucket"

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "aws:kms"
      }
    }
  }

  versioning {
    enabled = false
  }

  lifecycle_rule {
    enabled = true
    noncurrent_version_expiration {
      days = 30
    }
  }
}

resource "aws_s3_bucket_public_access_block" "code_pipeline_artifacts_bucket_policy" {
  bucket = aws_s3_bucket.code_pipeline_artifacts_bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_iam_role" "code_pipeline_role" {
  name = "CodePipelineRole"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = { Service = "codepipeline.amazonaws.com" }
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_policy" "code_pipeline_default_policy" {
  name   = "CodePipelineDefaultPolicy"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = ["s3:*"]
        Resource = ["${aws_s3_bucket.code_pipeline_artifacts_bucket.arn}/*"]
        Condition = {
          Bool = {
            "aws:SecureTransport" = "false"
          }
        }
      },
      {
        Effect   = "Allow"
        Action   = ["sts:AssumeRole"]
        Resource = ["*"]
      },
      {
        Effect   = "Allow"
        Action   = ["logs:CreateLogGroup", "logs:CreateLogStream", "logs:PutLogEvents"]
        Resource = ["arn:${data.aws_partition.current.partition}:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:log-group:/aws/codepipeline/${var.code_pipeline_name}*"]
      },
      {
        Effect   = "Allow"
        Action   = ["inspector-scan:ScanSbom"]
        Resource = "*"
      }
    ]
  })
  roles = [aws_iam_role.code_pipeline_role.name]
}

resource "aws_codepipeline" "pipeline" {
  name     = var.code_pipeline_name
  role_arn = aws_iam_role.code_pipeline_role.arn

  artifact_store {
    location = aws_s3_bucket.code_pipeline_artifacts_bucket.id
    type     = "S3"
  }

  stage {
    name = "Source"

    action {
      name             = "CodeConnections"
      category         = "Source"
      owner            = "AWS"
      provider         = "CodeStarSourceConnection"
      version          = "1"
      output_artifacts = ["SourceOutput"]
      configuration = {
        ConnectionArn   = var.connection_arn
        FullRepositoryId = var.full_repository_id
        BranchName      = var.branch_name
      }
    }
  }

  stage {
    name = "PythonBuild"

    action {
      name             = "CI_Python_Build"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      version          = "1"
      input_artifacts  = ["SourceOutput"]
      output_artifacts  = ["SourceOutput2"]
      configuration = {
        ProjectName = aws_codebuild_project.code_build_project.name
      }
    }
  }

  stage {
    name = "push-to-ecr"

    action {
      name             = "push-to-ecr"
      category         = "Source"
      owner            = "AWS"
      provider         = "ECR"
      version          = "1"
      input_artifacts  = ["SourceOutput2"]
      configuration = {
        RepositoryName = var.ecr_repo_name  # coming from Module ECR
      }
    }
  }
}