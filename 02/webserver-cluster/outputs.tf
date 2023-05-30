output "alb_dns_name" {
  description = "ALB DNS Name"
  value       = "http://${aws_lb.example.dns_name}"
}