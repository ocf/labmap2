#!/bin/bash
# Textfile directory for Node Exporter (adjust if your path differs)
OUTPUT_FILE="/var/lib/node_exporter/textfile_collector/logged_in_users.prom"

# Initialize the output file
> "$OUTPUT_FILE"

# Breaks down the loginctl output into rows for parsing
loginctl list-sessions --no-legend | while read -r session_id uid user seat leader class tty idle since; do
   if [[ $class == "user" ]]; then
      state=$(loginctl show-session "$session_id" -p State --value)
      if [[ $state == "active" ]]; then
         locked_status="unlocked"
      else
         locked_status="locked"
      fi
   echo "node_logged_in_user{name=\"$user\", state=\"$locked_status\"} 1" > $OUTPUT_FILE
   fi
done
