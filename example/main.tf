resource "aws_instance" "example" {
  ami           = var.ami
  instance_type = "t2.micro"
}
