#!/usr/bin/env bash

eval $(sed 's/^\$//' ./Variables.ps1)

az policy assignment delete --name "$PolicyAssignmentName" -g $Lab
az policy definition delete --name "$PolicyDefinitionName" 
az role assignment delete --assignee $User -g $Lab --role "$RoleDefinitionName"
az role definition delete --name "$RoleDefinitionName" --custom-role-only true
az ad user delete --id $User
az group delete --name $Lab --yes