output "allocation_id"{
    value = aws_eip.nat.id
}

output "public_ip"{
    value=aws_eip.nat.public_ip
}