output "instance_id" {
  value = aws_instance.nat.id
}

output "private_ip" {
  value = aws_instance.nat.private_ip
}
