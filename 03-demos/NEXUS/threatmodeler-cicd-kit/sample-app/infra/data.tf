# Customer-managed key used for every data store in this stack.
resource "aws_kms_key" "data" {
  description             = "LedgerLite data-at-rest key"
  enable_key_rotation     = true
  deletion_window_in_days = 30
}

resource "aws_kms_alias" "data" {
  name          = "alias/ledgerlite-data"
  target_key_id = aws_kms_key.data.key_id
}

# --- Postgres: invoices, customers, payments -------------------------------

resource "random_password" "db" {
  length  = 32
  special = false
}

resource "aws_secretsmanager_secret" "db" {
  name       = "ledgerlite/db-credentials"
  kms_key_id = aws_kms_key.data.arn
}

resource "aws_secretsmanager_secret_version" "db" {
  secret_id = aws_secretsmanager_secret.db.id
  secret_string = jsonencode({
    username = "ledgerlite"
    password = random_password.db.result
  })
}

resource "aws_db_subnet_group" "main" {
  name       = "ledgerlite-db"
  subnet_ids = aws_subnet.private[*].id
}

resource "aws_db_instance" "main" {
  identifier                  = "ledgerlite-db"
  engine                      = "postgres"
  engine_version              = "16.3"
  instance_class              = "db.t4g.medium"
  allocated_storage           = 50
  db_name                     = "ledgerlite"
  username                    = "ledgerlite"
  password                    = random_password.db.result
  db_subnet_group_name        = aws_db_subnet_group.main.name
  vpc_security_group_ids      = [aws_security_group.db.id]
  publicly_accessible         = false
  storage_encrypted           = true
  kms_key_id                  = aws_kms_key.data.arn
  backup_retention_period     = 7
  deletion_protection         = true
  iam_database_authentication_enabled = true
  skip_final_snapshot         = false
  final_snapshot_identifier   = "ledgerlite-db-final"
}

# --- S3: generated invoice PDFs --------------------------------------------

resource "aws_s3_bucket" "invoices" {
  bucket_prefix = "ledgerlite-invoices-"
}

resource "aws_s3_bucket_public_access_block" "invoices" {
  bucket                  = aws_s3_bucket.invoices.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "invoices" {
  bucket = aws_s3_bucket.invoices.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "aws:kms"
      kms_master_key_id = aws_kms_key.data.arn
    }
    bucket_key_enabled = true
  }
}

resource "aws_s3_bucket_versioning" "invoices" {
  bucket = aws_s3_bucket.invoices.id

  versioning_configuration {
    status = "Enabled"
  }
}
