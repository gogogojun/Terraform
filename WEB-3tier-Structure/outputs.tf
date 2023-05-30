output "db_dns_name" {
  description = "db_dns_name"
  value = aws_lb.myALB.dns_name
}