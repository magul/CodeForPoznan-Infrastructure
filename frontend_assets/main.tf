variable name {
  type = string
}

variable s3_bucket { }
variable iam_user { }

resource "aws_s3_bucket_object" "bucket_object" {
  bucket = var.s3_bucket.id
  key    = "${var.name}/"

  depends_on = [
    var.s3_bucket,
  ]
}

resource "aws_iam_policy" "policy" {
  name   = "${var.name}_frontend_assets"

  policy = <<POLICY
{
  "Version":"2012-10-17",
  "Statement":[{
    "Sid":"${replace(title(replace(var.name, "/[\\._]/", " ")), " ", "")}S3",
    "Effect":"Allow",
    "Action":["s3:DeleteObject", "s3:PutObject"],
    "Resource":["${var.s3_bucket.arn}/${aws_s3_bucket_object.bucket_object.key}*"]
  }]
}
  POLICY

  depends_on = [
    aws_s3_bucket_object.bucket_object,
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
