output "public_ip" {
  value = aws_instance.example.public_ip
  description = "EC2 Public IP"
}
