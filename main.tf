// Create the VPC
resource "aws_vpc" "vpc" {
  cidr_block           = "172.16.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    name        = "${var.name}-${var.environment}-private-route"
    environment = "${var.environment}"
  }

}

// Create the IGW
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    name        = "${var.name}-${var.environment}-igw"
    environment = "${var.environment}"
  }

}

// Create Public Subnets
resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.vpc.id
  count                   = length(var.public_subnets_cidr)
  cidr_block              = element(var.public_subnets_cidr, count.index)
  availability_zone       = element(data.aws_availability_zones.available.names, count.index)
  map_public_ip_on_launch = true

  tags = {
    name        = "${var.name}-${var.environment}-public-subnet"
    environment = "${var.environment}"
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    name        = "${var.name}-${var.environment}-public-route"
    environment = "${var.environment}"
  }
}

resource "aws_route_table_association" "public" {
  count          = length(var.public_subnets_cidr)
  subnet_id      = element(aws_subnet.public.*.id, count.index)
  route_table_id = aws_route_table.public.id
}

// Create the Private Subnets
resource "aws_subnet" "private" {
  vpc_id                  = aws_vpc.vpc.id
  count                   = length(var.private_subnets_cidr)
  cidr_block              = element(var.private_subnets_cidr, count.index)
  availability_zone       = element(data.aws_availability_zones.available.names, count.index)
  map_public_ip_on_launch = false

  tags = {
    name        = "${var.name}-${var.environment}-private-subnet"
    environment = "${var.environment}"
  }
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    name        = "${var.name}-${var.environment}-private-route"
    environment = "${var.environment}"
  }
}

resource "aws_route_table_association" "private" {
  count          = length(var.private_subnets_cidr)
  subnet_id      = element(aws_subnet.private.*.id, count.index)
  route_table_id = aws_route_table.private.id
}

// Create Security Group to allow SSH
resource "aws_security_group" "ssh_sg" {
  name        = "${var.name}-${var.environment}-ssh"
  description = "Security Group ${var.name}-${var.environment}"
  vpc_id      = aws_vpc.vpc.id

  tags = {
    name        = "${var.name}-${var.environment}-ssh"
    environment = "${var.environment}"
  }
  // allows traffic from the SG itself
  ingress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    self      = true
  }

  // allow traffic for TCP 22
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

// Create web security group
resource "aws_security_group" "web_sg" {
  name        = "${var.name}-${var.environment}-web"
  description = "Security Group ${var.name}-${var.environment}"
  vpc_id      = aws_vpc.vpc.id

  tags = {
    name        = "${var.name}-${var.environment}-web"
    environment = "${var.environment}"
  }
  // allows traffic from the SG itself
  ingress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    self      = true
  }

  // allow traffic for TCP 80
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  // allow traffic for TCP 443
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

// Create security group for ELB
resource "aws_security_group" "elb_sg" {
  name        = "${var.name}-${var.environment}-elb"
  description = "Security Group ${var.name}-${var.environment}"
  vpc_id      = aws_vpc.vpc.id

  tags = {
    name        = "${var.name}-${var.environment}-elb"
    environment = "${var.environment}"
  }
  # HTTP access from anywhere
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # outbound internet access
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

// Create security group fro RDS
resource "aws_security_group" "rds_sg" {
  name        = "${var.name}-${var.environment}-rds"
  description = "Security Group ${var.name}-${var.environment}"
  vpc_id      = aws_vpc.vpc.id
  tags = {
    name        = "${var.name}-${var.environment}-rds"
    environment = "${var.environment}"
  }

  // allows traffic from the SG itself
  ingress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    self      = true
  }

  // allow traffic for TCP 3306
  ingress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.web_sg.id]
  }

  // outbound internet access
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

// Create EC2 keypair resource. A key pair is used to control login access to EC2 instances.
resource "aws_key_pair" "ec2key" {
  key_name   = var.key_name
  public_key = var.public_key
}

// Create EC2 instances
resource "aws_instance" "ec2" {
  ami                    = data.aws_ami.ubuntu.id
  vpc_security_group_ids = [aws_security_group.ssh_sg.id, aws_security_group.web_sg.id]
  key_name               = var.key_name
  instance_type          = var.instance_type
  count                  = var.instance_count
  subnet_id              = element(split(",", local.public_subnet_id), count.index % 2)

  root_block_device {
    volume_type           = var.ebs_root_volume_type
    volume_size           = var.ebs_root_volume_size
    delete_on_termination = var.ebs_root_delete_on_termination
  }

  tags = {
    name        = "${var.name}-${var.environment}-${format("%02d", count.index + 1)}"
    environment = var.environment
    server_role = var.server_role
  }

  user_data = var.user_data

  # This is where we configure the instance with ansible-playbook
  /*provisioner "local-exec" {
    command = "ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -u ubuntu --key-file './secrets/key.pem' -i '${self.public_ip},' site.yml"
  }*/
}

// Create RDS Database
resource "aws_db_subnet_group" "rds_subnet_group" {
  name        = "${var.name}-${var.environment}-subnet-group"
  description = "Our main group of subnets"
  subnet_ids  = split(",", local.private_subnet_id)
}

resource "aws_db_instance" "rds" {
  identifier             = "${var.name}-${var.environment}"
  allocated_storage      = var.storage
  engine                 = var.engine
  engine_version         = var.engine_version
  instance_class         = var.instance_class
  multi_az               = var.multi_az
  name                   = var.db_name
  username               = var.username
  password               = var.password
  db_subnet_group_name   = aws_db_subnet_group.rds_subnet_group.id
  vpc_security_group_ids = [aws_security_group.rds_sg.id]
  skip_final_snapshot    = true

  tags = {
    name        = "${var.name}-${var.environment}"
    environment = var.environment
  }

  provisioner "local-exec" {
    command = "echo DB_HOSTNAME: ${aws_db_instance.rds.address} >> ${var.name}-${var.environment}.yml"
  }
}

// Create ELB resources and load balancing rules
resource "aws_elb" "elb" {
  name            = "${var.name}-${var.environment}-elb"
  security_groups = [aws_security_group.elb_sg.id]
  subnets         = split(",", local.public_subnet_id)

  tags = {
    name        = "${var.name}-${var.environment}-elb"
    environment = var.environment
  }

  listener {
    instance_port     = 8080
    instance_protocol = "http"
    lb_port           = 80
    lb_protocol       = "http"
  }

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    target              = "TCP:80"
    interval            = 30
  }

  cross_zone_load_balancing   = true
  idle_timeout                = 400
  connection_draining         = true
  connection_draining_timeout = 400

  instances = split(",", local.ec2_instance_id)

  provisioner "local-exec" {
    command = "echo ELB_DNS_NAME: ${aws_elb.elb.dns_name} >> ${var.name}-${var.environment}.yml"
  }
}

// Create Route 53 DNS Records
/*resource "aws_route53_record" "main" {
  zone_id = aws_elb.elb.zone_id
  name    = var.domain_name
  type    = "A"

  alias {
    name                   = aws_elb.elb.dns_name
    zone_id                = aws_elb.elb.zone_id
    evaluate_target_health = true
  }
}

resource "aws_route53_record" "www" {
  zone_id = aws_elb.elb.zone_id
  name    = "www.${var.domain_name}"
  type    = "CNAME"
  ttl     = "300"
  records = [var.domain_name]
}*/

