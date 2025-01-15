#!/bin/bash

# Get the current date
file_name="$(date "+%Y-%m-%d").json"

# Login and unlock Bitwarden
bw config server "${BW_SERVER}"
bw login --apikey
export BW_SESSION=$(bw unlock --passwordenv BW_PASSWORD --raw)

# Export the vault
bw export --format encrypted_json --password "${BW_PASSWORD}" --output "${file_name}"

# Upload the file to WebDAV
curl -T "${file_name}" -u "${WEBDAV_USERNAME}:${WEBDAV_PASSWORD}" "${WEBDAV_URL}${file_name}"

# Delete old export from WebDAV (7 days ago)
old_file_name="$(date +"%Y-%m-%d" --date="7 days ago").json"
curl -X DELETE -u "${WEBDAV_USERNAME}:${WEBDAV_PASSWORD}" "${WEBDAV_URL}${old_file_name}"

# Clean up local file
rm "${file_name}"

# Logout Bitwarden
bw logout
