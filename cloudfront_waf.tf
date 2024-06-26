resource "aws_cloudfront_distribution" "cf_distribution" {
  origin {
    domain_name = aws_lb.app_lb.dns_name   # origin domain name is set to the DNS name of the ALB
    origin_id   = "alb-origin"

    # Configure custom origin settings for the ALB
    custom_origin_config {
      http_port              = 80                   # HTTP port used to connect to the origin
      https_port             = 443                  # HTTPS port used to connect to the origin
      origin_protocol_policy = "http-only"          # only allow HTTP communication with the origin
      origin_ssl_protocols   = ["TLSv1.2"]          # SSL protocols used for communication with the origin
    }
  }

  web_acl_id           = aws_wafv2_web_acl.web_acl.arn  # attach the WAFv2 web ACL to the cloudFront distribution

  enabled              = true               # enable the cloudFront distribution
  is_ipv6_enabled      = true               # enable IPv6 support for the distribution
  default_root_object  = "index.html"       # default object use when no path is specified

  # Configure default cache behavior for requests
  default_cache_behavior {
    target_origin_id        = "alb-origin"   # use the ALB-origin as the target for requests

    viewer_protocol_policy  = "redirect-to-https"  # redirect HTTP to HTTPS for viewer requests
    allowed_methods         = ["GET", "HEAD", "OPTIONS"]  # allow these HTTP methods
    cached_methods          = ["GET", "HEAD", "OPTIONS"]  # cache responses for these HTTP methods

    forwarded_values {
      query_string = false   # do not include query strings in cache key

      cookies {
        forward = "none"     # do not forward cookies to the origin
      }
    }
  }

  # configure restrictions such as geo-restrictions
  restrictions {
    geo_restriction {
      restriction_type = "none"   # no geo-restrictions applied
    }
  }

  # configure the viewer certificate for HTTPS communication
  viewer_certificate {
    cloudfront_default_certificate = true
  }
}

# AWS WAFv2 Web ACL configuration
resource "aws_wafv2_web_acl" "web_acl" {
  name        = "web-acl"
  description = "web ACL to protect my cloudfront distribution"
  scope       = "CLOUDFRONT"                   # scope of the web ACL (CLOUDFRONT for CloudFront distributions)

  # define default action for requests that do not match any rule
  default_action {
    allow {}
  }

  # configure visibility settings for the web ACL
  visibility_config {
    cloudwatch_metrics_enabled = true    # enable CloudWatch metrics for the web ACL
    sampled_requests_enabled   = true    # enable sampling of requests for the web ACL
    metric_name                = "WebACL"
  }
}
