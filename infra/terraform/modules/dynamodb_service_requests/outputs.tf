output "service_requests_table_name" {
    value = aws_dynamodb_table.service_requests.name
}

output "idempotency_table_name" {
    value = aws_dynamodb_table.idempotency.name
}