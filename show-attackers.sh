#!/bin/bash

# Count the number of failed logins by IP address.
# If there are any IPs with over LIMIT failures, display the count, IP, and location

LIMIT='10'
LOG_FILE="${1}"

# Make sure a file was supplied as an argument
# -e is a file test operator to check if file exists, thus ! -e means if not existed
if [[ ! -e "${LOG_FILE}" ]]
then
  echo "Cannot open log file: ${LOG_FILE}" >&2
  exit 1
fi

# Displat the CSV header.
echo 'Count,IP,Location'

# Loop through the list of failed attempts and corresponding IP addresses.
grep Failed syslog | awk '{print $(NF - 3)}' | sort | uniq -c | sort -nr |\
while read COUNT IP
do
  # If the number of failed attempts is greater than the limit, display count, IP and location.
  if [[ "${COUNT}" -gt "${LIMIT}" ]]
  then
    # Check wether the system has geoiplookup tool or not.
    # If geoiplookup is not installed, just ignore to use it
    if type -a geoiplookup >/dev/null 2>&1; then
      LOCATION=$(geoiplookup ${IP} | awk -F ',' '{print $2}')
      echo "${COUNT},${IP},${LOCATION}"
    else
      echo "${COUNT},${IP},NULL"
    fi
  fi
done
exit 0