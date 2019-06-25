#### Deploy AWS Infrastructure
Clone this Terraform to deploy an AWS custom VPC. First setup S3 for remote tfstate.

###### Setup S3/Dynamo for tfstate remote locking

  - Create the credentials in /Scratch folder first
  - Setup profile if needed 
  - Run terraform init, plan and apply
```sh
$ cat /Scratch/sample-credentials
[default]
aws_access_key_id = AKIAUX6BYAL1234ABCD
aws_secret_access_key = SBXRYT+ZerojBrPay/m+dn5IT8xjkSLX+XJGadAw
region = us-west-2

[poweruser]
aws_access_key_id = AKIAUX6BYAL1234ABCD
aws_secret_access_key = SBXRYT+ZerojBrPay/m+dn5IT8xjkSLX+XJGadAw
region = us-west-2
```
###### Deploy Custom VPC
  - Rename backend.tf.ignore to backend.tf
  - Run terraform init, plan and apply
  
###### Destroy VPC in order
```sh
terraform destroy -auto-approve <vpc>
terrafrom destroy -auto-approve <s3-remote-state-bucket>
```