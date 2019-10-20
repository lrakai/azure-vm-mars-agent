#!/usr/bin/env bash

eval $(sed 's/^\$//' ./Variables.ps1)

resourceGroupScope=$(az group show --name $Lab -o tsv --query id)

az policy assignment delete --name $PolicyAssignmentName --scope $resourceGroupScope
az policy definition delete --name $PolicyDefinitionName 
az role assignment delete --assignee $User -g $Lab -role $RoleDefinitionName
az role definition delete --name $RoleDefinitionName --custom-role-only true
az ad user delete --id $User
az group delete --name $Lab --yes