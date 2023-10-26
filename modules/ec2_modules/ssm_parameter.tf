

resource "aws_ssm_parameter" "ise_password" {
  name  = "ADMIN_PASSWORD"
  type  = "SecureString"
  value = var.password
}


resource "aws_ssm_parameter" "ise_ssm" {
  for_each = local.ise_ssm_full_map
  name     = each.key
  type     = "String"
  value    = each.value
}

resource "aws_ssm_parameter" "retry_count" {
  name  = "RETRY_COUNT" 
  type  = "String"  
  value = "0"  
}