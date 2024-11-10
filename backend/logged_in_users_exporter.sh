#!/bin/bash
# Textfile directory for Node Exporter (adjust if your path differs)
OUTPUT_FILE="/var/lib/node_exporter/textfile_collector/logged_in_users.prom"

# Initialize the output file
> "$OUTPUT_FILE"

# Iterate over each unique logged-in user session of class 'user'
while read -r session_id user uid state; do
    # Determine if the session state is "locked" or "unlocked"
    if [[ "$state" == "active" ]]; then
        locked_status="locked"
    else
        locked_status="unlocked"
    fi

    # Append metric to the output file in Prometheus format
    echo "node_logged_in_user{name=\"$user\", uid=\"$uid\", state=\"$locked_status\"} 1" >> "$OUTPUT_FILE"
done < <(
    # List sessions and filter by class 'user', outputting session ID, user name, UID, and state
    loginctl list-sessions --no-legend | awk '$4 == "user" {print $1, $2, $3, $5}'
)
