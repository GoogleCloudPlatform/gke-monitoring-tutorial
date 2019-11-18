/*
Copyright 2018 Google LLC

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

   https://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
*/

///////////////////////////////////////////////////////////////////////////////////////
// This configuration will create a GKE cluster that will be used for creating
// logs and metrics that will be leveraged by a Stackdriver Monitoring account.
///////////////////////////////////////////////////////////////////////////////////////

///////////////////////////////////////////////////////////////////////////////////////
// Create the primary cluster for this project.
///////////////////////////////////////////////////////////////////////////////////////
data "google_container_engine_versions" "gke_versions" {
  location = var.zone
}

// Create the GKE Cluster
resource "google_container_cluster" "primary" {
  name               = "stackdriver-monitoring-tutorial"
  location           = var.zone
  initial_node_count = 1
  min_master_version = data.google_container_engine_versions.gke_versions.latest_master_version

  # Enable the new Stackdriver Kubernetes Monitoring/Logging features
  monitoring_service = "monitoring.googleapis.com/kubernetes"
  logging_service    = "logging.googleapis.com/kubernetes"

  master_auth {
    # Best practice
    # Disable basic auth
    # Default behavior for new clusters in GKE 1.12
    username = ""
    password = ""

    client_certificate_config {
      # Best practice
      # Disable client cert
      # Default behavior for new clusters in GKE 1.12
      issue_client_certificate = false
    }
  }

  ip_allocation_policy {
    # Best practice
    # Enable VPC-native IPs for pods and services
    # Default behavior for new clusters in GKE 1.12
  }

  provisioner "local-exec" {
    command = "gcloud container clusters get-credentials ${google_container_cluster.primary.name} --zone ${google_container_cluster.primary.location} --project ${var.project}"
  }

  provisioner "local-exec" {
    command = "kubectl -n default apply -f ../manifests/rbac-setup.yaml --as=admin --as-group=system:masters"
  }

  provisioner "local-exec" {
    command = "kubectl -n default apply -f ../manifests/prometheus-service-sed.yaml"
  }

  provisioner "local-exec" {
    command = "sleep 120"
  }
}

resource "google_monitoring_alert_policy" "prometheus_mem_alloc" {
  display_name = "Prometheus mem alloc"
  combiner     = "OR"
  enabled      = true
  conditions {
    display_name = "mem alloc above 12"
    condition_threshold {
      filter          = "metric.type=\"custom.googleapis.com/go_memstats_alloc_bytes\" AND resource.type=\"k8s_container\""
      duration        = "60s"
      comparison      = "COMPARISON_GT"
      threshold_value = 12
    }
  }
  depends_on = [google_container_cluster.primary]
}

resource "google_project_service" "monitoring" {
  service            = "monitoring.googleapis.com"
  disable_on_destroy = false
}

resource "google_project_service" "container" {
  service            = "container.googleapis.com"
  disable_on_destroy = false
}

resource "google_project_service" "logging" {
  service            = "logging.googleapis.com"
  disable_on_destroy = false
}
