output "service_requests_table_name" {
  value = module.dynamodb.service_requests_table_name
}

output "service_requests_table_arn" {
  value = module.dynamodb.service_requests_table_arn
}

output "service_requests_stream_arn" {
  value = module.dynamodb.service_requests_stream_arn
}

output "service_requests_created_at_gsi_name" {
  value = module.dynamodb.service_requests_created_at_gsi_name
}


output "idempotency_table_name" {
  value = module.dynamodb.idempotency_table_name
}

output "idempotency_table_arn" {
  value = module.dynamodb.idempotency_table_arn
}