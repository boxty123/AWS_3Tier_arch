output "instance_ids" {
  value = { for k, i in aws_instance.this : k => i.id }
}

output "private_ips" {
  value = { for k, i in aws_instance.this : k => i.private_ip }
}

output "public_ips" {
  value = { for k, i in aws_instance.this : k => try(i.public_ip, null) }
}
