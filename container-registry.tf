# Yandex Container Registry
resource "yandex_container_registry" "this" {
  name      = "diplom-registry"
  folder_id = var.folder_id
}

# IAM roles for Container Registry access
resource "yandex_resourcemanager_folder_iam_member" "registry_pusher" {
  folder_id = var.folder_id
  role      = "container-registry.images.pusher"
  member    = "serviceAccount:${yandex_iam_service_account.ha-k8s-account.id}"
}

resource "yandex_resourcemanager_folder_iam_member" "registry_puller" {
  folder_id = var.folder_id
  role      = "container-registry.images.puller"
  member    = "serviceAccount:${yandex_iam_service_account.ha-k8s-account.id}"
}

# Outputs for Container Registry
output "container_registry_id" {
  value       = yandex_container_registry.this.id
  description = "ID Container Registry"
}

output "container_registry_name" {
  value       = yandex_container_registry.this.name
  description = "Name Container Registry"
}

output "container_registry_url" {
  value       = yandex_container_registry.this.id
  description = "Registry URL (cr.yandex.net/REGISTRY_ID)"
}
