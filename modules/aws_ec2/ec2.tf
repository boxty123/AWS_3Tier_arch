data "aws_ami" "al2" {
  most_recent = true
  owners      = ["137112412989"] # Amazon

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_instance" "this" {
  ami                         = data.aws_ami.al2.id
  instance_type               = var.instance_type
  subnet_id                   = var.subnet_id

  vpc_security_group_ids      = var.security_group_ids
  associate_public_ip_address = var.associate_public_ip

  iam_instance_profile = var.instance_profile != "" ? var.instance_profile : null

  tags = merge(
    { Name = var.instance_name },
    var.tags
  )
}
