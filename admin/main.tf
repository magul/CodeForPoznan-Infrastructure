variable "name" {
  type = string
}
variable "public_key" {
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

resource "aws_key_pair" "key_pair" {
  key_name   = var.name
  public_key = var.public_key
}

output "public_key" {
  value = aws_key_pair.key_pair.public_key
}
