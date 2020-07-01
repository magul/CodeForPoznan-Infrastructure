variable name {
  type = string
}

resource "aws_iam_user" "user" {
  name = var.name
}

resource "aws_iam_access_key" "access_key" {
  user = aws_iam_user.user.name
}

output "user" {
  value = aws_iam_user.user
}
