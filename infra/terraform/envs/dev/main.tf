module "dynamodb" {
  source = "../../modules/dynamodb_service_requests"

  project_name                = var.project_name
  env                         = var.env
  deletion_protection_enabled = var.deletion_protection_enabled
}