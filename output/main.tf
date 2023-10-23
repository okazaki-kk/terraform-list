terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.67.0"
    }
  }
}

# デフォルトのプロバイダー設定
provider "aws" {
  region = "ap-northeast-1"
}

# CloudFront向けのプロバイダー設定
provider "aws" {
  alias  = "us_east_1"
  region = "us-east-1"
}
