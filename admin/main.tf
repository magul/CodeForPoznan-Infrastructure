variable name {
  type = string
}

resource "aws_iam_user" "user" {
  name = var.name
}

resource "aws_iam_access_key" "access_key" {
  user = aws_iam_user.user.name
}

resource "aws_iam_policy_attachment" "policy_attachment" {
  name       = "AdministratorAccess"
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
  users      = [aws_iam_user.user.name]
}
