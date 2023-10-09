resource "aws_s3_bucket" "sutekaku-meiyo" {
  bucket = "sutekaku-meiyo"
}

# バケットポリシー
resource "aws_s3_bucket_policy" "static_content_bucket_policy" {
  bucket = aws_s3_bucket.sutekaku-meiyo.id
  policy = data.aws_iam_policy_document.s3_static_content_policy.json
}

data "aws_iam_policy_document" "s3_static_content_policy" {
  statement {
    principals {
      type        = "Service"
      identifiers = ["cloudfront.amazonaws.com"]
    }
    condition {
      test     = "StringEquals"
      variable = "aws:SourceArn"
      values   = [aws_cloudfront_distribution.main.arn]
    }
    actions   = ["s3:GetObject"]
    resources = ["${aws_s3_bucket.sutekaku-meiyo.arn}/*"]
  }
}
