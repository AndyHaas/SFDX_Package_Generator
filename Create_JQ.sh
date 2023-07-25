#!/bin/bash
################################################################################
# Description: Salesforce Package Version Creation and Promotion Script
#
# This shell script automates the process of creating a new Salesforce package
# version and promoting it. It uses the Salesforce CLI (sfdx) to create the new
# package version, extracts the SubscriberPackageVersionId from the JSON response,
# and then promotes the package version using the extracted ID. Finally, it
# generates an install link for the package version.
#
# Author: Andy Haas 
#
# Created Date: 2023-07-25
# Last Modified Date: 2023-07-25
#
# Expected Results:
#   - The script will create a new Salesforce package version.
#   - If the package version creation is successful, it will promote the package.
#   - It will display loading messages to keep the user informed about the progress.
#   - Upon completion, it will generate an install link for the package version.
#
# Note: jq will need to be installed for this script to work.
# jq is a lightweight and flexible command-line JSON processor.
# It can be downloaded from https://stedolan.github.io/jq/download/.
#
# For Ubuntu/Debian-based systems:
#   sudo apt-get update
#   sudo apt-get install jq
#
# For CentOS/RHEL-based systems:
#   sudo yum install epel-release
#   sudo yum install jq
#
# For macOS using Homebrew:
#   brew install jq
#
################################################################################

# Check if jq is installed
function check_jq_installed() {
    if ! command -v jq &>/dev/null; then
        echo "jq not found. Please install jq to run this script."
        exit 1
    fi
}

# Function to increment the minor version in JSON file
function increment_minor_version() {
    echo "Incrementing the minor version in $1..."
    local json_file="$1"

    # Read the current version from the JSON file
    local current_version
    current_version=$(jq -r '.packageDirectories[0].versionNumber' "$json_file")

    # Split the version number into major, minor, and other parts
    local major minor other
    major=$(echo "$current_version" | cut -d. -f1)
    minor=$(echo "$current_version" | cut -d. -f2)
    other=$(echo "$current_version" | cut -d. -f3)

    # Increment the minor version
    ((minor++))

    # Create the new version string
    local new_version="${major}.${minor}.${other}.NEXT"

    # Update the JSON data with the new version using jq
    jq ".packageDirectories[0].versionNumber = \"$new_version\"" "$json_file" > "$json_file.tmp"
    mv "$json_file.tmp" "$json_file"

    echo "Updated $json_file with the new version: $new_version"
}

# Function to create a new Salesforce package version and get the SubscriberPackageVersionId
function create_package_version() {
    echo "Creating a new Salesforce package version..."
    response=$(sfdx force:package:version:create -p 0Ho5e000000wkULCAY -c -x -v milestoneDevHub -w 30 --json)
    status=$(echo "$response" | jq -r '.result.Status')
  
    if [ "$status" != "Success" ]; then
        echo "Error: Package version creation failed."
        echo "$response"
        exit 1
    fi

    subPkVers=$(echo "$response" | jq -r '.result.SubscriberPackageVersionId')
    echo "Package version created successfully."
    # echo "$response"
}

# Function to promote the package using the SubscriberPackageVersionId
function promote_package_version() {
    echo "Promoting the package version..."
    response=$(sfdx force:package:version:promote -p "$subPkVers" -v milestoneDevHub --json)
    echo "Package version promoted successfully."
    # echo "$response"
}

# Call the functions
check_jq_installed
increment_minor_version "sfdx-project.json"
create_package_version
promote_package_version

# Extract the result.id for creating an install link
install_link=$(echo "$response" | jq -r '.result.id')
echo "Install link: https://login.salesforce.com/packaging/installPackage.apexp?p0=$install_link"
