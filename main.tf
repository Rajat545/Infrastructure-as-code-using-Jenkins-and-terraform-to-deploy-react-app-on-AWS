//the provider block, will can add your here or leave it, terraform will use deafault 
provider "aws" {
    region = "us-east-1"
}

#create vpc
resource "aws_vpc" "main" {
    cidr_block = "10.0.0.0/16"
    tags = {
      Name = "demo-vpc"
    }
  
}

#create subnet for two different availability zones
resource "aws_subnet" "subnet1" {
    vpc_id = aws_vpc.main
    cidr_block = "10.0.0.0/24"
    availability_zone = "us-east-1a"
  
}

#create the second subnet with similar values
resource "aws_subnet" "subnet2" {
    vpc_id = "aws_vpc.main.id"
    cidr_block = "10.0.0.0/24"
    availability_zone = "us-east-1b"
  
}

#create internet gateway and attach to vpc
resource "aws_internet_gateway" "pandit_gw" {
    vpc_id = aws_vpc.main
}   

 # create route table 
  
resource "aws_route_table" "dev_rt" {
    vpc_id = aws_vpc.main

    route = {
        cird_block_id = "0.0.0.0/0"
        gateway_id = aws-internal_gateway.pandit_gw.vpc_id
    }
}

#create route association with two subnets
resource "aws_route_table_association" "subnet1" {
    subnet_id = aws_subnet.subnet1.id
    route_table_id = aws_route_table.dev_rt.id
}

resource "aws_route_table_association" "subnet2" {
    subnet_id = aws_subnet.subnet2.id
    route_table_id = aws_route_table.dev_rt.id
}

#create security group for jenkins instance
resource "aws_security_group" "jenkins_sg" {
    name = "jenkins_sg"
    description = "security group for jenkins instance"
    vpc_id = aws_vpc.main.id

    ingress = [
        {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    },

        {
        from_port = 8080
        to_port = 8080
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    ]
    
    egress = {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
}

#create security group for minikube instance
resource "aws_security_group" "minikube_sg" {
    name = "mimikube_sg"
    description = "security group for minikube instance"
    vpc_id = aws_vpc.main.id

    ingress = [
        {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    },

        {
        from_port = 8443
        to_port = 8443
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    },
    
     
        {
        from_port = 8444
        to_port = 8444
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    ]

    egress = [
        {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
    ]

}

#create jenkins instances in subnet1
resource "aws_instance" "jenkins" {
    ami = "ami-id"   #paste here your ec2 ami id
    instance_type = "t2.medium"
    subnet_id = aws_subnet.subnet1.id
    associate_public_ip_address = true
    key_name = "key"
    security_groups = [aws_security_group.jenkins_sg.id]

    tags = {
        Name = "jenkins-server"
    }
  
}

#create minikube instances in subnet2
resource "aws_instance" "minikube" {
    ami = "ami-id"   #paste here your ec2 ami id
    instance_type = "t2.medium"
    subnet_id = aws_subnet.subnet2.id
    associate_public_ip_address = true
    key_name = "key"
    security_groups = [aws_security_group.minikube_sg.id]

    tags = {
        Name = "minikube-server"
    }
  
}

resource "null_resource" "name" {
  

  #SSH into ec2 instance

  connection {
    type = "ssh"
    user = "ubuntu"
    private_key = file("~/Documents/checkup.pem")          //use the pem key path here
    host = aws_instance.jenkins_server.public_ip
  }

  #copy the install_jenkins.sh file from local to ec2 instance.

  provisioner "file"{
    source = "install_jenkins.sh"                       // the shell file we are transfering
    destination = "/tmp/install_jenkins.sh"
  }

  # set permission and execute the install_jenkins.sh file

  provisioner "remote-exec"{
    inline = [
      "sudo chmod +x /tmp/install_jenkins.sh",
      "sudo sh /tmp/install_jenkins.sh"

    ]
  }
   depends_on = [                           // this must start and be ready before the null resource starts.
    aws_instance.jenkins_server
  ]
}

output "jenkins_url" {
  value = join("",["http://",aws_instance.jenkins_server.public_dns,":","8080"])
  
}