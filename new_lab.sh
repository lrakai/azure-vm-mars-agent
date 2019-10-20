#!/usr/bin/env bash

az login

eval $(sed 's/^\$//' ./Variables.ps1)
source helpers.sh

# Create directory for policy, parameter, etc. files
tmp_dir=/tmp/$Lab
mkdir -p $tmp_dir

az group create --name $Lab --location $Region

get_lab_policy_components './infrastructure/policy.json'

new_lab_user $User $Pass

$resourceGroupScope=$(az group --name $Lab -o tsv --query 'ResourceId')
add_custom_role_field $resourceGroupScope