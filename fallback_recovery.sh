#!/bin/sh
# ============================================================
# fallback_recovery.sh
# ============================================================

INTERVAL=30
API="http://192.168.11.1:9090"
GROUPS="HK=HK-AutoTest JP=JP-AutoTest TW=TW-AutoTest SG=SG-AutoTest US=US-AutoTest"

logger -t fallback_recovery "Started, using API: $API"

while true; do
  for pair in $GROUPS; do
    FALLBACK_NAME="${pair%=*}"
    AUTOTEST_NAME="${pair#*=}"

    ALIVE=$(curl -s --connect-timeout 2 "$API/proxies/$AUTOTEST_NAME" | grep -o '"alive":[a-z]*' | head -1 | cut -d: -f2)
    FIXED=$(curl -s --connect-timeout 2 "$API/proxies/$FALLBACK_NAME" | grep -o '"fixed":"[^"]*"' | cut -d'"' -f4)

    if [ "$ALIVE" = "true" ] && [ "$FIXED" != "$AUTOTEST_NAME" ]; then
      curl -s -X PUT "$API/proxies/$FALLBACK_NAME" \
        -H "Content-Type: application/json" \
        -d "{\"name\":\"$AUTOTEST_NAME\"}" > /dev/null 2>&1
      logger -t fallback_recovery "$FALLBACK_NAME: recovered, fixed -> $AUTOTEST_NAME"

    elif [ "$ALIVE" != "true" ] && [ "$FIXED" != "AUTO" ]; then
      curl -s -X PUT "$API/proxies/$FALLBACK_NAME" \
        -H "Content-Type: application/json" \
        -d '{"name":"AUTO"}' > /dev/null 2>&1
      logger -t fallback_recovery "$FALLBACK_NAME: down, fixed -> AUTO"
    fi
  done

  sleep $INTERVAL
done
