module "my_ecr" {
  source = "../TF_modules/ECR/"
  ecr_repo_name = "ut_anagramma"
  scan_on_push = false

}

module "my_pipeline" {
  source = "../TF_modules/Pipeline/"
  ecr_repo_name = "ut_anagramma"
  branch_name = "develop"
  code_pipeline_name = "ut_anagramma"

}