provider "aws" {
  region = "us-east-1"
  profile = "terraform-user"
}

# Create VPC
# terraform aws create vpc
resource "aws_vpc" "vpc" {
  cidr_block              = "${var.vpc-cidr}"
  instance_tenancy        = "default"
  enable_dns_hostnames    = true

  tags      = {
    Name    = "vpc"
  }
}

#Create Internet Gateway and Attach it to VPC
# terraform aws create internet gateway
resource "aws_internet_gateway" "internet-gateway" {
  vpc_id    = aws_vpc.vpc.id

  tags      = {
    Name    = "Test amanda" 
  }
}

# Create Public Subnet 1
# terraform aws create subnet
resource "aws_subnet" "public-subnet-1" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = "${var.public-subnet-1-cidr}"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true

  tags      = {
    Name    = "public subnet 1"
  }
}

# Create Public Subnet 2
# terraform aws create subnet
resource "aws_subnet" "public-subnet-2" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              =  "${var.public-subnet-2-cidr}"
  availability_zone       = "us-east-1b"
  map_public_ip_on_launch = true

  tags      = {
    Name    = "public subnet 2"
  }
}

# Create Route Table and Add Public Route
# terraform aws create route table
resource "aws_route_table" "public-route-table" {
  vpc_id       = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.internet-gateway.id
  }

  tags       = {
    Name     = "Public Route Table"
  }
}

# Associate Public Subnet 1 to "Public Route Table"
# terraform aws associate subnet with route table
resource "aws_route_table_association" "public-subnet-1-route-table-association" {
  subnet_id           =  aws_subnet.public-subnet-1.id 
  route_table_id      = aws_route_table.public-route-table.id
}

# Associate Public Subnet 2 to "Public Route Table"
# terraform aws associate subnet with route table
resource "aws_route_table_association" "public-subnet-2-route-table-association" {
  subnet_id           = aws_subnet.public-subnet-2.id
  route_table_id      = aws_route_table.public-route-table.id
}

# Create Private Subnet 1
# terraform aws create subnet
resource "aws_subnet" "private-subnet-1" {
  vpc_id                   =  aws_vpc.vpc.id
  cidr_block               = "${var.private-subnet-1-cidr}"
  availability_zone        = "us-east-1a"
  map_public_ip_on_launch  = false

  tags      = {
    Name    = "private subnet 1 | App Tier"
  }
}

# Create Private Subnet 2
# terraform aws create subnet
resource "aws_subnet" "private-subnet-2" {
  vpc_id                   =  aws_vpc.vpc.id
  cidr_block               = "${var.private-subnet-2-cidr}"
  availability_zone        = "us-east-1b"
  map_public_ip_on_launch  = false

  tags      = {
    Name    = "private subnet 2 | App Tier"
  }
}
# Create Private Subnet 3
# terraform aws create subnet
resource "aws_subnet" "private-subnet-3" {
  vpc_id                   =  aws_vpc.vpc.id
  cidr_block               = "${var.private-subnet-3-cidr}"
  availability_zone        = "us-east-1a"
  map_public_ip_on_launch  = false

  tags      = {
    Name    =  "private subnet 3 | Database Tier"
  }
}

# Create Private Subnet 4
# terraform aws create subnet
resource "aws_subnet" "private-subnet-4" {
  vpc_id                   = aws_vpc.vpc.id
  cidr_block               = "${var.private-subnet-4-cidr}"
  availability_zone        = "us-east-1b"
  map_public_ip_on_launch  = false

  tags      = {
    Name    ="private subnet 4 | Database Tier"
  }
  }
  # Create Security Group for the Application Load Balancer
# terraform aws create security group
resource "aws_security_group" "elb-security-group" {
  name        = "ALB Security Group"
  description = "Enable HTTP/HTTPS access on Port 80/443"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    description      = "HTTP Access"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  ingress {
    description      = "HTTPS Access"
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  tags   = {
    Name = "ALB Security Group"
  }
}


# Create Security Group for the Web Server
# terraform aws create security group
resource "aws_security_group" "webserver-security-group" {
  name        = "Web Server Security Group"
  description = "Enable HTTP/HTTPS access on Port 80/443 via ALB and SSH access on Port 22 via SSH SG"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    description      = "HTTP Access"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks = ["0.0.0.0/0" ]
  }

  ingress {
    description      = "HTTPS Access"
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    cidr_blocks  = ["0.0.0.0/0"]
  }

  ingress {
    description      = "SSH Access"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks  = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  tags   = {
    Name = "Web Server Security Group"
  }
}

# Create Security Group for the Database
# terraform aws create security group
resource "aws_security_group" "database-security-group" {
  name        = "Database Security Group"
  description = "Enable MYSQL/Aurora access on Port 3306"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    description      = "MYSQL/Aurora Access"
    from_port        = 3306
    to_port          = 3306
    protocol         = "tcp"
    security_groups  = ["${aws_security_group.webserver-security-group.id}"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  tags   = {
    Name = "Database Security Group"
  }
}
# Allocate Elastic IP Address (EIP 1)
# terraform aws allocate elastic ip
resource "aws_eip" "eip-for-nat-gateway-1" {
  vpc    = true

  tags   = {
    Name = "EIP 1"
  }
}

# Allocate Elastic IP Address (EIP 2)
# terraform aws allocate elastic ip
resource "aws_eip" "eip-for-nat-gateway-2" {
  vpc    = true

  tags   = {
    Name = "EIP 2"
  }
}

# Create Nat Gateway 1 in Public Subnet 1
# terraform create aws nat gateway
resource "aws_nat_gateway" "nat-gateway-1" {
  allocation_id = aws_eip.eip-for-nat-gateway-1.id
  subnet_id     = aws_subnet.public-subnet-1.id

  tags   = {
    Name = "Nat Gateway Public Subnet 1"
  }
}

# Create Nat Gateway 2 in Public Subnet 2
# terraform create aws nat gateway
resource "aws_nat_gateway" "nat-gateway-2" {
  allocation_id = aws_eip.eip-for-nat-gateway-2.id
  subnet_id     = aws_subnet.public-subnet-2.id

  tags   = {
    Name = "Nat Gateway Public Subnet 2"
  }
}

# Create Private Route Table 1 and Add Route Through Nat Gateway 1
# terraform aws create route table
resource "aws_route_table" "private-route-table-1" {
  vpc_id            = aws_vpc.vpc.id

  route {
    cidr_block      = "0.0.0.0/0"
    nat_gateway_id  = aws_nat_gateway.nat-gateway-1.id
  }

  tags   = {
    Name = "Private Route Table 1"
  }
}

# Associate Private Subnet 1 with "Private Route Table 1"
# terraform aws associate subnet with route table
resource "aws_route_table_association" "private-subnet-1-route-table-association" {
  subnet_id         = aws_subnet.private-subnet-1.id
  route_table_id    = aws_route_table.private-route-table-1.id
}

# Associate Private Subnet 3 with "Private Route Table 1"
# terraform aws associate subnet with route table
resource "aws_route_table_association" "private-subnet-3-route-table-association" {
  subnet_id         = aws_subnet.private-subnet-3.id
  route_table_id    = aws_route_table.private-route-table-1.id
}

# Create Private Route Table 2 and Add Route Through Nat Gateway 2
# terraform aws create route table
resource "aws_route_table" "private-route-table-2" {
  vpc_id            = aws_vpc.vpc.id

  route {
    cidr_block      = "0.0.0.0/0"
    nat_gateway_id  = aws_nat_gateway.nat-gateway-2.id
  }

  tags   = {
    Name = "Private Route Table 2"
  }
}

# Associate Private Subnet 2 with "Private Route Table 2"
# terraform aws associate subnet with route table
resource "aws_route_table_association" "private-subnet-2-route-table-association" {
  subnet_id         = aws_subnet.private-subnet-2.id
  route_table_id    = aws_route_table.private-route-table-2.id
}

# Associate Private Subnet 4 with "Private Route Table 2"
# terraform aws associate subnet with route table
resource "aws_route_table_association" "private-subnet-4-route-table-association" {
  subnet_id         = aws_subnet.private-subnet-4.id
  route_table_id    = aws_route_table.private-route-table-2.id
}
# Create a new load balancer
# terraform create aws elb
resource "aws_elb" "application_load_balancer" {
  name               = "loadbalancer"
  internal           = false
  security_groups    = [aws_security_group.elb-security-group.id]
  subnets            = [aws_subnet.public-subnet-1.id, aws_subnet.public-subnet-2.id]
  

  tags   = {
    Name = "loadbalancer"
  }

  listener {
    instance_port     = 8000
    instance_protocol = "http"
    lb_port           = 80
    lb_protocol       = "http"
  }

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    target              = "HTTP:8000/"
    interval            = 30
  }

  instances                   = [aws_instance.wordpress.id, aws_instance.wordpress1.id]
  cross_zone_load_balancing   = true
  idle_timeout                = 400
  connection_draining         = true
  connection_draining_timeout = 400
  
}

#create autoscaling group
#terraform create aws autoscaling group
resource "aws_launch_template" "aws_autoscaling_group" {
  name_prefix   = "auto-scaling"
  image_id      = "ami-03c7d01cf4dedc891"
  instance_type = "t2.micro"
}

resource "aws_autoscaling_group" "webserver" {
  availability_zones = ["us-east-1a"]
  desired_capacity   = 1
  max_size           = 1
  min_size           = 1

  launch_template {
    id      = aws_launch_template.aws_autoscaling_group.id
    version = "$Latest"
  }
}

# create the subnet group for the rds instance
resource "aws_db_subnet_group" "database_subnet_group" {
  name         = "database-subnets"
  subnet_ids   = [aws_subnet.private-subnet-1.id, aws_subnet.public-subnet-2.id]
  description  = "subnet for database instance"

  tags   = {
    Name = "database-subnets"
  }
}
# create the subnet group for the rds instance
resource "aws_db_subnet_group" "database_subnet_groups" {
  name         = "database-subnet"
  subnet_ids   = [aws_subnet.private-subnet-2.id, aws_subnet.public-subnet-1.id]
  description  = "subnet for database instance"

  tags   = {
    Name = "database-subnets"
  }
}
# create the rds instance
resource "aws_db_instance" "db_instance" {
  engine                  = "mysql"
  engine_version          = "8.0.31"
  multi_az                = false
  identifier              = "rds-instance1"
  username                = "mydb"
  password                = "school12"
  instance_class          = "db.t2.micro"
  allocated_storage       = "200"
  db_subnet_group_name    = aws_db_subnet_group.database_subnet_group.name
  vpc_security_group_ids  = [aws_security_group.database-security-group.id,aws_security_group.webserver-security-group.id]
  db_name                 = "mydatabases"
  skip_final_snapshot     = true
}
# create the rds instance
resource "aws_db_instance" "db_instance1" {
  engine                  = "mysql"
  engine_version          = "8.0.31"
  multi_az                = false
  identifier              = "rds-instance"
  username                = "mydb1"
  password                = "school12"
  instance_class          = "db.t2.micro"
  allocated_storage       = "200"
  db_subnet_group_name    = aws_db_subnet_group.database_subnet_group.name
  vpc_security_group_ids  = [aws_security_group.database-security-group.id,aws_security_group.webserver-security-group.id]
  db_name                 = "mydatabases1"
  skip_final_snapshot     = true
}
#create an efs file system for wordpress
resource "aws_efs_file_system" "efsWordPress" {
  creation_token = "EFS for WordPress"
 
   tags = {
    Name = "EFS for WordPress"
  }
}
#create mount point for file system
 resource "aws_efs_mount_target" "wordpress" {
  file_system_id = aws_efs_file_system.efsWordPress.id
  subnet_id      = aws_subnet.public-subnet-1.id
}
#create mount point for file system
 resource "aws_efs_mount_target" "wordpress1" {
  file_system_id = aws_efs_file_system.efsWordPress.id
  subnet_id      = aws_subnet.public-subnet-2.id
}


# Launch a Webserver Instance hosting WordPress in it.
resource "aws_instance" "wordpress" {
  # AMI ID - Amazon Linux 2 AMI (HVM) - Kernel 5.10, SSD Volume Type
  ami           = data.aws_ami.amazon-linux-2.id
  instance_type =  "t2.micro"
  subnet_id     = aws_subnet.public-subnet-1.id
  availability_zone  = "us-east-1a"
  user_data = file("webserver.sh")

  key_name = "amandakey"

  # Security groups to use
  vpc_security_group_ids = [aws_security_group.webserver-security-group.id]

  tags = {
    Name = "wordpress"
  }
 
}
# Launch a Webserver Instance hosting WordPress in it.
resource "aws_instance" "wordpress1" {
  # AMI ID - Amazon Linux 2 AMI (HVM) - Kernel 5.10, SSD Volume Type
  ami           = data.aws_ami.amazon-linux-2.id
  instance_type =  "t2.micro"
  subnet_id     = aws_subnet.public-subnet-2.id
  availability_zone  = "us-east-1b"
  user_data = file("webserver.sh")

  key_name = "amanda-key"

  # Security groups to use
  vpc_security_group_ids = [aws_security_group.webserver-security-group.id]

  tags = {
    Name = "wordpress"
  }
 
}
resource "aws_s3_bucket" "schoolweb" {
  bucket = "school-webs"

  tags = {
    Name        = "My bucket"
    Environment = "Dev"
  }
}
resource "aws_iam_role" "for_IAM_user" {
  name = "test_role"

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })

  tags = {
    tag-key = "tag-value"
  }
}
resource "aws_cloudwatch_metric_alarm" "monitoring" {
  alarm_name                = "webserver1"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = 2
  metric_name               = "CPUUtilization"
  namespace                 = "AWS/EC2"
  period                    = 120
  statistic                 = "Average"
  threshold                 = 80
  alarm_description         = "This metric monitors ec2 cpu utilization"
}
#create sns
#terraform create aws sns topic
resource "aws_sns_topic" "user_updates" {
  name = "user-updates-topic"
}
# get hosted zone details
# terraform aws data  hosted zone
data "aws_route53_zone" "hosted_zone" {
  name         = var.domain_name
}
# create a record set in route 53
# terraform aws route 53 record
resource "aws_route53_record" "site_domain" {
  zone_id = data.aws_route53_zone.hosted_zone.zone_id 
  name    = var.record_name
  type    = "A"

   alias {
    name                   =  aws_elb.application_load_balancer.dns_name
    zone_id                = aws_elb.application_load_balancer.zone_id
    evaluate_target_health = true
   }
}
# create ebs
# terraform aws create ebs
resource "aws_ebs_volume" "volume_for_instances" {
  availability_zone = "us-east-1a"
  size              = 20

  tags = {
    Name = "volume"
  }
}
  


