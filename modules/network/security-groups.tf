resource "aws_security_group" "allow_web" {
  name   = "allow_web_traffic"
  vpc_id = aws_vpc.main.id

  ingress {
    from_port   = 80
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = var.allow_ips
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = var.allow_ips
  }
}
