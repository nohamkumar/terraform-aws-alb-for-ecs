data "aws_elb_service_account" "default" {}

data "aws_iam_policy_document" "lb_logs_access_policy_document" {
  version = "2012-10-17"
  statement {
    effect = "Allow"

    principals {
      type        = "AWS"
      identifiers = [data.aws_elb_service_account.default.arn]
    }

    actions = [
      "s3:PutObject",
    ]

    resources = [
      "${aws_s3_bucket.alb_logs.arn}/*",
    ]
  }
}

resource "aws_s3_bucket_policy" "lb_logs_access_policy" {
  bucket = aws_s3_bucket.alb_logs.id
  policy = data.aws_iam_policy_document.lb_logs_access_policy_document.json
}
