#! /bin/bash

cd ..

export $( grep -vE "^(#.*|\s*)$" .env )

aws iam create-role --role-name "${NAME}_role" --assume-role-policy-document file://scripts/lambda_trust_policy.json
sleep 5
aws iam attach-role-policy --role-name "${NAME}_role" --policy-arn arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole

aws lambda create-function --function-name "${NAME}" \
--zip-file fileb://deployment-package.zip --handler lambda_function.handler --runtime python3.12 --role "arn:aws:iam::${ACCOUNT}:role/${NAME}_role" --timeout 30  --environment Variables={IP_RANGE="${IP_RANGE}"}
sleep 5
aws lambda create-function-url-config \
    --function-name $NAME \
    --auth-type NONE \
    --cors '{"AllowOrigins": ["*"], "AllowMethods": ["*"], "AllowHeaders": ["*"], "AllowCredentials": false}'
aws lambda add-permission \
    --function-name $NAME \
    --statement-id FunctionURLAllowPublicAccess \
    --action lambda:InvokeFunctionUrl \
    --principal "*" \
    --function-url-auth-type NONE \