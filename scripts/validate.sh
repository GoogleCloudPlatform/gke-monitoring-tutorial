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
# "-  Validation script checks if demo application         -"
# "-  deployed successfully.                               -"
# "-                                                       -"
# "---------------------------------------------------------"

# Do not set exit on error, since the rollout status command may fail
set -o nounset
set -o pipefail

ROOT="$( cd "$( dirname "${BASH_SOURCE[0]}" )/.." && pwd )"
# shellcheck source=scripts/common.sh
source "$ROOT/scripts/common.sh"

APP_NAME=$(kubectl get deployments -n default \
  -ojsonpath='{.items[0].metadata.labels.app}')
APP_MESSAGE="deployment \"$APP_NAME\" successfully rolled out"

cd "$ROOT/terraform" || exit; CLUSTER_NAME=$(terraform output cluster_name) \
  ZONE=$(terraform output primary_location)

# Get credentials for the k8s cluster
gcloud container clusters get-credentials "$CLUSTER_NAME" --zone="$ZONE"

SUCCESSFUL_ROLLOUT=false
for _ in {1..30}; do
  ROLLOUT=$(kubectl rollout status -n default \
    --watch=false deployment/"$APP_NAME") &> /dev/null
  if [[ $ROLLOUT = *"$APP_MESSAGE"* ]]; then
    SUCCESSFUL_ROLLOUT=true
    break
  fi
  sleep 2
done

if [ "$SUCCESSFUL_ROLLOUT" = false ]
then
  echo "ERROR - Application failed to deploy"
  exit 1
fi

echo "App is deployed."
