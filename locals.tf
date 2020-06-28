locals {
  public_subnet_id  = join(",", aws_subnet.public.*.id)
  private_subnet_id = join(",", aws_subnet.private.*.id)
  ec2_instance_id   = join(",", aws_instance.ec2.*.id)
}