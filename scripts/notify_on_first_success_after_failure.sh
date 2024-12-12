#!/usr/bin/env bash
set -euo pipefail

: "${BUILDKITE_BUILD_ID:?Need BUILDKITE_BUILD_ID}"
: "${BUILDKITE_API_TOKEN:?Need BUILDKITE_API_TOKEN}"
: "${SLACK_WEBHOOK_URL:?Need SLACK_WEBHOOK_URL}"
: "${ORG_SLUG:?Need ORG_SLUG}"
: "${PIPELINE_SLUG:?Need PIPELINE_SLUG}"

CURRENT_BUILD_STATE="${BUILDKITE_BUILD_STATE}"
CURRENT_BUILD_NUMBER="${BUILDKITE_BUILD_NUMBER}"

if [[ "$CURRENT_BUILD_NUMBER" -le 1 ]]; then
  echo "No previous build to compare, skipping notification."
  exit 0
fi

PREVIOUS_BUILD_NUMBER=$((CURRENT_BUILD_NUMBER - 1))

# Fetch the previous build’s details from the API
PREVIOUS_BUILD=$(curl -sS \
  -H "Authorization: Bearer $BUILDKITE_API_TOKEN" \
  "https://api.buildkite.com/v2/organizations/$ORG_SLUG/pipelines/$PIPELINE_SLUG/builds/$PREVIOUS_BUILD_NUMBER")

PREVIOUS_BUILD_STATE=$(echo "$PREVIOUS_BUILD" | jq -r '.state')

if [[ "$CURRENT_BUILD_STATE" == "passed" && "$PREVIOUS_BUILD_STATE" != "passed" ]]; then
  MESSAGE=":tada: The pipeline is passing again! Build #$CURRENT_BUILD_NUMBER succeeded after a previous failure."
  curl -X POST -H 'Content-type: application/json' \
       --data "$(jq -n --arg text "$MESSAGE" '{text: $text}')" \
       "$SLACK_WEBHOOK_URL"
  echo "Slack notification sent."
else
  echo "No notification needed. Current: $CURRENT_BUILD_STATE, Previous: $PREVIOUS_BUILD_STATE"
fi
