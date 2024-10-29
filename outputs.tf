output "load_balancer_url" {
  value = aws_lb.web_app_lb.dns_name
}
