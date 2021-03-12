# Creazione chiave di accesso all'istanza web
resource "aws_key_pair" "bastion-key" {
  key_name   = "bastion.pem"
  public_key = data.template_file.bastion-pub.rendered
}

data "template_file" "bastion-pub" {
  template = file("bastion.pub")
}

# Creazione istanza temporanea per configurazione wordpress
resource "aws_instance" "web" {
  depends_on = [ aws_iam_role.cd ]
  ami                         = var.ami_images_id
  subnet_id                   = aws_subnet.sub-public-a.id
  instance_type               = var.ec2_instance_type
  iam_instance_profile        = aws_iam_instance_profile.wp.name
  associate_public_ip_address = true
  key_name                    = aws_key_pair.bastion-key.key_name
  vpc_security_group_ids      = [aws_default_security_group.default.id, aws_security_group.web.id, aws_security_group.ssh.id]
  tags = {
    "Name" = "WEB-TMP"
  }
}

# Sleep per la propagazione del record database
resource "time_sleep" "wait_30_seconds" {
  depends_on = [aws_route53_record.database]

  create_duration = "60s"
}

locals {
  repo_url = aws_codecommit_repository.wp.clone_url_http
}

# Configurazione ed installazione wordpress su EC2 web
resource "null_resource" "configure_nfs" {
  depends_on = [time_sleep.wait_30_seconds, aws_efs_mount_target.mount]
  connection {
    host        = aws_instance.web.public_ip
    type        = "ssh"
    user        = "ubuntu"
    private_key = file(aws_key_pair.bastion-key.key_name)

  }
  provisioner "file" {
    source      = "wp_script.sh"
    destination = "/tmp/wp_script.sh"
  }

  provisioner "remote-exec" {

    inline = [
      # mount nfs
      "sudo mkdir /var/www",
      "sudo apt install -y nfs-common",
      "sudo mount -t nfs -o nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2,noresvport ${aws_efs_file_system.efs.dns_name}:/  /var/www/",
      "cp /etc/fstab /tmp/fstab ; echo ${aws_efs_file_system.efs.dns_name}:/ /var/www nfs4 defaults,_netdev 0 0  >> /tmp/fstab ; sudo mv /tmp/fstab /etc/fstab",
      "chmod +x /tmp/wp_script.sh",
      "export REPO_NAME=${local.repo_url}",
      "export DOMAIN=${var.wp_url}",
      "export DB_NAME=${var.wp_dbname}",
      "export DB_HOST=${var.db_host}",  
      "export DB_USER=${var.db_user}",
      "export DB_PASSWORD=${var.db_pass}",
      "export WP_USER=${var.wp_user}",
      "export WP_PASSWORD=${var.wp_pass}", 
      "export WP_TITLE=${var.wp_title}",
      "export WP_EMAIL=${var.wp_email}",
       "/tmp/wp_script.sh"
    ]
  }
}

# Creare AMI a partire dall'istanza configurata
resource "aws_ami_from_instance" "ami-wp" {
  depends_on         = [null_resource.configure_nfs]
  name               = "AMI-WORDPRESS"
  source_instance_id = aws_instance.web.id
  tags = {
    Name = "AMI-WORDPRESS"
  }
}

# Ricavare id dell'AMI worpdress
data "aws_ami" "image" {
  depends_on = [aws_ami_from_instance.ami-wp]
  owners     = [var.owner]
  filter {
    name   = "name"
    values = ["AMI-WORDPRESS"]
  }
}
