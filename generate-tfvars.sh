#!/bin/bash -e

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
# "-  Helper script to generate terraform variables        -"
# "-  file based on glcoud defaults.                       -"
# "-                                                       -"
# "---------------------------------------------------------"

# This script will write the terraform.tfvars file into the current working directory.
# The purpose is to populate defaults for subsequent terraform commands.

# git is required for this tutorial
command -v git >/dev/null 2>&1 || { \
 echo >&2 "I require git but it's not installed.  Aborting."; exit 1; }

# glcoud is required for this tutorial
command -v gcloud >/dev/null 2>&1 || { \
 echo >&2 "I require gcloud but it's not installed.  Aborting."; exit 1; }


REGION=$(gcloud config get-value compute/region)
if [[ -z "${REGION}" ]]; then
    echo "https://cloud.google.com/compute/docs/regions-zones/changing-default-zone-region" 1>&2
    echo "gcloud cli must be configured with a default region." 1>&2
    echo "run 'gcloud config set compute/region REGION'." 1>&2
    echo "replace 'REGION' with the region name like us-west1." 1>&2
    exit 1;
fi

ZONE=$(gcloud config get-value compute/zone)
if [[ -z "${ZONE}" ]]; then
    echo "https://cloud.google.com/compute/docs/regions-zones/changing-default-zone-region" 1>&2
    echo "gcloud cli must be configured with a default zone." 1>&2
    echo "run 'gcloud config set compute/zone ZONE'." 1>&2
    echo "replace 'ZONE' with the zone name like us-west1-a." 1>&2
    exit 1;
fi

PROJECT=$(gcloud config get-value core/project)
if [[ -z "${PROJECT}" ]]; then
    echo "gcloud cli must be configured with a default project." 1>&2
    echo "run 'gcloud config set core/project PROJECT'." 1>&2
    echo "replace 'PROJECT' with the project name." 1>&2
    exit 1;
fi

TFVARS_FILE="./terraform.tfvars"

if [[ -f "${TFVARS_FILE}" ]]
then
    echo "${TFVARS_FILE} already exists." 1>&2
    echo "Please remove or rename before regenerating." 1>&2
    exit 1;
else
    cat <<EOF > "${TFVARS_FILE}"
project="${PROJECT}"
zone="${ZONE}"
EOF
fi

