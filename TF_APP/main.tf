resource "random_string" "suffix" {
  length  = 5
  special = false
  upper   = false
}

module "my_ecr" {
  source        = "../TF_modules/ECR/"
  ecr_repo_name = local.ecr_repo_name # 'must satisfy regular expression '(?:[a-z0-9]+(?:[._-][a-z0-9]+)*/)*[a-z0-9]+(?:[._-][a-z0-9]+)*''
  scan_on_push  = local.scan_on_push

}

module "my_pipeline" {
  source             = "../TF_modules/Pipeline/"
  region             = local.region
  ecr_repo_name      = local.ecr_repo_name
  branch_name        = local.branch_name
  code_pipeline_name = local.code_pipeline_name
  code_build_name    = local.code_build_name
  connection_arn     = "arn:aws:codeconnections:${local.region}:${local.awsaccount}:connection/ff446428-36cc-45fe-af21-6a952bf60cf8" # Developer Tools/Settings/Connections
  full_repository_id = local.full_repository_id                                                                                      # This targets you App's source repo"

}

