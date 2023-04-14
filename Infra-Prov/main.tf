# Configure VPC
resource "aws_vpc" "x-vpc" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "x-VPC"
  }
}

# Configure subnet
resource "aws_subnet" "public-subnet" {

  vpc_id     = aws_vpc.x-vpc.id
  cidr_block = "10.0.1.0/24"

  tags = {
    Name = "Public Subnet"
  }
}

resource "aws_subnet" "private-subnet" {
  vpc_id     = aws_vpc.x-vpc.id
  cidr_block = "10.0.2.0/24"


  tags = {
    Name = "Private Subnet"
  }
}


# Configure Security Group

resource "aws_security_group" "x-sg" {
  name        = "X-SG"
  description = "Allow TLS inbound traffic"
  vpc_id      = aws_vpc.x-vpc.id

  ingress {
    description = "TLS from VPC"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "TLS from VPC"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }


  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "X-SG"
  }
}

# Configure InternetGatway

resource "aws_internet_gateway" "x-igw" {
  vpc_id = aws_vpc.x-vpc.id

  tags = {
    Name = "X-IGW"
  }
}

# Configure RouteTable

resource "aws_route_table" "public-rt" {
  vpc_id = aws_vpc.x-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.x-igw.id
  }

  tags = {
    Name = "Public RT"
  }
}

# Configure RT association

resource "aws_route_table_association" "public-rt-assoc" {
  subnet_id      = aws_subnet.public-subnet.id
  route_table_id = aws_route_table.public-rt.id
}

# Configure for the web-server 

resource "aws_instance" "web-server" {
  ami                    = "ami-06e46074ae430fba6"
  instance_type          = "t2.micro"
  key_name               = "web-ser"
  subnet_id              = aws_subnet.public-subnet.id
  vpc_security_group_ids = [aws_security_group.x-sg.id]


  connection {
    type        = "ssh"
    host        = self.public-ip
    user        = ec2-user
    private_key = file("./web-ser.pem")
  }

  tags = {
    Name = "Web Server"
  }

}


# Configure elastic IP

resource "aws_eip" "x-aws-eip" {
  instance = aws_instance.web-server.id
  vpc      = true
}


# Configure for DB-server

resource "aws_instance" "db-server" {
  ami                    = "ami-06e46074ae430fba6"
  instance_type          = "t2.micro"
  key_name               = "web-ser"
  subnet_id              = aws_subnet.private-subnet.id
  vpc_security_group_ids = [aws_security_group.x-sg.id]


  connection {
    type        = "ssh"
    user        = ec2-user
    private_key = file("./web-ser.pem")
  }

  tags = {
    Name = "Database Server"
  }

}



resource "aws_eip" "x-aws-ngw-eip" {
  vpc = true
}

# Configure NAT Gateway

resource "aws_nat_gateway" "aws-ngw" {
  allocation_id = aws_eip.x-aws-ngw-eip.id
  subnet_id     = aws_subnet.public-subnet.id

  tags = {
    Name = "NAT Gateway"
  }
}


# Configure Private route table

resource "aws_route_table" "private-rt" {

  vpc_id = aws_vpc.x-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.aws-ngw.id
  }

  tags = {
    Name = "Private RT"
  }
}


# Configure Private Route Table assoc

resource "aws_route_table_association" "private-rt-assoc" {
  subnet_id      = aws_subnet.private-subnet.id
  route_table_id = aws_route_table.private-rt.id
}
