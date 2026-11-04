# Invoice export jobs, processed asynchronously by the API service.
resource "aws_sqs_queue" "export_jobs" {
  name                              = "ledgerlite-export-jobs"
  kms_master_key_id                 = aws_kms_key.data.arn
  kms_data_key_reuse_period_seconds = 300
}

resource "aws_iam_role_policy" "task_sqs" {
  name = "ledgerlite-task-sqs"
  role = aws_iam_role.task.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect   = "Allow"
      Action   = ["sqs:SendMessage", "sqs:ReceiveMessage", "sqs:DeleteMessage"]
      Resource = aws_sqs_queue.export_jobs.arn
    }]
  })
}
