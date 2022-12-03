output "id" {
  value       = aws_vpc.default.id
}

output "app_public_subnet_ids" {
  value       = aws_subnet.app-public.*.id
}

output "rds_public_subnet_ids" {
  value       = aws_subnet.rds-public.*.id
}

output "monitor_public_subnet_ids" {
  value       = aws_subnet.monitor-public.*.id
}

output "app_private_subnet_ids" {
  value       = aws_subnet.app-private.*.id
}

output "rds_private_subnet_ids" {
  value       = aws_subnet.rds-private.*.id
}

output "monitor_private_subnet_ids" {
  value       = aws_subnet.monitor-private.*.id
}

output "cidr_block" {
  value       = var.cidr_block
}

output "nat_gateway_ips" {
  value       = aws_eip.nat.*.public_ip
}

output "private_route_table" {
  value       = aws_route_table.private.*.id
}

output "public_route_table" {
  value       = aws_route_table.public.id
}

output "vpc_cidr" {
  value       = local.cidr_block
}