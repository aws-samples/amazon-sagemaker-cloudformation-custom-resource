## Amazon Sagemaker Cloudformation Custom Resource

Deploy Amazon SageMaker notebook using CloudFormation custom resource

## Overview

Currently it is not possible to launch an Amazon SageMaker notebook directly as a CloudFormation resource. In this blog post, I show you how to launch an Amazon SageMaker notebook using a CloudFormation custom resource, which allows you to write custom provisioning logic in templates that AWS CloudFormation runs any time you create, update, or delete stacks.  
 
## Deployment steps
You can use the AWS CloudFormation console or the AWS CLI to launch the provided CloudFormation template. The following tables list the required and optional parameters for launching the template.

### Required Amazon SageMaker parameters:

|Parameter label (name) | Default |	Description |
|---|---      | --- |
|Notebook Instance Name (NotebookInstanceName)	| Requires input |	Amazon SageMaker notebook instance name | 
|Notebook Instance Type (NotebookInstanceType) |	ml.t2.medium |	Select Instance type for the Amazon SageMaker notebook | 
|SageMaker IAM Role (SageMakerRoleArn) |	Optional |	ARN of the SageMaker IAM execution role. If you don't specify a role, a new role is created with the AmazonSageMakerFullAccess managed policy and access is provided to SageMakerS3Bucket, if provided.|

### Optional SageMaker Parameters:  

|Parameter label (name) |	Default |	Description |
|---                    |---        |---            |
|Default Internet Access (DirectInternetAccess) |	Enabled |	Not yet available to custom resource. Sets whether Amazon SageMaker notebook instance has internet access. If you set this to Disabled this notebook instance will be able to access resources only in your VPC. This is used only if SubnetId is not empty. |
|Subnet Id (SubnetId) |	Optional | 	The ID of the subnet in a VPC to which you want to have connectivity from your ML compute instance. | 
|Security Group Id (SecurityGroupId) |	Optional |	The VPC security group IDs, in the form sg-xxxxxxxx. The security groups must be for the same VPC as specified in the subnet. | 
|SageMaker S3 Bucket (SageMakerS3Bucket) |	Optional |	Name of a pre-existing bucket to which Amazon SageMaker will be granted full access | 
|KMS Key Id (KMSKeyId)  |	Optional	| AWS KMS key ID used to encrypt data at rest on the ML storage volume attached to notebook instance. | 
|Lifecycle Config Name (LifecycleConfigName) | 	Optional | Not yet available to custom resource. Notebook lifecycle configuration to associate with the notebook instance. | 


Launching a SageMaker notebook requires three mandatory parameters:  
* Notebook Instance Name, 
* Notebook Instance Type, and 
* IAM Role for the notebook instance. 

This CloudFormation template requires only the first one. Instance type defaults to ml.t2.medium. If you specify an IAM role, that role is used, otherwise, a new role is created with the AmazonSageMakerFullAccess policy attached and an additional inline policy that provides access to the SageMakerS3Bucket if the parameter is not blank.	

**Note:** Two new parameters, Lifecycle Config Name and Direct Internet Access, have been recently added to Amazon SageMaker. However, these parameters are not available to CloudFormation custom resource at this time. At the time of this writing, setting these two parameter values will have no effect. However the AWS Lambda code embedded in the template contains lines that have been commented out. These lines can be uncommented in the future when the feature becomes available.

### Launching the template from the AWS CloudFormation Console
Upload the provided [CloudFormation template](templates/sagemaker-custom-resource.yaml) to your Amazon S3 bucket or re-use the provided [launch template][1] link.

### Launching the template using the AWS CLI

From the AWS CLI, execute the following command, substituting the stack name, notebook instance name, and, optionally, modifying the template URL to launch the CloudFormation stack.

```bash
aws cloudformation --region us-east-1 create-stack --stack-name <my-sagemaker-stack> \
  --template-url https://s3.amazonaws.com/aws-cfn-samples/sagemaker/custom-resource/sagemaker-custom-resource.yaml\
  --parameters ParameterKey=NotebookInstanceName,ParameterValue=<my-notebook> \
  --capabilities "CAPABILITY_IAM" \
  --disable-rollback
```

If you need to supply all the input parameters, it is easier to specify the parameters in a JSON input file and specify that as input, for example:

```bash
aws cloudformation --region us-east-1 create-stack --stack-name <my-sagemaker-stack> \
  --template-url https://s3.amazonaws.com/aws-cfn-samples/sagemaker/custom-resource/sagemaker-custom-resource.yaml \
  --parameters file://sagemaker-params.txt \
  --capabilities "CAPABILITY_IAM" \
  --disable-rollback
```

A sample sagemaker-params.txt is shown below:

```json 
[
    {
        "ParameterValue": "ml.t2.medium",
        "ParameterKey": "NotebookInstanceType"
    },
    {
        "ParameterValue": "sg-abcd1234",
        "ParameterKey": "SecurityGroupId"
    },
    {
        "ParameterValue": "subnet-abcd1234",
        "ParameterKey": "SubnetId"
    },
    {
        "ParameterValue": "my-sagemaker-notebook",
        "ParameterKey": "NotebookInstanceName"
    },
    {
        "ParameterValue": "my-s3-data-bucket",
        "ParameterKey": "SageMakerS3Bucket"
    }
]
```

## Testing the deployment
After the stack launch is complete, you can validate the deployment.

1.	In the AWS CloudFormation console, in the Outputs tab, verify that there is a ARN for the newly created notebook.
 
2.	Go to the AWS SageMaker console and verify that your SageMaker notebook has been created. 

**Note:** Initially the notebook is in Pending status when it is created. It may take up to 10 minutes for the notebook to show InService status before you can start using it.
 
3.	To access your notebook, choose the Open action link and verify access to the Jupyter notebook dashboard.
 
## Clean up
**Note:** The following procedure will delete your notebook. If you have done any meaningful work, remember to save it before proceeding.

1.	Delete the CloudFormation stack. This will stop the notebook.
 
2.	After the notebook is stopped, go to the SageMaker console, select the notebook, and select Delete from the Actions menu.
 
3.	Delete CloudWatch logs. The stack will create a CloudWatch log group with name that matched your CloudFormation stack. In the CloudWatch logs console, spot the log group and delete it.
 
[1]: https://s3.amazonaws.com/aws-cfn-samples/sagemaker/custom-resource/sagemaker-custom-resource.yaml

## License Summary

This sample code is made available under a modified MIT license. See the [LICENSE](LICENSE) file.
