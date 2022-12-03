output "id" {
  value       = aws_vpc.default.id
  description = "VPC ID"
}

output "app_public_subnet_ids" {
  value       = aws_subnet.app-public.*.id
  description = "List of public subnet IDs"
}

output "rds_public_subnet_ids" {
  value       = aws_subnet.rds-public.*.id
  description = "List of public subnet IDs"
}

output "monitor_public_subnet_ids" {
  value       = aws_subnet.monitor-public.*.id
  description = "List of public subnet IDs"
}

output "app_private_subnet_ids" {
  value       = aws_subnet.app-private.*.id
  description = "List of private subnet IDs"
}

output "rds_private_subnet_ids" {
  value       = aws_subnet.rds-private.*.id
  description = "List of private subnet IDs"
}

output "monitor_private_subnet_ids" {
  value       = aws_subnet.monitor-private.*.id
  description = "List of private subnet IDs"
}

output "cidr_block" {
  value       = var.cidr_block
  description = "The CIDR block associated with the VPC"
}

output "nat_gateway_ips" {
  value       = aws_eip.nat.*.public_ip
  description = "List of Elastic IPs associated with NAT gateways"
}

output "private_route_table" {
  value       = aws_route_table.private.*.id
}

output "public_route_table" {
  value       = aws_route_table.public.id
}