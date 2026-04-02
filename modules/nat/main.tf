data "aws_ami" "al2023" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_security_group" "nat" {
  name   = "nat-instance"
  vpc_id = var.vpc_id

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = var.allowed_cidrs
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, { Name = "nat-instance-sg" })
}

resource "aws_instance" "nat" {
  ami                    = data.aws_ami.al2023.id
  instance_type          = var.instance_type
  subnet_id              = var.public_subnet_id
  source_dest_check      = false
  vpc_security_group_ids = [aws_security_group.nat.id]

  user_data = <<-EOF
    #!/bin/bash
    echo "net.ipv4.ip_forward = 1" >> /etc/sysctl.d/custom.conf
    sysctl -p /etc/sysctl.d/custom.conf
    yum install -y iptables-services
    iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
    service iptables save
  EOF

  tags = merge(var.tags, { Name = "nat-instance" })
}

resource "aws_route_table" "private" {
  vpc_id = var.vpc_id

  route {
    cidr_block           = "0.0.0.0/0"
    network_interface_id = aws_instance.nat.primary_network_interface_id
  }

  tags = merge(var.tags, { Name = "private-rt" })
}

resource "aws_route_table_association" "private" {
  count          = length(var.private_subnet_ids)
  subnet_id      = var.private_subnet_ids[count.index]
  route_table_id = aws_route_table.private.id
}
