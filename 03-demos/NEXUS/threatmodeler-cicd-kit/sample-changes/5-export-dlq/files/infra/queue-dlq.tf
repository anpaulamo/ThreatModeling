# Export jobs that fail five times go to a dead-letter queue for inspection.
resource "aws_sqs_queue" "export_jobs_dlq" {
  name                              = "ledgerlite-export-jobs-dlq"
  kms_master_key_id                 = aws_kms_key.data.arn
  kms_data_key_reuse_period_seconds = 300
  message_retention_seconds         = 1209600
}

resource "aws_sqs_queue_redrive_policy" "export_jobs" {
  queue_url = aws_sqs_queue.export_jobs.id
  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.export_jobs_dlq.arn
    maxReceiveCount     = 5
  })
}
