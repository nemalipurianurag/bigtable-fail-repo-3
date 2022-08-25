##Deployment to PROD need to have HA support deploying cluster in different zones of regions.
## skipping 2nd cluster block in Multi region Bigtable 

# Required Google APIs
locals {
  googleapis = ["bigtable.googleapis.com", "cloudkms.googleapis.com", ]
}

resource "google_project_service" "bigtable" {
  for_each           = toset(local.googleapis)
  project            = var.project_id
  service            = each.key
  disable_on_destroy = false
}

resource "google_kms_key_ring" "example-keyring658" {
  name     = "keyring-example658"
  location = "us-central1"
  depends_on = [
    google_project_service.bigtable
  ]
}

resource "google_kms_crypto_key" "bt_key658" {
  name     = "key656"
  key_ring = google_kms_key_ring.example-keyring658.id
}

resource "google_kms_key_ring" "example-keyring659" {
  name     = "keyring-example659"
  location = "us-east1"
  depends_on = [
    google_project_service.bigtable
  ]
}

resource "google_kms_crypto_key" "bt_key659" {
  name     = "key657"
  key_ring = google_kms_key_ring.example-keyring659.id
}


# Deployment to PROD need to have HA support deploying cluster in different zones of regions.

resource "google_bigtable_instance" "bt_prod_instance656" {
  name                = "bt-wf-instance656"
  deletion_protection = false

  cluster {
    cluster_id   = "bt-instance-cluster-central"
    storage_type = "HDD"
    zone         = "us-central1-b"
    kms_key_name = google_kms_crypto_key.bt_key658.id
    autoscaling_config {
      min_nodes  = 1
      max_nodes  = 5
      cpu_target = 50
    }
  }

  #   cluster {
  #     cluster_id   = "bt-instance-cluster-east"
  #     storage_type = "HDD"
  #     zone         = "us-east1-b"
  #     kms_key_name = google_kms_crypto_key.bt_key657.id
  #     autoscaling_config {
  #       min_nodes  = 1
  #       max_nodes  = 5
  #       cpu_target = 50
  #     }
  #   }
}

resource "google_bigtable_instance" "bt_prod_instance657" {
  name                = "bt-wf-instance657"
  deletion_protection = false

  cluster {
    cluster_id   = "bt-instance-cluster-central-b"
    storage_type = "HDD"
    zone         = "us-central1-b"
    kms_key_name = google_kms_crypto_key.bt_key658.id
    autoscaling_config {
      min_nodes  = 1
      max_nodes  = 5
      cpu_target = 50
    }
  }

  cluster {
    cluster_id   = "bt-instance-cluster-central-a"
    storage_type = "HDD"
    zone         = "us-central1-a"
    kms_key_name = google_kms_crypto_key.bt_key658.id
    autoscaling_config {
      min_nodes  = 1
      max_nodes  = 5
      cpu_target = 50
    }
  }
}
 