variable "name" {
  type = string
}

variable "s3_bucket" {}
variable "iam_user" {}

resource "aws_s3_object" "object" {
  bucket = var.s3_bucket.id
  key    = "${var.name}/"

  depends_on = [
    var.s3_bucket,
  ]
}

data "aws_iam_policy_document" "policy" {
  version = "2012-10-17"

  statement {
    sid       = "${replace(title(replace(var.name, "/[\\._]/", " ")), " ", "")}S3"
    effect    = "Allow"
    actions   = ["s3:DeleteObject", "s3:PutObject"]
    resources = ["${var.s3_bucket.arn}/${aws_s3_object.object.key}*"]
  }
}

resource "aws_iam_policy" "policy" {
  name   = "${var.name}_frontend_assets"
  policy = data.aws_iam_policy_document.policy.json

  depends_on = [
    aws_s3_object.object,
  ]
}

resource "aws_iam_user_policy_attachment" "user_policy_attachment" {
  user       = var.iam_user.name
  policy_arn = aws_iam_policy.policy.arn

  depends_on = [
    aws_iam_policy.policy,
    var.iam_user,
  ]
}
