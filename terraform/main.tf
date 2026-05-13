resource "aws_vpc" "main" {
  cidr_block = var.vpc-cidr
}

resource "aws_subnet" "main" {
  vpc_id = aws_vpc.main.id
  cidr_block = var.subnet-cidr
  map_public_ip_on_launch = true
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

}

resource "aws_route_table" "rt" {
    vpc_id = aws_vpc.main.id

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.igw.id
    }

}

resource "aws_route_table_association" "rt-a" {
    subnet_id = aws_subnet.main.id
    route_table_id = aws_route_table.rt.id
}

resource "aws_security_group" "sg" {
    name = "sg"
    description = "Allow SSH and HTTP inbound"
    vpc_id = aws_vpc.main.id
}

resource "aws_vpc_security_group_ingress_rule" "allow_ssh" {
  security_group_id = aws_security_group.sg.id
  cidr_ipv4 = var.my-ip
  from_port = 22
  to_port = 22
  ip_protocol = "tcp"
}

resource "aws_vpc_security_group_ingress_rule" "allow_http" {
  security_group_id = aws_security_group.sg.id
  cidr_ipv4 = "0.0.0.0/0"
  from_port = 80
  to_port = 80
  ip_protocol = "tcp"
}

resource "aws_vpc_security_group_egress_rule" "allow_all_outbound" {
  security_group_id = aws_security_group.sg.id
  cidr_ipv4 = "0.0.0.0/0"
  ip_protocol = "-1"
}

resource "tls_private_key" "private-key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "ec2-key-pair" {
  key_name = "ec2-key"
  public_key = tls_private_key.private-key.public_key_openssh
}

resource "local_file" "save-private-key" {
  content = tls_private_key.private-key.private_key_pem
  filename = "${path.module}/ec2-private-key.pem"
}

resource "aws_instance" "ec2" {
  ami = data.aws_ami.ubuntu.id
  instance_type = var.instance-type
  subnet_id = aws_subnet.main.id
  vpc_security_group_ids = [aws_security_group.sg.id]
  key_name = aws_key_pair.ec2-key-pair.key_name
}