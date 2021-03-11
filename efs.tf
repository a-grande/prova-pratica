# Creazione EFS
resource "aws_efs_file_system" "efs" {
  depends_on     = [aws_vpc.wordpress-vpc]
  creation_token = "wp-efs"
}

locals {
  subnet_ids = [aws_subnet.sub-private-a.id, aws_subnet.sub-private-b.id]
}

# Configurazione efs
resource "aws_efs_mount_target" "mount" {
  depends_on      = [aws_default_security_group.default]
  count           = length(local.subnet_ids)
  file_system_id  = aws_efs_file_system.efs.id
  subnet_id       = element(local.subnet_ids, count.index)
  security_groups = [aws_default_security_group.default.id]
}

