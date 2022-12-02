data "aws_availability_zones" "available" {
  state = "available"
}

locals {
  cidr_block = "172.${var.second_octet}.0.0/16"
  name = ["app", "rds", "monitoring"]
  private_subnets = ["172.${var.second_octet}.1.0/24", "172.${var.second_octet}.2.0/24", "172.${var.second_octet}.3.0/24"]
  public_subnets = ["172.${var.second_octet}.11.0/24", "172.${var.second_octet}.12.0/24", "172.${var.second_octet}.13.0/24"]
}

#
# VPC resources
#
resource "aws_vpc" "default" {
  cidr_block           = local.cidr_block
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = merge(
    {
      Name        = format("%s-%s", var.name, var.environment)
      Environment = var.environment,
      Terraform   = "true"
    },
    var.tags
  )
}

resource "aws_internet_gateway" "default" {
  vpc_id = aws_vpc.default.id

  tags = merge(
    {
      Name        = format("%s-%s-gwInternet", var.name, var.environment)
      Environment = var.environment,
      Terraform   = "true"
    },
    var.tags
  )
}

resource "aws_route_table" "private" {
  count = length(local.private_subnets) > 0 ? 1: 0

  vpc_id = aws_vpc.default.id

  tags = merge(
    {
      Name        = format("%s-%s-PrivateRouteTable", var.name, var.environment)
      Environment = var.environment
      Terraform   = "true"
    },
    var.tags
  )
}

resource "aws_route" "private" {
  route_table_id         = aws_route_table.private[0].id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.default[0].id
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.default.id

  tags = merge(
    {
      Name        = format("%s-%s-PublicRouteTable", var.name, var.environment),
      Environment = var.environment,
      Terraform   = "true"
    },
    var.tags
  )
}

resource "aws_route" "public" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.default.id
}

resource "aws_subnet" "private" {
  count = length(data.aws_availability_zones.available.names) < 3 ? length(data.aws_availability_zones.available.names) : 3
  vpc_id            = aws_vpc.default.id
  cidr_block        = local.private_subnets[count.index]
  availability_zone = data.aws_availability_zones.available.names[count.index]

  tags = merge(
    {
      Name        = format("%s-%s-%s-PrivateSubnet", var.name, var.environment, local.name[count.index]),
      Environment = var.environment,
      Terraform   = "true",
      type        = "private"
    },
    var.tags
  )
}

resource "aws_subnet" "public" {
  count = length(data.aws_availability_zones.available.names) < 3 ? length(data.aws_availability_zones.available.names) : 3
  vpc_id                  = aws_vpc.default.id
  cidr_block              = local.public_subnets[count.index]
  availability_zone = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = true

  tags = merge(
    {
      Name        = format("%s-%s-%s-PublicSubnet", var.name, var.environment, local.name[count.index]),
      Environment = var.environment,
      Terraform   = "true",
      type        = "public"
    },
    var.tags
  )
}

resource "aws_route_table_association" "private" {
  count = length(data.aws_availability_zones.available.names) < 3 ? length(data.aws_availability_zones.available.names) : 3

  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private[0].id
}

resource "aws_route_table_association" "public" {
  count = length(data.aws_availability_zones.available.names) < 3 ? length(data.aws_availability_zones.available.names) : 3
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

#
# NAT resources
#
resource "aws_eip" "nat" {
  count = length(local.public_subnets) > 0 ? 1: 0

  vpc = true
}

resource "aws_nat_gateway" "default" {
  depends_on = [aws_internet_gateway.default]

  count = length(local.public_subnets) > 0 ? 1: 0

  allocation_id = aws_eip.nat[0].id
  subnet_id     = aws_subnet.public[0].id

  tags = merge(
    {
      Name        = format("%s-%s-gwNAT", var.name, var.environment),
      Environment = var.environment,
      Terraform   = "true"
    },
    var.tags
  )
}

resource "aws_route53_zone_association" "secondary" {
  zone_id = var.zone_id
  vpc_id  = aws_vpc.default.id
}