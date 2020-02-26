module dev_pah_fm_db {
  source       = "./database"

  name        = "dev_pah_fm"
  db_instance = aws_db_instance.db
}
