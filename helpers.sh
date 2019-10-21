#!/bin/bash

function new_lab_user {
    if [[ $# -ne 2 ]]; then
        echo "$0 requires the following arguments (expected 2, got $#):" >&2
        echo "user password" >&2
        exit 1
    fi
    user=$1
    password=$2
    az ad user create --display-name $user \
        --password $password \
        --user-principal-name $user \
        --force-change-password-next-login
}

function get_lab_policy_components {
    if [[ $# -ne 1 ]]; then
        echo "$0 requires the following arguments (expected 1, got $#):" >&2
        echo "file" >&2
        exit 1
    fi
    file=$1
    jq ".policyRule" < $file > $tmp_dir/policy.json
    jq ".permissions" < $file > $tmp_dir/permissions.json
    jq ".parameters" < $file > $tmp_dir/parameters.json
    jq ".parameters_values" < $file > $tmp_dir/values.json
}

function write_custom_role_file {
    if [[ $# -ne 1 ]]; then
        echo "$0 requires the following arguments (expected 1, got $#):" >&2
        echo "scope" >&2
        exit 1
    fi
    scope=$1

    jq --arg n "$RoleDefinitionName" --arg d "Lab Role" --arg s "$scope" '.[0] + {name:$n,description:$d,assignableScopes:[$s]}' \
    < $tmp_dir/permissions.json \
    > $tmp_dir/role.json
}

