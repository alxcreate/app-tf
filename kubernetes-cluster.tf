resource "yandex_kubernetes_cluster" "kubernetes-cluster" {
  network_id = yandex_vpc_network.vpc-network.id
  master {
    regional {
      region = "ru-central1"
      location {
        zone      = yandex_vpc_subnet.subnet-a1.zone
        subnet_id = yandex_vpc_subnet.subnet-a1.id
      }
      location {
        zone      = yandex_vpc_subnet.subnet-b1.zone
        subnet_id = yandex_vpc_subnet.subnet-b1.id
      }
      location {
        zone      = yandex_vpc_subnet.subnet-c1.zone
        subnet_id = yandex_vpc_subnet.subnet-c1.id
      }
    }
    public_ip = true
  }
  service_account_id      = yandex_iam_service_account.sa-kubernetes.id
  node_service_account_id = yandex_iam_service_account.sa-kubernetes.id
  kms_provider {
    key_id = yandex_kms_symmetric_key.kms-key-kubernetes.id
  }
  depends_on = [
    yandex_resourcemanager_folder_iam_member.editor,
    yandex_resourcemanager_folder_iam_member.images-puller
  ]
}
# Группа нод в subnet-a1
resource "yandex_kubernetes_node_group" "kubernetes-nodes-a1" {
  cluster_id = yandex_kubernetes_cluster.kubernetes-cluster.id
  name       = "kubernetes-nodes-a1"
  allocation_policy {
    location {
      zone = yandex_vpc_subnet.subnet-a1.zone
    }
  }
  instance_template {
    platform_id = "standard-v1"
    name = "kubernetes-node-"
    network_interface {
      nat        = true
      subnet_ids = ["${yandex_vpc_subnet.subnet-a1.id}"]
    }
    resources {
      cores = 2
    }
    boot_disk {
      type = "network-hdd"
      size = 30
    }
    container_runtime {
      type = "containerd"
    }
  }
  scale_policy {
    fixed_scale {
      size = 1
    }
  }
}
# Группа нод в subnet-b1
resource "yandex_kubernetes_node_group" "kubernetes-nodes-b1" {
  cluster_id = yandex_kubernetes_cluster.kubernetes-cluster.id
  name       = "kubernetes-nodes-b1"
  allocation_policy {
    location {
      zone = yandex_vpc_subnet.subnet-b1.zone
    }
  }
  instance_template {
    platform_id = "standard-v1"
    name = "kubernetes-node-${instance.index}"
    network_interface {
      nat        = true
      subnet_ids = ["${yandex_vpc_subnet.subnet-b1.id}"]
    }
    resources {
      cores = 2
    }
    boot_disk {
      type = "network-hdd"
      size = 30
    }
    container_runtime {
      type = "containerd"
    }
  }
  scale_policy {
    fixed_scale {
      size = 1
    }
  }
}
# Группа нод в subnet-c1
resource "yandex_kubernetes_node_group" "kubernetes-nodes-c1" {
  cluster_id = yandex_kubernetes_cluster.kubernetes-cluster.id
  name       = "kubernetes-nodes-c1"
  allocation_policy {
    location {
      zone = yandex_vpc_subnet.subnet-c1.zone
    }
  }
  instance_template {
    platform_id = "standard-v1"
    name = "kubernetes-node-${instance.index}"
    network_interface {
      nat        = true
      subnet_ids = ["${yandex_vpc_subnet.subnet-c1.id}"]
    }
    resources {
      cores = 2
    }
    boot_disk {
      type = "network-hdd"
      size = 30
    }
    container_runtime {
      type = "containerd"
    }
  }
  scale_policy {
    fixed_scale {
      size = 1
    }
  }
}

resource "yandex_iam_service_account" "sa-kubernetes" {
  name        = "sa-kubernetes"
  description = "Service account for kubernetes cluster"
}

resource "yandex_resourcemanager_folder_iam_member" "editor" {
  folder_id = var.yc_folder_id
  role      = "editor"
  member    = "serviceAccount:${yandex_iam_service_account.sa-kubernetes.id}"
}

resource "yandex_resourcemanager_folder_iam_member" "images-puller" {
  folder_id = var.yc_folder_id
  role      = "container-registry.images.puller"
  member    = "serviceAccount:${yandex_iam_service_account.sa-kubernetes.id}"
}

resource "yandex_kms_symmetric_key" "kms-key-kubernetes" {
  name              = "kms-key-kubernetes"
  default_algorithm = "AES_128"
  rotation_period   = "8760h" # 1 год
}
