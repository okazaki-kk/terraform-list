resource "aws_cloudfront_origin_access_control" "main" {
  name                              = aws_s3_bucket.bucket1.bucket_regional_domain_name
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

resource "aws_cloudfront_distribution" "main" {
  default_root_object = "index.html"
  enabled             = true

  origin {
    domain_name              = aws_s3_bucket.bucket1.bucket_regional_domain_name
    origin_id                = aws_s3_bucket.bucket1.bucket_regional_domain_name
    origin_access_control_id = aws_cloudfront_origin_access_control.main.id
  }

  origin {
    domain_name              = aws_s3_bucket.bucket2.bucket_regional_domain_name
    origin_id                = aws_s3_bucket.bucket2.bucket_regional_domain_name
    origin_access_control_id = aws_cloudfront_origin_access_control.main.id
  }

  default_cache_behavior {
    allowed_methods        = ["GET", "HEAD"]
    cached_methods         = ["GET", "HEAD"]
    target_origin_id       = aws_s3_bucket.bucket1.bucket_regional_domain_name
    viewer_protocol_policy = "allow-all"

    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }
  }

  ordered_cache_behavior {
    allowed_methods        = ["GET", "HEAD"]
    cached_methods         = ["GET", "HEAD"]
    target_origin_id       = aws_s3_bucket.bucket2.bucket_regional_domain_name
    cache_policy_id        = "658327ea-f89d-4fab-a63d-7e88639e58f6"
    path_pattern           = "/*.png"
    viewer_protocol_policy = "allow-all"
    compress               = true
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }
}
