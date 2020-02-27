resource "aws_iam_user" "dev_pah_fm" {
  name = "dev_pah_fm"
}

resource "aws_iam_access_key" "dev_pah_fm" {
  user = aws_iam_user.dev_pah_fm.name
}

module dev_pah_fm_db {
  source       = "./database"

  name        = "dev_pah_fm"
  db_instance = aws_db_instance.db
}

resource "random_password" "secret_key" {
  length  = 50
  special = false
}

module dev_pah_fm_migration {
  source          = "./lambda"

  name            = "dev_pah_fm_migration"
  runtime         = "python3.6"
  handler         = "handlers.migration"
  s3_bucket       = aws_s3_bucket.codeforpoznan_lambdas
  iam_user        = aws_iam_user.dev_pah_fm
  user_can_invoke = true

  subnets         = [
    aws_subnet.private_a,
    aws_subnet.private_b,
    aws_subnet.private_c,
  ]

  security_groups = [
    aws_default_security_group.main
  ]

  envvars = {
    PAH_FM_DB_USER = module.dev_pah_fm_db.user.name
    PAH_FM_DB_NAME = module.dev_pah_fm_db.database.name
    PAH_FM_DB_PASS = module.dev_pah_fm_db.password.result
    PAH_FM_DB_HOST = aws_db_instance.db.address
    BASE_URL       = "dev.pahfm.codeforpoznan.pl"
    SECRET_KEY     = random_password.secret_key.result
  }
}
