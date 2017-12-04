provider "aws" {
  access_key = "xxx"
  secret_key = "xxx"
  region     = "sa-east-1"
}

resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
}

resource "aws_internet_gateway" "igw" {
    vpc_id = "${aws_vpc.main.id}"
    tags {
        Name = "igw"
    }
}

resource "aws_subnet" "main" {
  vpc_id     = "${aws_vpc.main.id}"
  cidr_block = "10.0.1.0/24"

  tags {
    Name = "Main"
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
  key_name        = "spkeypar"
  subnet_id       = "${aws_subnet.main.id}"
  security_groups = ["${aws_security_group.ssh.id}"]
  associate_public_ip_address  = false
}

resource "aws_eip" "pib" {
  instance = "${aws_instance.proxy.id}"
  vpc      = true
}

output "ip" {
  value = "${aws_eip.pib.public_ip}"
}
