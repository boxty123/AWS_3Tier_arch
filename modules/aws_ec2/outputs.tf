output "instance_ids"{
    value=  {for k,i in aws_instance.this: k=>i.id}
}

output "private_ips"{
    value=  {for k,i in aws_instance.this: k=>i.private_ips}
}

output "public_ips"{
    value=  {for k,i in aws_instance.this: k=>i.public_ips}
}