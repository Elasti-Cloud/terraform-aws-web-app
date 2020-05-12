# Terraform
Deployment of infrustructure and application artifacts for a web site

# Requirements
- AWS account and a user with programmatic access and Admin rights (required to create IAM roles)
- Terraform 0.12.x
- S3 bucket to host files for the upload to app servers
- AWS key-pair(s) kreated in the target region
- All variables that require values are in the terraform.tfvars file
- Jenkins configuration is out of scope for this project but it was tested with Blue Ocean and Pipeline: aws plugins 
