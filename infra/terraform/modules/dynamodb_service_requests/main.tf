locals {
    name_prefix = "${var.project_name}-${var.env}"
}

resource "aws_dynamodb_table" "service_requests" {
    name = "${local.name_prefix}-service-requests"
    billing_mode = "PAY_PER_REQUEST"
    hash_key = "serviceRequestId"

    attribute {
        name = "serviceRequestId"
        type = "S"
    }
    
    point_in_time_recovery {
        enabled = true
    }

    deletion_protection_enabled = var.deletion_protection_enabled

    tags = {
        Project = var.project_name
        Env = var.env
        Domain = "service-requests"
    }
}

resource "aws_dynamodb_table" "idempotency" {
    name = "${local.name_prefix}-service-request-idempotency"
    billing_mode = "PAY_PER_REQUEST"
    hash_key = "idempotencyKey"

    attribute {
        name = "idempotencyKey"
        type = "S"
    }

    ttl {
        attribute_name = "expiresAt"
        enabled = true
    }

    point_in_time_recovery {
        enabled = true
    }

    deletion_protection_enabled = var.deletion_protection_enabled

    tags = {
        Project = var.project_name
        Env = var.env
        Domain = "service-requests"
    }
}
