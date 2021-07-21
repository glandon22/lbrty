resource "aws_vpc" "lbrty-main-vpc" {
  cidr_block       = "10.10.0.0/16"
  instance_tenancy = "default"
  enable_dns_hostnames = "true"
  tags = {
    Name = "lbrty-main-vpc"
  }
}

resource "aws_security_group" "lbrty-sg-1" {
 name = "lbrty-sg-1"
 description = "This firewall allows SSH, HTTP and HTTPS"
 vpc_id = aws_vpc.lbrty-main-vpc.id
 
 ingress {
  description = "SSH"
  from_port = 22
  to_port = 22
  protocol = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
 }
 
 ingress { 
  description = "HTTP"
  from_port = 80
  to_port = 80
  protocol = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
 }
 
 ingress {
  description = "HTTPS"
  from_port = 443
  to_port = 443
  protocol = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
 }

 ingress {
  description = "Jenkins"
  from_port = 8080
  to_port = 8080
  protocol = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
 }
 
 egress {
  from_port = 0
  to_port = 0
  protocol = "-1"
  cidr_blocks = ["0.0.0.0/0"]
 }
 
 tags = {
  Name = "lbrty-main-vpc"
 }
}

resource "aws_subnet" "lbrty-public" {
 vpc_id = aws_vpc.lbrty-main-vpc.id
 cidr_block = "10.10.0.0/24"
 availability_zone = "us-east-1a"
 map_public_ip_on_launch = "true"
 
 tags = {
  Name = "lbrty_public_sbn"
 } 
}
resource "aws_subnet" "lbrty-private" {
 vpc_id = aws_vpc.lbrty-main-vpc.id
 cidr_block = "10.10.1.0/24"
 availability_zone = "us-east-1b"
 
 tags = {
  Name = "lbrty_private_sbn"
 }
}

resource "aws_internet_gateway" "lbrty-igw-1" {
 vpc_id = aws_vpc.lbrty-main-vpc.id
 
 tags = { 
  Name = "lbrty-igw-1"
 }
}

resource "aws_route_table" "lbrty-route-table-1" {
 vpc_id = aws_vpc.lbrty-main-vpc.id
 
 route {
  cidr_block = "0.0.0.0/0"
  gateway_id = aws_internet_gateway.lbrty-igw-1.id
 }
 
 tags = {
  Name = "brty-route-table-1"
 }
}

resource "aws_route_table_association" "a" {
 subnet_id = aws_subnet.lbrty-public.id
 route_table_id = aws_route_table.lbrty-route-table-1.id
}

resource "aws_route_table_association" "b" {
 subnet_id = aws_subnet.lbrty-private.id
 route_table_id = aws_route_table.lbrty-route-table-1.id
}

resource "aws_key_pair" "terraform-lbrty_server" {
  key_name   = "lbrty"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCqlyZTY1PrkkBAJP4uc0eXPYqj4j52462TayzXipkMX1ily/wHF3h9ZfChnd2VpSYNO5+hqOGRhl6Hf/xkcJK2qgze48uz9NYSNNoFj/LdtITLBaRnENKymJr1Wcu+WF/N7qf5Mnmgdf4iP7KeBUq1qtV4st6j/Gw1xYUFX25I0BoRLtq8Y0keHBOdg3EgclnZC+Vvz3ShQ4GtumWxZQ1pDzCkkOPHeEWVInEW+zXao41DCJT73yViQU2wvIOt+GRwCY2AwEqyMF3rVQP4K34RqrMX4OJZPwtrQccSqSesokMF2SnDraFpAdTb1fom5orh6O6UC8BXAOnc4SWZ6dH5"
}

resource "aws_key_pair" "terraform-jenkins_server" {
  key_name   = "jenkins"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCjJTt7CPdeudLAjBr1C0v2w9PxdZ9S1OkQmSHXHUU8V/aseGa0IB4QaSdKly+ZGsdgR4eCZMCb82IJC+F9yLpvSbfvVdpuQWKGEEqUTZklnSt4c8aWG6ozSDiNdz/lHeis0Cba85nyEAzmkX7c+Y25E2ouhD1AY7jQwZeBKzS/+Ugy3f3AcH/Bhx97EBI9q9ItG/jb4iHxj0blHbg+9GPa5rW7UydhuTE/cCKiKZ/1ERmg8+M1jgkEo4bLQy52HyDugFi2YTYzEIkVcosGNKHIOdrWD/quCVhx/KNSUSwRImiDD1r4PXpYb0Tz4oWzy02DWy6hxgVeO/7WYde3xvTr"
}

resource "aws_instance" "lbrty_server" {
  ami           = "ami-09e67e426f25ce0d7"
  instance_type = "t3.small"
  instance_initiated_shutdown_behavior = "terminate"
  associate_public_ip_address = "true"
  key_name = "lbrty"
  vpc_security_group_ids = [aws_security_group.lbrty-sg-1.id]
  subnet_id = aws_subnet.lbrty-public.id
  tags = {
    Name = "lbrty_server"
  }
}

resource "aws_instance" "jenkins_server" {
  ami           = "ami-09e67e426f25ce0d7"
  instance_type = "t2.nano"
  instance_initiated_shutdown_behavior = "terminate"
  associate_public_ip_address = "true"
  key_name = "jenkins"
  vpc_security_group_ids = [aws_security_group.lbrty-sg-1.id]
  subnet_id = aws_subnet.lbrty-public.id
  tags = {
    Name = "jenkins_server"
  }
}

resource "aws_ebs_volume" "lbrty_vol" {
  availability_zone = aws_instance.lbrty_server.availability_zone
  size              = 30
}

resource "aws_volume_attachment" "ebs_att" {
  device_name = "/dev/sdh"
  volume_id   = aws_ebs_volume.lbrty_vol.id
  instance_id = aws_instance.lbrty_server.id
}

resource "aws_ebs_volume" "jenkins_vol" {
  availability_zone = aws_instance.jenkins_server.availability_zone
  size              = 30
}

resource "aws_volume_attachment" "jenkins_ebs_att" {
  device_name = "/dev/sdh"
  volume_id   = aws_ebs_volume.jenkins_vol.id
  instance_id = aws_instance.jenkins_server.id
}