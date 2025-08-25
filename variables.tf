variable "cloud_id" {
  type        = string
  description = "ID облака"
}

variable "folder_id" {
  type        = string
  description = "ID папки"
}

variable "sa_key_file" {
  type        = string
  description = "Путь к JSON ключу сервисного аккаунта"
}

variable "default_zone" {
  type        = string
  description = "Зона по умолчанию"
  default     = "ru-central1-a"
}

variable "ssh_public_key" {
  type        = string
  description = "Содержимое публичного SSH ключа, который будет добавлен в ВМ"
}

variable "ssh_username" {
  type        = string
  description = "Пользователь для SSH входа на ВМ"
  default     = "ubuntu"
}

// удалены переменные для self-hosted VM кластера

variable "preemptible" {
  type        = bool
  description = "Использовать прерываемые ВМ для worker узлов"
  default     = true
}

# Managed Kubernetes
variable "k8s_cluster_name" {
  type        = string
  description = "Имя кластера Kubernetes (Yandex Managed)"
  default     = "diplom-regional"
}

variable "k8s_release_channel" {
  type        = string
  description = "Канал релизов (RAPID/STABLE/REGULAR)"
  default     = "REGULAR"
}

variable "k8s_network_policy_provider" {
  type        = string
  description = "Провайдер сетевых политик (CALICO/none)"
  default     = "CALICO"
}

variable "node_group_name" {
  type        = string
  description = "Имя группы узлов"
  default     = "ng-workers"
}

variable "node_group_size" {
  type        = number
  description = "Размер группы узлов"
  default     = 2
}

variable "node_cores" {
  type        = number
  description = "Количество vCPU на ноду"
  default     = 2
}

variable "node_memory_gb" {
  type        = number
  description = "ОЗУ на ноду (ГБ)"
  default     = 3
}

variable "core_fraction" {
  type        = number
  description = "Использование ядра"
  default     = 20
}


variable "node_disk_gb" {
  type        = number
  description = "Размер диска (ГБ)"
  default     = 20
}

variable "node_platform_id" {
  type        = string
  description = "Платформа нод (например standard-v3)"
  default     = "standard-v3"
}



