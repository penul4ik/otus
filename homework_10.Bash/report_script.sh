#!/bin/bash

# Configuration
LOGFILE="/var/log/nginx/access.log"
EMAIL="test-7de2b6@test.mailgenius.com" # Destination E-Mail address
LOCKFILE="/tmp/report_script.lock"
TIMESTAMPFILE="/var/log/last_run_timestamp"

# Check if the script is already running
if [ -f "$LOCKFILE" ]; then
        echo "The script is already running."
        exit 1
fi

# Create a lockfile
touch $LOCKFILE

# Determine the time of the last launch
if [ -f "$TIMESTAMPFILE" ]; then
        LAST_RUN=$(cat $TIMESTAMPFILE)
else
        LAST_RUN=$(date +"%Y-%m-%d %H:%M:%S" -d "1 hour ago")
fi

# Save the current time for reuse
date +"%Y-%m-%d %H:%M:%S" > $TIMESTAMPFILE

# Get necessary inforamtion from logs
TOP_IPS=$(awk '{print $1}' $LOGFILE | sort | uniq -c | sort -rn | head)
TOP_URLS=$(awk '($9 >= 200 && $9 < 300) {print $7}' $LOGFILE | sort | uniq -c | sort -rn | head)
ERRORS=$(awk '($9 >= 500) {print $0}' $LOGFILE | tail)
HTTP_CODES=$(awk '{print $9}' $LOGFILE | sort | uniq -c | sort -rn)

# Send e-mail
echo -e "Report for the period from $LAST_RUN to $(date +"%Y-%m-%d %H:%M:%S") \n ============================= \n Top IPs "$TOP_IPS" \n ============================= \n Top URLs "$TOP_URLS" \n ============================= \n Errors "$ERRORS" \n ============================= \n HTTP requests "$HTTP_CODES"" | mail -s "Web-server report" $EMAIL

#Remove lockfile
rm -f $LOCKFILE