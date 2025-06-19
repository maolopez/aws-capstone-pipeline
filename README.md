aws capstone pipeline
=====================

Minimal deployment of  AWS CodePipeline and ECR with terraform by using only required parameters.

Assumptions
-----
1- You have AWS credentials

2- You have a AWS Linux Instance set up to deploy: Git, Terraform, AWS creds, kubectl, helm, docker, eksctl, nvm, npm, etc

3- For the deployer use "ami-0e449927258d45bc4"

4- You have an existing "default" VPC provided by your AWS account.

5- The App repository has an buildspec.yml file like for example https://github.com/maolopez/ut_anagramma/blob/develop/buildspec.yml

6- You may need AWS GitHub App:
   A- On Github go to settings -> integrations (Click on applications)
   B- On AWS go to Developer Tools and then Connections. (Create a connection) This should be reflected in (A)
   C- You may need to edit your terraform created pipeline to hook the connection.


General description
-----


|*instance to use*   |*Description*                                                           |
|:------------------:|:----------------------------------------------------------------------:|
|kubernetes-deployer |20 points Create and configure your deployment environment              |
|ECR                 |20 points – Containerize and store your images in a repository          |
|kubernetes-cluster  |40 points – Deploy your application, including a backend database       |
|kubernetes-cluster  |10 points – Test updating your application using rolling updates        |


INSTRUCTIONS
------------------

cd aws-capstone-kubernetes/TF_APP/

Add a terraform.tfvars file here

terraform init

terraform validate

terraform plan

terraform apply --auto-approve


REFERENCES
-----

https://github.com/maolopez/ut_anagramma

https://github.com/maolopez/aws-capstone-kubernetes
