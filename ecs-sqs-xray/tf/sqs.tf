resource "aws_sqs_queue" "demo_queue" {
  name                        = "demo.fifo"
  fifo_queue                  = true
  content_based_deduplication = true
}