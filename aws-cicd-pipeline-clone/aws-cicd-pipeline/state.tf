terraform {
  backend "s3" {
    bucket  = "gjh-aws-cicd-pipeline"
    encrypt = true
    key     = "terraform.tfstate"
    region  = "ap-northeast-2"
  }
}

provider "aws" {
  region = "ap-northeast-2"
}


