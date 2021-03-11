# Creazione istanza RDS MySQL
resource "aws_db_instance" "wordpress" {
  allocated_storage    = 20
  storage_type         = "gp2"
  engine               = "mysql"
  engine_version       = "5.7"
  instance_class       = "db.t2.micro"
  username             = var.db_user
  password             = var.db_pass
  port                 = "3306"
  name                 = "wordpress"
  identifier           = "wordpress"
  parameter_group_name = "default.mysql5.7"
  skip_final_snapshot  = true
  multi_az             = false # Mettere a true per ridondanza su più zone  
  publicly_accessible  = false
  db_subnet_group_name = aws_db_subnet_group.wordpress.id
  tags = {
    "Name" = "wordpress"
  }
}

# Creazione subnet RDS
resource "aws_db_subnet_group" "wordpress" {
  subnet_ids = [aws_subnet.sub-private-a.id, aws_subnet.sub-private-b.id]
  tags = {
    "Name" = "wp-rds-sg"
  }
}
