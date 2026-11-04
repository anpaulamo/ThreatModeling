# Redis cache for invoice list responses and session data.
resource "aws_security_group" "cache" {
  name        = "ledgerlite-cache"
  description = "Redis; reachable only from API tasks"
  vpc_id      = aws_vpc.main.id

  ingress {
    description     = "Redis from API tasks"
    from_port       = 6379
    to_port         = 6379
    protocol        = "tcp"
    security_groups = [aws_security_group.app.id]
  }
}

resource "aws_elasticache_subnet_group" "main" {
  name       = "ledgerlite-cache"
  subnet_ids = aws_subnet.private[*].id
}

resource "aws_elasticache_replication_group" "main" {
  replication_group_id       = "ledgerlite-cache"
  description                = "LedgerLite invoice and session cache"
  engine                     = "redis"
  engine_version             = "7.1"
  node_type                  = "cache.t4g.small"
  num_cache_clusters         = 2
  automatic_failover_enabled = true
  subnet_group_name          = aws_elasticache_subnet_group.main.name
  security_group_ids         = [aws_security_group.cache.id]
  at_rest_encryption_enabled = true
  transit_encryption_enabled = true
}
