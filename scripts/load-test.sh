#!/usr/bin/env bash
#
# Load test script for the Flask app – triggers HPA scaling.
# Run in one terminal while watching HPA in another: kubectl get hpa -w
#
# Usage:
#   ./scripts/load-test.sh [URL] [DURATION_SEC]
#   ./scripts/load-test.sh                    # default: http://localhost:8080, 60s
#   ./scripts/load-test.sh http://localhost:80 120
#

set -e

URL="${1:-http://localhost:8080}"
DURATION="${2:-60}"

echo "Load test: $URL for ${DURATION}s"
echo "Watch HPA in another terminal: kubectl get hpa -w"
echo "Press Ctrl+C to stop early."
echo ""

end_time=$((SECONDS + DURATION))
count=0

while [ $SECONDS -lt $end_time ]; do
  curl -s -o /dev/null -w "" "$URL" &
  curl -s -o /dev/null -w "" "$URL/health" &
  count=$((count + 2))
  # Limit concurrent curls to avoid overwhelming the shell
  if [ $((count % 20)) -eq 0 ]; then
    wait
  fi
done

wait
echo ""
echo "Done. Sent ~$count requests."
