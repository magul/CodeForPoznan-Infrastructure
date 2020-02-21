variable name {
  type = string
}

resource "aws_iam_user" "user" {
  name = var.name
}

resource "aws_iam_access_key" "access_key" {
  user = aws_iam_user.user.name
}

resource "aws_iam_user_policy_attachment" "policy_attachment" {
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
  user       = aws_iam_user.user.name
}
