resource "aws_s3_bucket" "static_content" {
  bucket        = "iu-static-content"
  force_destroy = true
}

resource "aws_s3_bucket_cors_configuration" "static_content_cors" {
  bucket = aws_s3_bucket.static_content.id

  cors_rule {
    allowed_methods = ["GET", "HEAD"]
    allowed_origins = ["*"]
    allowed_headers = ["*"]
    max_age_seconds = 3000
  }
}

resource "aws_s3_bucket_website_configuration" "static_content_website" {
  bucket = aws_s3_bucket.static_content.id

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "error.html"
  }
}

resource "aws_cloudfront_origin_access_identity" "cloudfront_oai" {
  comment = "OAI for S3 bucket access"
}

resource "aws_s3_bucket_policy" "bucket_policy" {
  bucket = aws_s3_bucket.static_content.id
  policy = jsonencode({
    Version   = "2012-10-17"
    Statement = [
      {
        Effect    = "Allow"
        Principal = { AWS = aws_cloudfront_origin_access_identity.cloudfront_oai.iam_arn }
        Action    = "s3:GetObject"
        Resource  = "${aws_s3_bucket.static_content.arn}/*"
      }
    ]
  })
}

resource "aws_lb" "web_app_lb" {
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.web_app_sg.id]
  subnets            = local.subnet_ids
}

resource "aws_lb_target_group" "web_app_tg" {
  port        = 80
  protocol    = "HTTP"
  vpc_id      = aws_vpc.default_vpc.id
  target_type = "instance"
  
  health_check {
    path                = "/"
    protocol            = "HTTP"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
}

resource "aws_lb_listener" "http_listener" {
  load_balancer_arn = aws_lb.web_app_lb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.web_app_tg.arn
  }
}

resource "aws_launch_template" "app_lt" {
  name          = "app1-template"
  instance_type = "t2.micro"
  image_id      = "ami-00dc61b35bec09b72"

  block_device_mappings {
    device_name = "/dev/xvda"
    ebs {
      delete_on_termination = true
      volume_size           = 8
    }
  }

  network_interfaces {
    security_groups = [aws_security_group.web_app_sg.id]
  }

  user_data = filebase64("hello-world.sh")
}

resource "aws_autoscaling_group" "web_app_asg" {
  desired_capacity    = 1
  max_size            = 1
  min_size            = 1
  vpc_zone_identifier = local.subnet_ids
  target_group_arns   = [aws_lb_target_group.web_app_tg.arn]

  launch_template {
    id      = aws_launch_template.app_lt.id
    version = "$Latest"
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_cloudfront_distribution" "cdn" {
  enabled = true

  origin {
    domain_name = aws_s3_bucket.static_content.bucket_regional_domain_name
    origin_id   = "S3-origin"

    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.cloudfront_oai.cloudfront_access_identity_path
    }
  }

  origin {
    domain_name = aws_lb.web_app_lb.dns_name
    origin_id   = "ELB-origin"

    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "http-only"
      origin_ssl_protocols   = ["TLSv1.2"]
    }
  }

  default_cache_behavior {
    target_origin_id       = "S3-origin"
    viewer_protocol_policy = "allow-all"
    allowed_methods        = ["GET", "HEAD"]
    cached_methods         = ["GET", "HEAD"]

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

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }
}
