data "digitalocean_kubernetes_versions" "k8s_versions" {
  version_prefix = "${var.k8s_version}."
}

data "digitalocean_sizes" "valid_sizes" {
  filter {
    key    = "vcpus"
    values = var.node_cpu
  }

  filter {
    key    = "memory"
    values = var.node_memory
  }

  filter {
    key    = "regions"
    values = [var.region]
  }

  sort {
    key       = "price_monthly"
    direction = "asc"
  }
}

resource "digitalocean_kubernetes_cluster" "k8s_cluster" {
  name    = "${var.name}-${var.region}"
  region  = var.region
  version = data.digitalocean_kubernetes_versions.k8s_versions.latest_version

  node_pool {
    name       = "default"
    node_count = var.node_count
    size       = length(data.digitalocean_sizes.valid_sizes.sizes) > 0 ? element(data.digitalocean_sizes.valid_sizes.sizes, 0).slug : null
  }
}

output "cluster_name" {
  value = digitalocean_kubernetes_cluster.k8s_cluster.name
}

output "kubeconfig" {
  value     = digitalocean_kubernetes_cluster.k8s_cluster.kube_config.0.raw_config
  sensitive = true
}
