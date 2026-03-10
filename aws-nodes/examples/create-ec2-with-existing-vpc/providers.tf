terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.45.0"
    }
    assert = {
      source  = "bwoznicki/assert"
      version = "0.0.1"
    }
  }
  required_version = ">= 1.5.0"
}