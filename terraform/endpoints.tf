resource "aws_security_group" "vpce" {
  name        = "${var.project_name}-vpce-sg"
  description = "Allow HTTPS from spoke VPC to VPC interface endpoints"
  vpc_id      = aws_vpc.spoke.id

  tags = {
    Name = "${var.project_name}-vpce-sg"
  }
}

resource "aws_vpc_security_group_ingress_rule" "vpce_https" {
  security_group_id = aws_security_group.vpce.id

  description = "HTTPS from spoke VPC"

  cidr_ipv4   = var.vpc_cidr
  from_port   = 443
  to_port     = 443
  ip_protocol = "tcp"
}

resource "aws_vpc_security_group_egress_rule" "vpce_all" {
  security_group_id = aws_security_group.vpce.id

  description = "Allow endpoint responses"

  cidr_ipv4   = var.vpc_cidr
  ip_protocol = "-1"
}


resource "aws_vpc_endpoint" "interface" {
  for_each = local.interface_endpoints

  vpc_id = aws_vpc.spoke.id

  service_name = "com.amazonaws.${var.aws_region}.${each.key}"

  vpc_endpoint_type = "Interface"

  subnet_ids = [
    aws_subnet.private_a.id,
    aws_subnet.private_b.id
  ]

  security_group_ids = [
    aws_security_group.vpce.id
  ]

  private_dns_enabled = true

  tags = {
    Name    = "${var.project_name}-vpce-${replace(each.key, ".", "-")}"
    Service = each.key
    Type    = "Interface"
  }
}


resource "aws_vpc_endpoint" "s3" {
  vpc_id = aws_vpc.spoke.id

  service_name = "com.amazonaws.${var.aws_region}.s3"

  vpc_endpoint_type = "Gateway"

  route_table_ids = [
    aws_route_table.private_a.id,
    aws_route_table.private_b.id
  ]

  tags = {
    Name    = "${var.project_name}-vpce-s3"
    Service = "s3"
    Type    = "Gateway"
  }
}


  