resource "aws_s3_bucket" "bucket1" {
  bucket = "haikyu-bucket1"
}

resource "aws_s3_bucket" "bucket2" {
  bucket = "haikyu-bucket2"
}

resource "aws_s3_bucket_policy" "bucket1" {
  bucket = aws_s3_bucket.bucket1.bucket
  policy = data.aws_iam_policy_document.cloudfront1.json
}

resource "aws_s3_bucket_policy" "bucket2" {
  bucket = aws_s3_bucket.bucket2.bucket
  policy = data.aws_iam_policy_document.cloudfront2.json
}

data "aws_iam_policy_document" "cloudfront1" {
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
    actions = ["s3:GetObject"]
    resources = [
      "${aws_s3_bucket.bucket1.arn}/*",
    ]
  }
}

data "aws_iam_policy_document" "cloudfront2" {
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
    actions = ["s3:GetObject"]
    resources = [
      "${aws_s3_bucket.bucket2.arn}/*",
    ]
  }
}
