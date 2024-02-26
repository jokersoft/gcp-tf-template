resource "google_service_account" "atlantis" {
  account_id   = "atlantis"
  display_name = "Atlantis Service Account"
}

resource "google_project_iam_member" "atlantis_compute" {
  project = var.project
  role    = "roles/compute.instanceAdmin.v1"
  member  = "serviceAccount:${google_service_account.atlantis.email}"
}

resource "google_project_iam_member" "atlantis_storage" {
  project = var.project
  role    = "roles/storage.objectAdmin"
  member  = "serviceAccount:${google_service_account.atlantis.email}"
}

resource "google_project_iam_member" "atlantis_secrets" {
  project = var.project
  role    = "roles/secretmanager.secretAccessor"
  member  = "serviceAccount:${google_service_account.atlantis.email}"
}
