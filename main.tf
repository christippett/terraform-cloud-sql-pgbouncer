locals {
  private_ip = google_compute_instance.pgbouncer.network_interface[0].network_ip
  public_ip  = length(google_compute_instance.pgbouncer.network_interface[0].access_config) > 0 ? google_compute_instance.pgbouncer.network_interface[0].access_config[0].nat_ip : null
}

/* Instance Configuration --------------------------------------------------- */

module "pgbouncer_cloud_init" {
  source = "./modules/pgbouncer_cloud_init"

  pgbouncer_image_tag = var.pgbouncer_image_tag
  listen_port         = var.port
  database_host       = var.database_host
  database_port       = 5432
  users               = var.users
  auth_user           = var.auth_user
  auth_query          = var.auth_query
  default_pool_size   = var.default_pool_size
  max_db_connections  = var.max_db_connections
  max_client_conn     = var.max_client_connections
  pool_mode           = var.pool_mode
  custom_config       = var.pgbouncer_custom_config
}

data "google_compute_image" "boot" {
  project = split("/", var.boot_image)[0]
  family  = split("/", var.boot_image)[1]
}

resource "google_compute_instance" "pgbouncer" {
  project      = var.project
  name         = var.name
  machine_type = var.machine_type
  zone         = var.zone
  tags         = var.tags

  dynamic "service_account" {
    for_each = var.disable_service_account ? [] : [1]
    content {
      email  = var.service_account_email
      scopes = var.service_account_scopes == null ? ["https://www.googleapis.com/auth/cloud-platform"] : var.service_account_scopes
    }
  }

  metadata = {
    google-logging-enabled = var.disable_service_account ? null : true
    user-data              = module.pgbouncer_cloud_init.cloud_config
  }

  boot_disk {
    initialize_params {
      image = data.google_compute_image.boot.self_link
    }
  }

  network_interface {
    subnetwork         = var.subnetwork
    subnetwork_project = var.project
    network_ip         = var.network_ip

    dynamic "access_config" {
      for_each = var.disable_public_ip ? [] : [1]
      content {
        nat_ip = var.public_ip_address
      }
    }
  }

  scheduling {
    automatic_restart = true
  }

  allow_stopping_for_update = true

  depends_on = [null_resource.module_depends_on]
}

/* Misc --------------------------------------------------------------------- */

# restart instance when users are updated, added or removed

resource "null_resource" "user_updater" {
  triggers = {
    users = join("", [for u in var.users : join("", values(u))])
  }
  provisioner "local-exec" {
    on_failure = continue
    command    = "gcloud compute instances reset --project '${var.project}' --zone '${var.zone}' '${google_compute_instance.pgbouncer.name}'"
  }
}

# inject external dependencies into module

resource "null_resource" "module_depends_on" {
  count = length(var.module_depends_on) > 0 ? 1 : 0

  triggers = {
    value = length(var.module_depends_on)
  }
}
