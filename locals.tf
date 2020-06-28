locals {
  public_subnet_id  = join(",", aws_subnet.public.*.id)
  private_subnet_id = join(",", aws_subnet.private.*.id)
}