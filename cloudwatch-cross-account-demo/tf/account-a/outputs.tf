output "tgw_id" {
  value = aws_ec2_transit_gateway.transit_gateway.id
}

output "shared_arn" {
  value = aws_ram_principal_association.example.resource_share_arn
}