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
  subnet_id              = element(split(",", local.subnet_id), count.index % 2)
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
}


