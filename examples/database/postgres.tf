resource "google_sql_database_instance" "postgres" {
  name                = "${var.name}-instance"
  database_version    = "POSTGRES_13"
  region              = var.region
  deletion_protection = false # TODO: rm on prod

  settings {
    tier = "db-f1-micro"
  }
}

resource "google_sql_database" "default" {
  name     = "database-name"
  instance = google_sql_database_instance.postgres.name
}

resource "google_sql_user" "default" {
  instance = google_sql_database_instance.postgres.name
  name     = "user"
  password = "password" # TODO: secret manager
}
#
#resource "google_compute_instance" "instance" {
#
#  metadata = {
#    # ... existing metadata ...
#    "sql-database-instance" = google_sql_database_instance.postgres.connection_name
#  }
#}

#psql "host=127.0.0.1 port=5432 dbname=database-name user=user password=password"
