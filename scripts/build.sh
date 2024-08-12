#! /bin/bash

cd ../src/client
npm run build
cd ../../prod
zip -r ../deployment-package.zip .
