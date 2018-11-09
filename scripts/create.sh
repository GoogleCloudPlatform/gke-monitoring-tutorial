#! /usr/bin/env bash

# Copyright 2018 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     https://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# "---------------------------------------------------------"
# "-                                                       -"
# "-  Creates cluster and deploys demo application         -"
# "-                                                       -"
# "---------------------------------------------------------"
set -o errexit
set -o nounset
set -o pipefail

ROOT="$( cd "$( dirname "${BASH_SOURCE[0]}" )/.." && pwd )"
# shellcheck source=scripts/common.sh
source "$ROOT/scripts/common.sh"

# Generate the variables to be used by Terraform
# shellcheck source=scripts/generate-tfvars.sh
"$ROOT/scripts/generate-tfvars.sh"

# sed the prometheus file for the project specific stuff
PROJECT=$(gcloud config get-value core/project)
CLUSTER_NAME="stackdriver-monitoring-tutorial"
ZONE=$(gcloud config get-value compute/zone)
sed -e "s/\\[PROJECT_ID\\]/$PROJECT/" \
-e "s/\\[CLUSTER_NAME\\]/$CLUSTER_NAME/" \
-e "s/\\[CLUSTER_ZONE\\]/$ZONE/" "$ROOT/manifests/prometheus-service.yaml" \
> "$ROOT/manifests/prometheus-service-sed.yaml"

# Enable any APIs we need
gcloud services enable compute.googleapis.com \
    container.googleapis.com \
    cloudbuild.googleapis.com \
    cloudresourcemanager.googleapis.com

# Initialize and run Terraform
(cd "$ROOT/terraform"; terraform init -input=false)
(cd "$ROOT/terraform"; terraform apply -input=false -auto-approve)
