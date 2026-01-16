output "service_requests_table_name" {
  value = aws_dynamodb_table.service_requests.name
}

output "service_requests_table_arn" {
  value = aws_dynamodb_table.service_requests.arn
}

output "service_requests_stream_arn" {
  value = aws_dynamodb_table.service_requests.stream_arn
}

output "service_requests_created_at_gsi_name" {
  value = "gsi-tenantId-createdAt"
}

output "idempotency_table_name" {
  value = aws_dynamodb_table.idempotency.name
}

output "idempotency_table_arn" {
  value = aws_dynamodb_table.idempotency.arn
}