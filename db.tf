resource "aws_db_subnet_group" "private" {
  name = "private"
  subnet_ids = [
    aws_subnet.private_a.id,
    aws_subnet.private_b.id,
    aws_subnet.private_c.id,
  ]
}

resource "random_password" "db_password" {
  length  = 128
  special = false
}

resource "aws_db_instance" "db" {
  identifier = "main-postgres"

  engine         = "postgres"
  engine_version = "13.20"

  instance_class    = "db.t3.micro"
  allocated_storage = 8

  username = "postgres"
  password = random_password.db_password.result

  backup_retention_period = 7
  backup_window           = "03:00-04:00"
  multi_az                = false
  db_subnet_group_name    = aws_db_subnet_group.private.name

  final_snapshot_identifier = "main-postgres-final-snapshot"

  ca_cert_identifier = "rds-ca-rsa2048-g1"

  depends_on = [
    random_password.db_password,
    aws_db_subnet_group.private,
  ]

  lifecycle {
    # we don't want to destroy db by accident
    prevent_destroy = true
  }
}
