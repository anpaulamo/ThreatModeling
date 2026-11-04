output "alb_dns_name" {
  value = aws_lb.public.dns_name
}

output "invoice_bucket" {
  value = aws_s3_bucket.invoices.bucket
}
