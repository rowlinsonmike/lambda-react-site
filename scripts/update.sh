#! /bin/bash

cd ..

export $( grep -vE "^(#.*|\s*)$" .env )

aws lambda update-function-code --function-name "${NAME}" --zip-file fileb://deployment-package.zip

aws lambda update-function-configuration \
    --function-name "${NAME}" \
    --environment Variables={IP_RANGE="${IP_RANGE}"}