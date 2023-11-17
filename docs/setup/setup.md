# Configure DynamoDB API

_Owners_: @bhashinee \
_Reviewers_: @daneshk \
_Created_: 2022/11/15 \
_Updated_: 2023/11/15 \

## Introduction

To invoke the DynamoDB REST API, you need AWS credentials. Below is a step-by-step guide on how to obtain these credentials:

1. Create an AWS Account:
* If you don't already have an AWS account, you need to create one. Go to the AWS Management Console, click on "Create an AWS Account," and follow the instructions.

2. Access the AWS Identity and Access Management (IAM) Console:

* Once logged into the [AWS Management Console](https://aws.amazon.com/), go to the IAM console by selecting "Services" and then choosing "IAM" under the "Security, Identity, & Compliance" section.

3. Create an IAM User:

* In the IAM console, navigate to "Users" and click on "Add user."
* Enter a username, and under "Select AWS access type," choose "Programmatic access."
* Click through the permissions setup, attaching policies that grant access to DynamoDB if you have specific requirements.
* Review the details and click "Create user."

4. Access Key ID and Secret Access Key:

* Once the user is created, you will see a success message. Take note of the "Access key ID" and "Secret access key" displayed on the confirmation screen. These credentials are needed to authenticate your requests.

5. Securely Store Credentials:

* Download the CSV file containing the credentials, or copy the "Access key ID" and "Secret access key" to a secure location. This information is sensitive and should be handled with care.

6. Use the Credentials in Your Application:

* In your application, use the obtained "Access key ID" and "Secret access key" to authenticate requests to the DynamoDB REST API.
