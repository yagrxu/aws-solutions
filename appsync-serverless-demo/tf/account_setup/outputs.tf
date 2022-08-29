output role_arn {
  value = aws_iam_role.tf_role.arn
}

output access_key_id {
  value = aws_iam_access_key.ak.id
}

output access_key_secret {
  value = aws_iam_access_key.ak.secret
}
