resource "aws_eip" "nat" {
  domain = "vpc" 

  tags = merge(
    {
      Name = "${var.project_name}-${var.environment}-nat-eip"
    },
    var.tags
  )
}
