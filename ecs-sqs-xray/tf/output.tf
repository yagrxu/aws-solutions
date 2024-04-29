output "role_arn" {
  value = aws_iam_role.adot_role.arn
}

output "cluster_name" {
  value = var.cluster_name
}