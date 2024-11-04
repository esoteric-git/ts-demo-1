output "vm1_public_ip" {
  description = "Public IP of vm-1 (Subnet Router)"
  value       = aws_instance.vm1.public_ip
}

output "vm2_private_ip" {
  description = "Private IP of vm-2"
  value       = aws_instance.vm2.private_ip
} 