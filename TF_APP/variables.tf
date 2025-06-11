variable "ecr_repo_name" {
  description = "The name of the repository on ECR"
  type        = string
}

variable "region" {
  type        = string
  description = "default region"
}

variable "ecr_repo_name" {
  description = "The name of the repository on ECR"
  type        = string
  default = ut_anagramma
}