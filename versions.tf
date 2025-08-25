terraform {
  required_version = ">= 1.4.0"

  required_providers {
    yandex = {
      source  = "yandex-cloud/yandex"
      version = ">= 0.95.0"
    }
  }
}

provider "yandex" {
  service_account_key = var.sa_key
  cloud_id            = var.cloud_id
  folder_id           = var.folder_id
  zone                = var.default_zone
}


