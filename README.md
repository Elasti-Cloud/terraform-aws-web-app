# Terraform with AWS
Deployment of infrastructure and application artifacts for a web site

# Architectural diagram
![Architectural diagram](website_app.png)

# Requirements
* AWS account and a user with programmatic access and Admin rights _(required to create IAM roles)_
* Terraform <=0.12.6
* S3 bucket to host files for the upload to app servers _(can use a sample from a website_sample folder)_
* AWS key-pair(s) created in the target region
* All variables that require values are in the __terraform.tfvars__ file
* Jenkins configuration is out of scope for this project but it was tested with Blue Ocean and Pipeline: aws plugins 

# Notes
* __Provisioned infrastructure will result in costs__
* Only one NAT gateway included to decrease cost
* The cron task included in user data for the Launch Template syncs with s3 bucket __every minute__. It is done for test purposes and an interval should be increased to avoid excessive # of s3 requests. 
