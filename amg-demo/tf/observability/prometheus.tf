resource "aws_cloudwatch_log_group" "prom_log" {
  name = "${var.cluster_name}_prom_log"
}

resource "aws_prometheus_workspace" "prom" {
  alias = "grafana-demo"
  logging_configuration {
    log_group_arn = "${aws_cloudwatch_log_group.prom_log.arn}:*"
  }
}

