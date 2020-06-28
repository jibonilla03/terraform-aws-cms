output "availability_zones" {
  value = data.aws_availability_zones.available.names
}

output "vpc_id" {
  value = aws_vpc.vpc.id
}

output "public_subnets_id" {
  value = join(",", aws_subnet.public.*.id)
}

output "private_subnets_id" {
  value = join(",", aws_subnet.private.*.id)
}

output "ssh_sg_id" {
  value = aws_security_group.ssh_sg.id
}

output "web_sg_id" {
  value = aws_security_group.web_sg.id
}

output "elb_sg_id" {
  value = aws_security_group.elb_sg.id
}

output "rds_sg_id" {
  value = aws_security_group.rds_sg.id
}

output "ec2key_name" {
  value = aws_key_pair.ec2key.key_name
}

output "ec2_id" {
  value = join(",", aws_instance.ec2.*.id)
}

output "rds_address" {
  value = aws_db_instance.rds.address
}

output "elb_dns_name" {
  value = aws_elb.elb.dns_name
}

output "elb_zone_id" {
  value = aws_elb.elb.zone_id
}
