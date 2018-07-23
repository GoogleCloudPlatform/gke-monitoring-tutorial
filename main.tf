// Copyright 2018 Google LLC
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     https://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

///////////////////////////////////////////////////////////////////////////////////////
// This configuration will create a GKE cluster that will be used for creating
// logs and metrics that will be leveraged by a Stackdriver Monitoring account.
///////////////////////////////////////////////////////////////////////////////////////

///////////////////////////////////////////////////////////////////////////////////////
// Create the primary cluster for this project.
///////////////////////////////////////////////////////////////////////////////////////

// Create the GKE Cluster
resource "google_container_cluster" "primary" {
  name               = "stackdriver-monitoring-tutorial"
  zone               = "${var.zone}"
  initial_node_count = 2

  master_auth {
    username = "stackdrivertester"
    password = "sixteencharactersinlength"
  }

  node_config {
    oauth_scopes = [
      "https://www.googleapis.com/auth/compute",
      "https://www.googleapis.com/auth/devstorage.read_only",
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
    ]
  }

  provisioner "local-exec" {
    command = "gcloud container clusters get-credentials ${google_container_cluster.primary.name} --zone ${google_container_cluster.primary.zone} --project ${var.project}"
  }

  provisioner "local-exec" {
    command = "kubectl run hello-server4 --image gcr.io/google-samples/hello-app:1.0 --port 8080"
  }

  provisioner "local-exec" {
    command = "kubectl expose deployment hello-server4 --type \"LoadBalancer\" "
  }
}
