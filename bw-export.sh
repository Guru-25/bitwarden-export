#!/bin/bash

# Get the current date
file_name="$(date "+%Y-%m-%d").json"

# Login and unlock Bitwarden
bw config server "${BW_SERVER}"
bw login --apikey
export BW_SESSION=$(bw unlock --passwordenv BW_PASSWORD --raw)

# Export the vault
bw export --format encrypted_json --password "${BW_PASSWORD}" --output "${file_name}"

# Dropbox Uploader configuration
echo "CONFIGFILE_VERSION=2.0" > ~/.dropbox_uploader
echo "OAUTH_APP_KEY=${dropbox_app_key}" >> ~/.dropbox_uploader
echo "OAUTH_APP_SECRET=${dropbox_app_secret}" >> ~/.dropbox_uploader
echo "OAUTH_REFRESH_TOKEN=${dropbox_refresh_token}" >> ~/.dropbox_uploader

# Download Dropbox Uploader script
curl -s "https://raw.githubusercontent.com/andreafabrizi/Dropbox-Uploader/master/dropbox_uploader.sh" -o dropbox_uploader.sh
chmod +x dropbox_uploader.sh

# Upload the file to Dropbox
./dropbox_uploader.sh upload "${file_name}.json" "${file_name}.json"

# Delete old export from Dropbox
./dropbox_uploader.sh delete "$(date +"%Y-%m-%d" --date="7 days ago").json"

# Clean up local files
rm "${file_name}"

# Logout Bitwarden
bw logout