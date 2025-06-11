output "code_build_project_name" {
  description = "The name of the CodeBuild project."
  value       = aws_codebuild_project.code_build_project.name
}

output "code_build_project_arn" {
  description = "The ARN of the CodeBuild project."
  value       = aws_codebuild_project.code_build_project.arn
}

output "code_pipeline_name" {
  description = "The name of the CodePipeline."
  value       = aws_codepipeline.pipeline.name
}

output "code_pipeline_arn" {
  description = "The ARN of the CodePipeline."
  value       = aws_codepipeline.pipeline.id
}

output "artifacts_bucket_name" {
  description = "The name of the S3 bucket used for artifact storage."
  value       = aws_s3_bucket.code_pipeline_artifacts_bucket.bucket
}

output "artifacts_bucket_arn" {
  description = "The ARN of the S3 bucket used for artifact storage."
  value       = aws_s3_bucket.code_pipeline_artifacts_bucket.arn
}

output "code_build_role_arn" {
  description = "The ARN of the CodeBuild IAM role."
  value       = aws_iam_role.code_build_role.arn
}

output "code_pipeline_role_arn" {
  description = "The ARN of the CodePipeline IAM role."
  value       = aws_iam_role.code_pipeline_role.arn
}