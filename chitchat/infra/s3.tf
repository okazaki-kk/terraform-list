resource "aws_s3_bucket" "alb_logs" {
  bucket = "${local.name}-alb-logs"
}

resource "aws_s3_bucket_policy" "aws-logs" {
  bucket = aws_s3_bucket.alb_logs.id
  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "AWS": "arn:aws:iam::582318560864:root"
      },
      "Action": "s3:PutObject",
      "Resource": "arn:aws:s3:::chitchat-alb-logs/*"
    }
  ]
}
POLICY
}
