provider "aws" {
  access_key = "${var.aws_access_key}"
  secret_key = "${var.aws_secret_key}"
  region     = "us-east-1"
}

resource "aws_instance" "aws_linux_vm" {
  instance_type   = "t2.micro"
  ami             = "ami-09f9d773751b9d606"
  key_name        = "${var.key_name}"
  security_groups = ["${aws_security_group.http_test.name}"]

}

resource "aws_security_group" "http_test" {
  name        = "http_test"
  description = "default VPC security group"
  # HTTP access from anywhere
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

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


resource "null_resource" "get_docker" {
  depends_on = ["aws_instance.aws_linux_vm"]
  connection {
    type        = "ssh"
    user        = "ubuntu"
    private_key = "${file(var.private_key_path)}"
    host        = "${aws_instance.aws_linux_vm.public_ip}"
    timeout     = "10m"
  }

  provisioner "remote-exec" {
    inline = [
      "mkdir /tmp/bytecubed/",
    ]
  }

  provisioner "file" {
    source      = "makepage.sh"
    destination = "/tmp/bytecubed/makepage.sh"
  }

  provisioner "file" {
    source      = "Dockerfile"
    destination = "/tmp/bytecubed/Dockerfile"
  }
}

resource "null_resource" "run_docker" {
  depends_on = ["null_resource.get_docker"]
  connection {
    type        = "ssh"
    user        = "ubuntu"
    private_key = "${file(var.private_key_path)}"
    host        = "${aws_instance.aws_linux_vm.public_ip}"
    timeout     = "10m"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo apt-get update",
      "sudo apt -y install docker.io",
      "cd /tmp/bytecubed/",
      "sudo docker build -t bytecubed .",
      "sudo docker run --name some-nginx -d -p 80:80 bytecubed",
    ]
  }
}
