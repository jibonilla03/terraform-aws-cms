locals {
  subnet_id = join(",", aws_subnet.public.*.id)
}