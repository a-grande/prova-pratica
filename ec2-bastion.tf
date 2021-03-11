# Creazione chiave di accesso a bastion
resource "aws_key_pair" "key" {
  key_name   = "provapratica.pem"
  public_key = data.template_file.ssh_public_key.rendered
}

data "template_file" "ssh_public_key" {
  template = file("~/.ssh/id_rsa.pub")
}

# Associazione EIP a bastion 
resource "aws_eip_association" "eip_assoc" {
  depends_on    = [aws_instance.bastion]
  instance_id   = aws_instance.bastion.id
  allocation_id = aws_eip.eip-bastion.id
}

# Creazione istanza EC2 bastion
resource "aws_instance" "bastion" {
  ami                    = var.ami_images_id
  instance_type          = "t3.nano"
  availability_zone      = "eu-west-1a"
  vpc_security_group_ids = [aws_default_security_group.default.id, aws_security_group.ssh.id]
  subnet_id              = aws_subnet.sub-public-a.id
  key_name               = aws_key_pair.key.id

  tags = {
    "Name" = "BASTION"
  }
}

# Allocazione EIP
resource "aws_eip" "eip-bastion" {
  vpc = true
}
