variable "name" {
  type = string
}

variable "db_instance" {}

provider "postgresql" {
  host            = "127.0.0.1" // var.db_instance.address
  port            = "15432"     // var.db_instance.port
  username        = var.db_instance.username
  password        = var.db_instance.password
  sslmode         = "require"
  connect_timeout = 15
}

provider "postgresql" {
  alias           = "without_superuser"
  host            = "127.0.0.1" // var.db_instance.address
  port            = "15432"     // var.db_instance.port
  username        = var.db_instance.username
  password        = var.db_instance.password
  sslmode         = "require"
  connect_timeout = 15
  superuser       = false
}

resource "random_password" "password" {
  length  = 128
  special = false
}

resource "postgresql_role" "user" {
  provider = postgresql.without_superuser
  name     = var.name
  login    = true
  password = random_password.password.result

  depends_on = [
    random_password.password,
    var.db_instance,
  ]
}

resource "postgresql_database" "database" {
  name  = var.name
  owner = postgresql_role.user.name

  depends_on = [
    postgresql_role.user,
  ]
}

output "user" {
  value     = postgresql_role.user
  sensitive = true
}

output "database" {
  value = postgresql_database.database
}

output "password" {
  value     = random_password.password
  sensitive = true
}
