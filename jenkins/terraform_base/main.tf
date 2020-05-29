resource "google_container_cluster" "primary" {
  name     = var.project_id
  location = var.region

  remove_default_node_pool = true
  initial_node_count       = 1

  master_auth {
    username = ""
    password = ""

    client_certificate_config {
      issue_client_certificate = false
    }
  }
}

resource "google_container_node_pool" "primary_preemptible_nodes" {
  name       = "node-pool"
  location   = var.region
  cluster    = google_container_cluster.primary.name
  node_count = 1

  node_config {
    preemptible  = true
    machine_type = var.machine_type
    service_account = var.service_account

    metadata = {
      disable-legacy-endpoints = "true"
    }

    oauth_scopes = [
      "https://www.googleapis.com/auth/devstorage.read_only",
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring"
    ]
  }
}

resource "google_compute_instance" "default" {
  name         = var.vm_name
  machine_type = var.machine_type
  zone         = var.region //var.zones[0]

  boot_disk {
    initialize_params {
      image = "centos-cloud/centos-7"
    }
  }

  metadata = {
    ssh-keys = "${var.ssh_username}:${file(var.ssh_pub_key_path)}"
  }    

  network_interface {
    network = "default"

    access_config {
      // Include this section to give the VM an external ip address
    }
  }

    //metadata_startup_script = "sudo apt-get update && sudo apt-get install apache2 -y && echo '<!doctype html><html><body><h1>Avenue Code is the leading software consulting agency focused on delivering end-to-end development solutions for digital transformation across every vertical. We pride ourselves on our technical acumen, our collaborative problem-solving ability, and the warm professionalism of our teams.!</h1></body></html>' | sudo tee /var/www/html/index.html"

    // Apply the firewall rule to allow external IPs to access this instance
    //tags = ["http-server"]
}

resource "google_compute_firewall" "http-server" {
  name    = "default-allow-http-terraform"
  network = "default"

  allow {
    protocol = "tcp"
    ports    = ["22", "80", "8080"]
  }

  // Allow traffic from everywhere to instances with an http-server tag
  source_ranges = ["0.0.0.0/0"]
  //target_tags   = ["http-server"]
}

output "vm_ip" {
  value = "${google_compute_instance.default.network_interface.0.access_config.0.nat_ip}"
}