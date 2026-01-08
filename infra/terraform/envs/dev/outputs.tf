output "service_requests_table_name" {
  value = module.dynamodb.service_requests_table_name
}

output "idempotency_table_name" {
  value = module.dynamodb.idempotency_table_name
}