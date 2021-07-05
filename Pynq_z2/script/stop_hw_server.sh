#!/bin/bash
PID_FILE=$1
if [[ -f "$PID_FILE" ]]; then
  kill -INT -"$(cat "${PID_FILE}")"
  rm "$PID_FILE"
  echo killed hw_server
else
  echo no hw_server running
fi
