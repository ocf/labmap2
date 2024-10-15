#!/bin/bash
# Textfile directory for Node Exporter (adjust if your path differs)
OUTPUT_FILE="/var/lib/node_exporter/textfile_collector/logged_in_users.prom"

# Get the logged-in users and format as Prometheus metrics
who | awk '{print $1}' | sort | uniq | awk '{print "node_logged_in_user{name=\"" $1 "\"} 1"}' > $OUTPUT_FILE
