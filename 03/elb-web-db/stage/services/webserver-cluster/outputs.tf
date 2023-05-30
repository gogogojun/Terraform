output "alb_dns_name" {
  description = "ALB DNS name"
  value       = "http://${aws_lb.myALB.dns_name}"
}