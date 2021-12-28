resource "aws_vpc" "firstvpc" {
  cidr_block       = var.vpc_cidr
  
  tags = {
    Name = "MY-VPC"
  }
}


resource "aws_subnet" "pubsubnet" {
  vpc_id     = aws_vpc.firstvpc.id
  cidr_block = var.subnets_cidr
  availability_zone = var.azs
  map_public_ip_on_launch = true

 tags = {
    Name = "PUBLIC-SUB"
  }
}


resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.firstvpc.id

  tags = {
    Name = "IGW"
  }
}


resource "aws_route_table" "pubRT" {
  vpc_id = aws_vpc.firstvpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

   tags = {
		Name = "PUBLIC-RT"
	}
}


resource "aws_route_table_association" "Pub-RT-Association" {
	subnet_id      = aws_subnet.pubsubnet.id
	route_table_id = aws_route_table.pubRT.id
}



resource "aws_security_group" "my-sg" {
    vpc_id = aws_vpc.firstvpc.id
    name = "MY-SG"
    
    ingress {
        from_port = 22
        to_port = 22
        cidr_blocks = ["0.0.0.0/0"]
        protocol = "tcp"

    }

    ingress {
        from_port = 80
        to_port = 80
        cidr_blocks = ["0.0.0.0/0"]
        protocol = "tcp"

    }

     ingress {
        from_port = 3000
        to_port = 3000
        cidr_blocks = ["0.0.0.0/0"]
        protocol = "tcp"

    }
    
    egress {
        from_port = 0
        protocol = "-1"
        to_port = 0
        cidr_blocks = ["0.0.0.0/0"]
    }

  
}




  resource "aws_instance" "EC2-Instance"{
	ami = var.ami
	instance_type = var.instance_type
        security_groups = [aws_security_group.my-sg.id]
	key_name = var.ohio_key
        subnet_id = aws_subnet.pubsubnet.id
	
    tags = {
      "Name" = "EC2-Instance"
    }
	

provisioner "remote-exec" {
      inline = [
        "sudo apt-get update -y",
        "sudo apt install apt-transport-https ca-certificates curl software-properties-common -y",
        "sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -",
        "sudo add-apt-repository 'deb [arch=amd64] https://download.docker.com/linux/ubuntu bionic stable'",
        "sudo apt update",
        "sudo apt-cache policy docker-ce -y",
        "sudo apt install docker-ce -y",
        "sudo git clone https://github.com/pathakbhaskar/samplequest",
        "cd samplequest",
        "sudo docker build -t demoapp1 .",
        "sudo docker run -d -p 3000:3000 demoapp1",
        "sudo echo 'Done'",
      ]
    }



connection {
    type = "ssh"
    host = self.public_ip
    user = "ubuntu"
    private_key =file("C:\\ppk-file\\ohio_key.pem")

  }
}



 