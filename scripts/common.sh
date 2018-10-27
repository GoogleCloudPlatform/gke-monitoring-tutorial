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
# "-  Common commands for all scripts                      -"
# "-                                                       -"
# "---------------------------------------------------------"

# gcloud and kubectl are required for this demo
command -v gcloud >/dev/null 2>&1 || { \
 echo >&2 "I require gcloud but it's not installed.  Aborting."; exit 1; }

command -v kubectl >/dev/null 2>&1 || { \
 echo >&2 "I require kubectl but it's not installed.  Aborting."; exit 1; }


# wait_for_service_okay() - Wait for a server at given url to respond with a 200 status code at  a
# given endpoint.  It will periodically retry until the MAX_COUNT*SLEEP is exceeded.
# Usage:
#  wait_for_service_okay <url>
# Where:
#   <url> is of the form 'http://<ip-address>:<port>'
# Returns:
#   0 - when the server responds with a 200 status code
#   1 - when timed out or a non 200 status code is returned

# wait until the service returns 200
function wait_for_service_okay() {
  # Define retry constants
  local -r MAX_COUNT=60
  local RETRY_COUNT=0
  local -r SLEEP=2
  local -r url=$1
  local STATUS_CODE
  # Curl for the service with retries
  STATUS_CODE=$(curl -s -o /dev/null -w '%{http_code}' "$url")
  until [[ $STATUS_CODE -eq 200 ]]; do
      if [[ "${RETRY_COUNT}" -gt "${MAX_COUNT}" ]]; then
        # failed with retry, lets check whatz wrong and bail
        echo "Retry count exceeded. Exiting..."
        # Timed out?
        if [ -z "$STATUS_CODE" ]
        then
            echo "ERROR - Timed out waiting for service"
            exit 1
        fi
        # HTTP status not okay?
        if [ "$STATUS_CODE" != "200" ]
        then
            echo "ERROR - Service is returning error"
            exit 1
        fi
        exit 1
      fi
      NUM_SECONDS="$(( RETRY_COUNT * SLEEP ))"
      echo "Waiting for service availability..."
      echo "service / did not return an HTTP 200 response code after ${NUM_SECONDS} seconds"
      sleep "${SLEEP}"
      RETRY_COUNT="$(( RETRY_COUNT + 1 ))"
      STATUS_CODE=$(curl -s -o /dev/null -w '%{http_code}' "$EXT_IP:$EXT_PORT/")
  done
  # returns the status (0-255) only
  return 0
}