#!/bin/bash


aws_profile="eb-cli"
if [[ -z "${REDFLAG_EB_ENV_NAME}" ]]; then
    echo "EB env not found"
    exit 1
else
    auto_scaling_group_name=$(aws elasticbeanstalk describe-environment-resources --profile "$aws_profile" --environment-name "${REDFLAG_EB_ENV_NAME}" | jq -r '.EnvironmentResources.AutoScalingGroups[0].Name')

    if [ -z "$auto_scaling_group_name" ]; then
        echo "Auto Scaling Group Name not found"
        exit 1
    else
        echo "Auto Scaling Group Name found: $auto_scaling_group_name"
        policies=`aws autoscaling describe-policies --auto-scaling-group-name "$auto_scaling_group_name" --profile "$aws_profile"`

        for row in $(echo "${policies}" | jq -r '.ScalingPolicies[] | @base64'); do
            _jq() {
             echo ${row} | base64 --decode | jq -r ${1}
            }
            policy_name=$(_jq '.PolicyName')
            aws autoscaling delete-policy --auto-scaling-group-name $auto_scaling_group_name --policy-name $policy_name --profile "$aws_profile"
        done
    fi
fi
