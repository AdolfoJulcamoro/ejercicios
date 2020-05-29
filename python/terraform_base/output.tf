output "gcp_cluster_endpoint" {
  value = "${google_container_cluster.cluster1.endpoint}"
}

output "gcp_cluster_name" {
  value = "${google_container_cluster.cluster1.name}"
}