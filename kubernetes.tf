resource "yandex_kubernetes_cluster" "this" {
  name = "k8s-ha-three-zones"
  network_id = yandex_vpc_network.my-ha-net.id
  master {
    public_ip = true
    master_location {
      zone      = yandex_vpc_subnet.mysubnet-a.zone
      subnet_id = yandex_vpc_subnet.mysubnet-a.id
    }
    /*master_location {
      zone      = yandex_vpc_subnet.mysubnet-b.zone
      subnet_id = yandex_vpc_subnet.mysubnet-b.id
    }
    master_location {
      zone      = yandex_vpc_subnet.mysubnet-d.zone
      subnet_id = yandex_vpc_subnet.mysubnet-d.id
    }*/
    security_group_ids = [yandex_vpc_security_group.ha-k8s-sg.id]
  }

  service_account_id      = yandex_iam_service_account.ha-k8s-account.id
  node_service_account_id = yandex_iam_service_account.ha-k8s-account.id
  depends_on = [
    yandex_resourcemanager_folder_iam_member.k8s-clusters-agent,
    yandex_resourcemanager_folder_iam_member.vpc-public-admin,
    yandex_resourcemanager_folder_iam_member.images-puller,
    yandex_resourcemanager_folder_iam_member.encrypterDecrypter
  ]
  kms_provider {
    key_id = yandex_kms_symmetric_key.kms-key.id
  }
}


resource "yandex_iam_service_account" "ha-k8s-account" {
  name        = "ha-k8s-account"
  description = "Service account for the highly available Kubernetes cluster"
}

resource "yandex_resourcemanager_folder_iam_member" "k8s-clusters-agent" {
  # Сервисному аккаунту назначается роль "k8s.clusters.agent".
  folder_id = var.folder_id
  role      = "k8s.clusters.agent"
  member    = "serviceAccount:${yandex_iam_service_account.ha-k8s-account.id}"
}

resource "yandex_resourcemanager_folder_iam_member" "vpc-public-admin" {
  # Сервисному аккаунту назначается роль "vpc.publicAdmin".
  folder_id = var.folder_id
  role      = "vpc.publicAdmin"
  member    = "serviceAccount:${yandex_iam_service_account.ha-k8s-account.id}"
}

resource "yandex_resourcemanager_folder_iam_member" "images-puller" {
  # Сервисному аккаунту назначается роль "container-registry.images.puller".
  folder_id = var.folder_id
  role      = "container-registry.images.puller"
  member    = "serviceAccount:${yandex_iam_service_account.ha-k8s-account.id}"
}

resource "yandex_resourcemanager_folder_iam_member" "encrypterDecrypter" {
  # Сервисному аккаунту назначается роль "kms.keys.encrypterDecrypter".
  folder_id = var.folder_id
  role      = "kms.keys.encrypterDecrypter"
  member    = "serviceAccount:${yandex_iam_service_account.ha-k8s-account.id}"
}

resource "yandex_resourcemanager_folder_iam_member" "lb-admin" {
  # Сервисному аккаунту назначается роль "load-balancer.admin" для создания балансировщика.
  folder_id = var.folder_id
  role      = "load-balancer.admin"
  member    = "serviceAccount:${yandex_iam_service_account.ha-k8s-account.id}"
}

resource "yandex_kms_symmetric_key" "kms-key" {
  # Ключ Yandex Key Management Service для шифрования важной информации, такой как пароли, OAuth-токены и SSH-ключи.
  name              = "kms-key"
  default_algorithm = "AES_128"
  rotation_period   = "8760h" # 1 год.
}


resource "yandex_kubernetes_node_group" "workers" {
  cluster_id  = yandex_kubernetes_cluster.this.id
  name        = var.node_group_name

  instance_template {
    platform_id = var.node_platform_id
    resources {
      cores  = var.node_cores
      memory = var.node_memory_gb
      core_fraction = var.core_fraction
    }
    container_runtime {
      type = "containerd"
    }
    boot_disk {
      type = "network-hdd"
      size = var.node_disk_gb
    }
    network_interface {
      nat                = true
      security_group_ids = [yandex_vpc_security_group.ha-k8s-sg.id]
      subnet_ids         = [
        yandex_vpc_subnet.mysubnet-a.id,
        //yandex_vpc_subnet.mysubnet-b.id,
        //yandex_vpc_subnet.mysubnet-d.id,
      ]
    }
    scheduling_policy {
      preemptible = var.preemptible
    }
    metadata = {
      ssh-keys = "${var.ssh_username}:${var.ssh_public_key}"
    }
  }

  scale_policy {
    fixed_scale {
      size = var.node_group_size
    }
  }

  # Явно зададим зоны размещения для кластера
  allocation_policy {
    location { zone = "ru-central1-a" }
    //location { zone = "ru-central1-b" }
    //location { zone = "ru-central1-d" }
  }

}

output "managed_k8s_cluster_id" {
  value       = yandex_kubernetes_cluster.this.id
  description = "ID Managed Kubernetes кластера"
}

output "managed_k8s_node_group_id" {
  value       = yandex_kubernetes_node_group.workers.id
  description = "ID группы узлов"
}


