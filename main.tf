data "aws_availability_zones" "available" {
  state = "available"
}

locals {
  cidr_block = "172.${var.second_octet}.0.0/16"
  ap_private_subnets = ["172.${var.second_octet}.1.0/24", "172.${var.second_octet}.2.0/24", "172.${var.second_octet}.3.0/24"]
  rds_private_subnets = ["172.${var.second_octet}.11.0/24", "172.${var.second_octet}.12.0/24", "172.${var.second_octet}.13.0/24"]
  monitor_private_subnets = ["172.${var.second_octet}.21.0/24", "172.${var.second_octet}.22.0/24", "172.${var.second_octet}.23.0/24"]
  app_public_subnets = ["172.${var.second_octet}.101.0/24", "172.${var.second_octet}.102.0/24", "172.${var.second_octet}.103.0/24"]
  rds_public_subnets = ["172.${var.second_octet}.111.0/24", "172.${var.second_octet}.112.0/24", "172.${var.second_octet}.113.0/24"]
  monitor_public_subnets = ["172.${var.second_octet}.121.0/24", "172.${var.second_octet}.122.0/24", "172.${var.second_octet}.123.0/24"]
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
  count = length(local.ap_private_subnets) > 0 ? 1: 0

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

resource "aws_subnet" "app-private" {
  count = length(local.ap_private_subnets)
  vpc_id            = aws_vpc.default.id
  cidr_block        = local.ap_private_subnets[count.index]
  availability_zone = data.aws_availability_zones.available.names[count.index]

  tags = merge(
    {
      Name        = format("%s-%s-app-PrivateSubnet", var.name, var.environment),
      Environment = var.environment,
      Terraform   = "true",
      type        = "private"
    },
    var.tags
  )
}

resource "aws_subnet" "rds-private" {
  count = length(local.rds_private_subnets)
  vpc_id            = aws_vpc.default.id
  cidr_block        = local.rds_private_subnets[count.index]
  availability_zone = data.aws_availability_zones.available.names[count.index]

  tags = merge(
    {
      Name        = format("%s-%s-rds-PrivateSubnet", var.name, var.environment),
      Environment = var.environment,
      Terraform   = "true",
      type        = "private"
    },
    var.tags
  )
}

resource "aws_subnet" "monitor-private" {
  count = length(local.monitor_private_subnets)
  vpc_id            = aws_vpc.default.id
  cidr_block        = local.monitor_private_subnets[count.index]
  availability_zone = data.aws_availability_zones.available.names[count.index]

  tags = merge(
    {
      Name        = format("%s-%s-monitor-PrivateSubnet", var.name, var.environment),
      Environment = var.environment,
      Terraform   = "true",
      type        = "private"
    },
    var.tags
  )
}


resource "aws_subnet" "app-public" {
  count = length(local.app_public_subnets)
  vpc_id                  = aws_vpc.default.id
  cidr_block              = local.app_public_subnets[count.index]
  availability_zone = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = true

  tags = merge(
    {
      Name        = format("%s-%s-app-PublicSubnet", var.name, var.environment),
      Environment = var.environment,
      Terraform   = "true",
      type        = "public"
    },
    var.tags
  )
}


resource "aws_subnet" "rds-public" {
  count = length(local.rds_public_subnets)
  vpc_id                  = aws_vpc.default.id
  cidr_block              = local.rds_public_subnets[count.index]
  availability_zone = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = true

  tags = merge(
    {
      Name        = format("%s-%s-rds-PublicSubnet", var.name, var.environment),
      Environment = var.environment,
      Terraform   = "true",
      type        = "public"
    },
    var.tags
  )
}

resource "aws_subnet" "monitor-public" {
  count = length(local.monitor_public_subnets)
  vpc_id                  = aws_vpc.default.id
  cidr_block              = local.monitor_public_subnets[count.index]
  availability_zone = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = true

  tags = merge(
    {
      Name        = format("%s-%s-monitor-PublicSubnet", var.name, var.environment),
      Environment = var.environment,
      Terraform   = "true",
      type        = "public"
    },
    var.tags
  )
}


resource "aws_route_table_association" "app-private" {
  count = length(local.ap_private_subnets)

  subnet_id      = aws_subnet.app-private[count.index].id
  route_table_id = aws_route_table.private[0].id
}

resource "aws_route_table_association" "app-public" {
  count = length(local.app_public_subnets)
  subnet_id      = aws_subnet.app-public[count.index].id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "rds-private" {
  count = length(local.rds_private_subnets)
  subnet_id      = aws_subnet.rds-private[count.index].id
  route_table_id = aws_route_table.private[0].id
}

resource "aws_route_table_association" "rds-public" {
  count = length(local.rds_public_subnets)
  subnet_id      = aws_subnet.rds-public[count.index].id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "monitor-private" {
  count = length(local.monitor_private_subnets)

  subnet_id      = aws_subnet.monitor-private[count.index].id
  route_table_id = aws_route_table.private[0].id
}

resource "aws_route_table_association" "monitr-public" {
  count = length(local.monitor_public_subnets)
  subnet_id      = aws_subnet.monitor-public[count.index].id
  route_table_id = aws_route_table.public.id
}

#
# NAT resources
#
resource "aws_eip" "nat" {
  count = length(local.app_public_subnets) > 0 ? 1: 0

  vpc = true
}

resource "aws_nat_gateway" "default" {
  depends_on = [aws_internet_gateway.default]

  count = length(local.app_public_subnets) > 0 ? 1: 0

  allocation_id = aws_eip.nat[0].id
  subnet_id     = aws_subnet.app-public[0].id

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