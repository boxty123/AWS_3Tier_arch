output "role_name" {
  value       = aws_iam_role.this.name
  description = "생성된 IAM Role 이름"
}

output "role_arn" {
  value       = aws_iam_role.this.arn
  description = "생성된 IAM Role ARN"
}

output "instance_profile_name" {
  value       = aws_iam_instance_profile.this.name
  description = "생성된 Instance Profile 이름"
}

output "instance_profile_arn" {
  value       = aws_iam_instance_profile.this.arn
  description = "생성된 Instance Profile ARN"
}
