resource "yandex_vpc_network" "my-ha-net" {
  name = "my-ha-net"
}

resource "yandex_vpc_subnet" "mysubnet-a" {
  name = "mysubnet-a"
  v4_cidr_blocks = ["10.5.0.0/16"]
  zone           = "ru-central1-a"
  network_id     = yandex_vpc_network.my-ha-net.id
}

resource "yandex_vpc_subnet" "mysubnet-b" {
  name = "mysubnet-b"
  v4_cidr_blocks = ["10.6.0.0/16"]
  zone           = "ru-central1-b"
  network_id     = yandex_vpc_network.my-ha-net.id
}

resource "yandex_vpc_subnet" "mysubnet-d" {
  name = "mysubnet-d"
  v4_cidr_blocks = ["10.7.0.0/16"]
  zone           = "ru-central1-d"
  network_id     = yandex_vpc_network.my-ha-net.id
}

resource "yandex_vpc_security_group" "ha-k8s-sg" {
  name        = "ha-k8s-sg"
  description = "Правила группы обеспечивают базовую работоспособность кластера Managed Service for Kubernetes. Примените ее к кластеру и группам узлов."
  network_id  = yandex_vpc_network.my-ha-net.id
  # SSH
  ingress {
    protocol       = "TCP"
    description    = "SSH"
    port           = 22
    v4_cidr_blocks = ["0.0.0.0/0"]
  }

  # Kubernetes API (6443)
  ingress {
    protocol       = "TCP"
    description    = "Kubernetes API"
    port           = 6443
    v4_cidr_blocks = ["0.0.0.0/0"]
  }

  # App port (80)
  ingress {
    protocol       = "TCP"
    description    = "App port"
    port           = 80
    v4_cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    protocol          = "TCP"
    description       = "Правило разрешает проверки доступности с диапазона адресов балансировщика нагрузки. Нужно для работы отказоустойчивого кластера Managed Service for Kubernetes и сервисов балансировщика."
    predefined_target = "loadbalancer_healthchecks"
    from_port         = 0
    to_port           = 65535
  }
  ingress {
    protocol          = "ANY"
    description       = "Правило разрешает взаимодействие мастер-узел и узел-узел внутри группы безопасности."
    predefined_target = "self_security_group"
    from_port         = 0
    to_port           = 65535
  }
  ingress {
    protocol          = "ANY"
    description       = "Правило разрешает взаимодействие под-под и сервис-сервис. Укажите подсети вашего кластера Managed Service for Kubernetes и сервисов."
    v4_cidr_blocks    = concat(yandex_vpc_subnet.mysubnet-a.v4_cidr_blocks, yandex_vpc_subnet.mysubnet-b.v4_cidr_blocks, yandex_vpc_subnet.mysubnet-d.v4_cidr_blocks)
    from_port         = 0
    to_port           = 65535
  }
  ingress {
    protocol          = "ICMP"
    description       = "Правило разрешает отладочные ICMP-пакеты из внутренних подсетей."
    v4_cidr_blocks    = ["10.0.0.0/8", "172.16.0.0/12", "192.168.0.0/16"]
  }
  ingress {
    protocol          = "TCP"
    description       = "Правило разрешает входящий трафик из интернета на диапазон портов NodePort. Добавьте или измените порты на нужные вам."
    v4_cidr_blocks    = ["0.0.0.0/0"]
    from_port         = 30000
    to_port           = 32767
  }
  egress {
    protocol          = "ANY"
    description       = "Правило разрешает весь исходящий трафик. Узлы могут связаться с Yandex Container Registry, Yandex Object Storage, Docker Hub и т. д."
    v4_cidr_blocks    = ["0.0.0.0/0"]
    from_port         = 0
    to_port           = 65535
  }
}
