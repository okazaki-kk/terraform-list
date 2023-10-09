resource "aws_cloudfront_origin_access_control" "main" {
  name                              = aws_s3_bucket.sutekaku-meiyo.bucket_regional_domain_name
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

resource "aws_cloudfront_distribution" "main" {
  default_root_object = "index.html"
  is_ipv6_enabled     = true
  enabled             = true

  origin {
    domain_name              = aws_s3_bucket.sutekaku-meiyo.bucket_regional_domain_name
    origin_id                = aws_s3_bucket.sutekaku-meiyo.bucket_regional_domain_name
    origin_access_control_id = aws_cloudfront_origin_access_control.main.id
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  default_cache_behavior {
    allowed_methods        = ["GET", "HEAD"]
    cached_methods         = ["GET", "HEAD"]
    compress               = true
    target_origin_id       = aws_s3_bucket.sutekaku-meiyo.bucket_regional_domain_name
    viewer_protocol_policy = "allow-all"


    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }
}
