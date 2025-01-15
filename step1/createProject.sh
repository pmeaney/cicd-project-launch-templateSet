#!/bin/bash

# Functional DevOps script for 1password and YAML injection.

# This "Step1" of the project will:
#  1. Automatically create a 1password vault ("ExperimentVault1")
#  2. Add secure config data:
#     - It Creates "ExperimentSecureNote1" of type "Secure Note" (represented by code "003")
#       For simplicity, it creates a SecureNote because SecureNotes just store a single value.
#       In the project's next step, we'll ask the user for a field name and a field value.
#       (Ultimately, this project's purpose is to streamline adding fields to both Github & 1password)
#     - and adds two items to it: "projectName" and "registryName"
#  3. Inject the config data into a YAML file"
#     - This just serves as a simplified example for the next step, which will be a Github Actions Yaml file.

# Project Introduction
projectIntro="Welcome to the Project Setup Script.  This process will automatically create a 1password vault, add secure config data, and inject the config data into a YAML file"
yamlFile="basic-yaml-env-subst.yml"

# Function: Display Welcome Message
display_welcome() {
    echo "$projectIntro"
}

# Function: Prompt User for Vault Selection or Creation
setup_vault() {
    local defaultVaultName="ExperimentVault1"
    echo "Step 1: 1Password Setup"
    echo "Would you like to use an existing vault or create a new one?"
    echo "1. Use an existing vault"
    echo "2. Create a new vault"
    read -p "Enter your choice (1 or 2): " vaultChoice

    if [[ "$vaultChoice" == "1" ]]; then
        echo "Fetching existing vaults..."
        op vault list --format json | jq -r '.[].name' | nl
        read -p "Select a vault number: " vaultNumber
        vaultName=$(op vault list --format json | jq -r --argjson num "$vaultNumber" '.[($num-1)].name')
    else
        read -p "Enter the new vault name (default: $defaultVaultName): " vaultName
        vaultName="${vaultName:-$defaultVaultName}"
        echo "Creating vault $vaultName..."
        op vault create "$vaultName"
    fi
    echo "Selected Vault: $vaultName"
}

# Function: Prompt User for Secure Note Details
create_secure_note() {
    local defaultSecureNoteName="ExperimentSecureNote1"
    read -p "Enter the Secure Note name (default: $defaultSecureNoteName): " secureNoteName
    secureNoteName="${secureNoteName:-$defaultSecureNoteName}"

    echo "Provide values for the fields:"
    read -p "Enter value for projectName: " projectName
    read -p "Enter value for registryName: " registryName

    echo "Creating Secure Note..."
    op item create \
        --category 003 \
        --title "$secureNoteName" \
        --vault "$vaultName" \
        "projectName[text]=$projectName" \
        "registryName[text]=$registryName"
    echo "Secure Note '$secureNoteName' created in vault '$vaultName'."
}

# Function: Inject Retrieved Fields into YAML
inject_into_yaml() {
    echo "Retrieving Secure Note fields..."
    local itemJson
    itemJson=$(op item get "$secureNoteName" --vault "$vaultName" --format json)
    local projectName
    projectName=$(echo "$itemJson" | jq -r '.fields[] | select(.label == "projectName") | .value')
    local registryName
    registryName=$(echo "$itemJson" | jq -r '.fields[] | select(.label == "registryName") | .value')

    echo "Injecting fields into YAML..."
    cat << EOF > "$yamlFile"
# $yamlFile

name: 1. build, publish, 2. login, pull, run.

on:
  push:
    branches:
      - main
      # - blah
env:
  REGISTRY: "$registryName"
  PROJECT_NAME: "$projectName"
EOF

    echo "Fields successfully injected into $yamlFile."
}

# Main Function to Orchestrate the Script Flow
main() {
    display_welcome
    setup_vault
    create_secure_note
    inject_into_yaml
    echo "All tasks completed successfully!"
}

# Run the Main Function
main
