output "availability_zones" {
  value = data.aws_availability_zones.available.names
}

output "vpc_id" {
  value = aws_vpc.vpc.id
}

output "public_subnets_id" {
  value = "${join(",", aws_subnet.public.*.id)}"
}

output "private_subnets_id" {
  value = "${join(",", aws_subnet.private.*.id)}"
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