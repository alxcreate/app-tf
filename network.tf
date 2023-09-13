resource "yandex_vpc_network" "vpc-network" {
  name = "vpc-network"
}
# Subnets for my-app
resource "yandex_vpc_subnet" "subnet-a1" {
  name           = "subnet-a1"
  zone           = "ru-central1-a"
  network_id     = yandex_vpc_network.vpc-network.id
  v4_cidr_blocks = ["10.0.1.0/24"]
}

resource "yandex_vpc_subnet" "subnet-b1" {
  name           = "subnet-b1"
  zone           = "ru-central1-b"
  network_id     = yandex_vpc_network.vpc-network.id
  v4_cidr_blocks = ["10.0.2.0/24"]
}

resource "yandex_vpc_subnet" "subnet-c1" {
  name           = "subnet-c1"
  zone           = "ru-central1-c"
  network_id     = yandex_vpc_network.vpc-network.id
  v4_cidr_blocks = ["10.0.3.0/24"]
}
