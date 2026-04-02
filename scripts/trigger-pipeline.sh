#!/bin/bash
set -e

if [ -f "$(dirname "$0")/../.env" ]; then
  source "$(dirname "$0")/../.env"
fi

if [ -z "$JENKINS_IP" ]; then
  read -rp "Jenkins IP: " JENKINS_IP
fi

JENKINS_URL="http://${JENKINS_IP}:32000"

COOKIE_JAR=$(mktemp)

CRUMB=$(curl -s --fail \
  "${JENKINS_URL}/crumbIssuer/api/json" \
  --user admin:admin \
  --cookie-jar "${COOKIE_JAR}" \
  | python3 -c "import sys,json; d=json.load(sys.stdin); print(d['crumbRequestField']+':'+d['crumb'])")

curl -X POST "${JENKINS_URL}/job/app-pipeline/build" \
  --user admin:admin \
  --header "${CRUMB}" \
  --cookie "${COOKIE_JAR}" \
  --fail --show-error

rm -f "${COOKIE_JAR}"

echo "Pipeline triggered on ${JENKINS_URL}"
