variable "aws_access_key" {
  type = "string"
}

variable "aws_access_secret" {
  type = "string"
}

variable "key_pair" {
  type = "string"
  default = "tf"
  description = "The name of the key pair file (.pem)"
}

provider "aws" {
  access_key = "${var.aws_access_key}"
  secret_key = "${var.aws_access_secret}"
  region     = "sa-east-1"
}

resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
}

resource "aws_internet_gateway" "igw" {
    vpc_id = "${aws_vpc.main.id}"
    tags = {
        Name = "igw"
    }
}

resource "aws_route_table" "public" {
  vpc_id = "${aws_vpc.main.id}"
}

resource "aws_route" "public_default" {
  route_table_id = "${aws_route_table.public.id}"
  gateway_id     = "${aws_internet_gateway.igw.id}"
  destination_cidr_block = "0.0.0.0/0"
}

resource "aws_route_table_association" "public" {
  subnet_id      = "${aws_subnet.main.id}"
  route_table_id = "${aws_route_table.public.id}"
}

resource "aws_subnet" "main" {
  vpc_id     = "${aws_vpc.main.id}"
  cidr_block = "10.0.1.0/24"
  map_public_ip_on_launch = false

  tags = {
    Name = "Proxy Subnet"
  }

  depends_on = [
        "aws_internet_gateway.igw"
    ]
}

resource "aws_security_group" "ssh" {
  name        = "ssh"
  description = "(Proxy) Allow SSH"
  vpc_id      = "${aws_vpc.main.id}"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "proxy" {
  ami             = "ami-286f2a44"
  instance_type   = "t2.micro"
  key_name        = "${var.key_pair}"
  subnet_id       = "${aws_subnet.main.id}"
  security_groups = ["${aws_security_group.ssh.id}"]
  associate_public_ip_address  = false
  tags = {
    Name =  "proxy machine"
  }
}

resource "aws_eip" "pib" {
  instance = "${aws_instance.proxy.id}"
  vpc      = true
}

resource "aws_eip_association" "eip_assoc" {
  instance_id   = "${aws_instance.proxy.id}"
  allocation_id = "${aws_eip.pib.id}"
}

output "command" {
  value = "sshuttle --dns -r ec2-user@${aws_eip.pib.public_ip} 0/0 -e \"ssh -A -i ${var.key_pair}.pem\""
}
