data "oci_containerengine_cluster_kube_config" "cluster_kube_config" {
  cluster_id    = "${oci_containerengine_cluster.cluster.id}"
  expiration    = 2592000
  token_version = "1.0.0"
}

resource "local_file" "cluster_kube_config_file" {
  content  = "${data.oci_containerengine_cluster_kube_config.cluster_kube_config.content}"
  filename = "kube_config_file.txt"
}

resource "oci_containerengine_cluster" "cluster" {
  compartment_id     = "${var.tenancy_ocid}"
  kubernetes_version = "${var.oke["version"]}"
  name               = "${var.oke["name"]}"
  vcn_id             = "${oci_core_virtual_network.virtual_network.id}"

  options {
    service_lb_subnet_ids = ["${oci_core_subnet.subnet.id}"]

    add_ons {
      is_kubernetes_dashboard_enabled = true
      is_tiller_enabled               = true
    }

    kubernetes_network_config {
      pods_cidr     = "10.244.0.0/16"
      services_cidr = "10.96.0.0/16"
    }
  }
}

resource "oci_containerengine_node_pool" "node_pool" {
  cluster_id          = "${oci_containerengine_cluster.cluster.id}"
  compartment_id      = "${var.tenancy_ocid}"
  kubernetes_version  = "${var.oke["version"]}"
  name                = "${var.oke["name"]}"
  node_image_name     = "Oracle-Linux-7.5"
  node_shape          = "${var.oke["shape"]}"
  subnet_ids          = ["${oci_core_subnet.subnet.id}"]
  quantity_per_subnet = "${var.oke["nodes"]}"
  ssh_public_key      = "${var.ssh_public_key}"
}
