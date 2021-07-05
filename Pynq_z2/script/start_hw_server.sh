#!/bin/bash
HW_SERVER=$1
PID_FILE=$2
if [[ ! -f "$PID_FILE" ]]; then
  $HW_SERVER >/dev/null & echo "$$" > "$PID_FILE"
  echo started hw_server
else
  echo hw_server already running
fi
