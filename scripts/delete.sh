#! /bin/bash

cd ..

export $( grep -vE "^(#.*|\s*)$" .env )



# Extract the role name from the ARN
ROLE_NAME="${NAME}_role"

echo "Deleting Lambda function: $NAME"
# Delete the Lambda function
aws lambda delete-function-url-config --function-name $NAME
aws lambda delete-function --function-name $NAME

echo "Detaching policies from IAM role: $ROLE_NAME"

# List, detach, and delete all policies from the role
for POLICY_ARN in $(aws iam list-attached-role-policies --role-name $ROLE_NAME --query 'AttachedPolicies[*].PolicyArn' --output text); do
    POLICY_NAME=$(echo $POLICY_ARN | awk -F'/' '{print $NF}')
    
    echo "Detaching policy: $POLICY_NAME"
    aws iam detach-role-policy --role-name $ROLE_NAME --policy-arn $POLICY_ARN
    if [ $? -ne 0 ]; then
        echo "Error detaching policy $POLICY_NAME. Continuing to next policy."
        continue
    fi
    
    # Check if the policy is an AWS managed policy
    if [[ $POLICY_ARN != arn:aws:iam::aws:policy/* ]]; then
        echo "Deleting customer managed policy: $POLICY_NAME"
        aws iam delete-policy --policy-arn $POLICY_ARN
        if [ $? -ne 0 ]; then
            echo "Error deleting policy $POLICY_NAME. Continuing to next policy."
        fi
    else
        echo "Skipping deletion of AWS managed policy: $POLICY_NAME"
    fi
done


echo "Deleting IAM role: $ROLE_NAME"
# Delete the IAM role
aws iam delete-role --role-name $ROLE_NAME

echo "Lambda function and associated role have been deleted."