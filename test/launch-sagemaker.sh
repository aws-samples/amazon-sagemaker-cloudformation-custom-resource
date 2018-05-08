#! /bin/bash
aws cloudformation --region us-east-1 create-stack --stack-name my-sagemaker-stack \
  --template-url https://s3.amazonaws.com/aws-cfn-samples/sagemaker/custom-resource/sagemaker-custom-resource.yml \
  --parameters file://sagemaker-params.json \
  --capabilities "CAPABILITY_IAM" \
  --disable-rollback