#!/usr/bin/env bash

az login

eval $(sed 's/^\$//' ./Variables.ps1)
source helpers.sh

# Create directory for policy, parameter, etc. files
tmp_dir=/tmp/$Lab
mkdir -p $tmp_dir

az group create --name $Lab --location $Region

new_lab_user $User $Pass

get_lab_policy_components './infrastructure/policy.json'

resourceGroupScope=$(az group show --name $Lab -o tsv --query id)
write_custom_role_file $resourceGroupScope

az role definition create --role-definition $tmp_dir/role.json
az role assignment create --assignee $User -g $Lab --role "$RoleDefinitionName"

defintion_id=$(az policy definition create -n $PolicyDefinitionName --display-name "Lab Policy" \
    --description "Lab policy" \
    --metadata "Category=Lab" \
    --rules $tmp_dir/policy.json \
    --params $tmp_dir/parameters.json \
    --mode "All" \
    -o tsv --query "id")
az policy assignment create -n $PolicyAssignmentName --display-name "Lab Policy Assignment" \
    --scope $resourceGroupScope \
    --policy $defintion_id \
    --params $tmp_dir/values.json

template_path="./infrastructure/arm-template.json"
if [ -e $template_path ]; then
    az group deployment create -g $Lab -n "lab-resources" --template-file $template_path
fi