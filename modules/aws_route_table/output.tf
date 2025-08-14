output "public_route_table_id" {
  description = "Public route table ID (public 모드일 때만 유효)"
  value       = try(aws_route_table.public["public"].id, null)
}

output "private_route_table_ids" {
  description = "AZ 인덱스별 Private route table IDs (private 모드일 때만 유효)"
  value = {
    for k, rt in aws_route_table.private :
    k => rt.id
  }
}
