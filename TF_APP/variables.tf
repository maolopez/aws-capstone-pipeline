locals {
  region             = "us-east-1"
  project_name       = "test-${random_string.suffix.result}"
  awsaccount         = "271271282869"
  ecr_repo_name      = "test-component-${random_string.suffix.result}"
  scan_on_push       = false
  branch_name        = "develop"
  code_pipeline_name = "test-${random_string.suffix.result}"
  code_build_name    = "test-${random_string.suffix.result}"
  full_repository_id = "maolopez/ut-anagramma"
  codestarconnection = "codestarconn-${random_string.suffix.result}"
}

