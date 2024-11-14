#create vpc
resource "aws_vpc" "user09" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "user09-vpc"
   }
 }

#create subnet
resource "aws_subnet" "user09_public" {
    count = 2
    vpc_id = "vpc-094579365b61b900d"
    cidr_block = ["10.222.5.0/24","10.222.6.0/24"][count.index]
    availability_zone = ["us-east-1a","us-east-1b"][count.index]
    map_public_ip_on_launch = true
    tags = {
      Name = "user09_public-${count.index}"
    }
}
#create security group
resource "aws_security_group" "prod-sg" {
  name        = "prod-web-ssh-sg"
  vpc_id      = "vpc-094579365b61b900d"
  description = "prod web server traffic allowed ssh & http"

}

resource "aws_vpc_security_group_ingress_rule" "prod-ingress-22" {
  security_group_id = aws_security_group.prod-sg.id
  from_port         = 22
  to_port           = 22
  ip_protocol       = "tcp"
  cidr_ipv4         = "0.0.0.0/0"
}

resource "aws_vpc_security_group_ingress_rule" "prod-ingress-80" {
  security_group_id = aws_security_group.prod-sg.id
  from_port         = 80
  to_port           = 80
  ip_protocol       = "tcp"
  cidr_ipv4         = "0.0.0.0/0"
}

resource "aws_vpc_security_group_egress_rule" "prod-egress" {
  security_group_id = aws_security_group.prod-sg.id
  ip_protocol       = "-1"
  cidr_ipv4         = "0.0.0.0/0"
}
#create ec2 instance
resource "aws_instance" "user09" {
  ami = "ami-0866a3c8686eaeeba" 
  instance_type = "t2.micro"
  subnet_id = aws_subnet.user09_public[0].id
  security_groups = [aws_security_group.prod-sg.id]
  key_name = "user09"
  tags = {
    Name = "user09-instance"
  }
}
#create output
output "public_ip" {
  value = aws_instance.user09.public_ip
}
 

output "vpc_info" {
  value = {
id = aws_vpc.finalvpc.id
    cidr_block = aws_vpc.finalvpc.cidr_block
  }
}
