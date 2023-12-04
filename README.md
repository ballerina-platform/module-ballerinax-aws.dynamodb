# Ballerina Amazon DynamoDB Connector 
[![Build Status](https://github.com/ballerina-platform/module-ballerinax-aws.dynamodb/workflows/CI/badge.svg)](https://github.com/ballerina-platform/module-ballerinax-aws.dynamodb/actions?query=workflow%3ACI)
[![codecov](https://codecov.io/gh/ballerina-platform/module-ballerinax-aws.dynamodb/branch/main/graph/badge.svg)](https://codecov.io/gh/ballerina-platform/module-ballerinax-aws.dynamodb)
[![GitHub Last Commit](https://img.shields.io/github/last-commit/ballerina-platform/module-ballerinax-aws.dynamodb.svg)](https://github.com/ballerina-platform/module-ballerinax-aws.dynamodb./commits/master)
[![GraalVM Check](https://github.com/ballerina-platform/module-ballerinax-aws.dynamodb/actions/workflows/build-with-bal-test-native.yml/badge.svg)](https://github.com/ballerina-platform/module-ballerinax-aws.dynamodb/actions/workflows/build-with-bal-test-native.yml)
[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](https://opensource.org/licenses/Apache-2.0)

[Amazon DynamoDB](https://aws.amazon.com/dynamodb/) is a fully managed, serverless, key-value NoSQL database designed to run high-performance applications at any scale. DynamoDB offers built-in security, continuous backups, automated multi-region replication, in-memory caching, and data export tools.

The connector provides the capability to programatically handle AWS DynamoDB related operations.

For more information, go to the module(s).
- [aws.dynamodb](./Module.md)

## Set up DynamoDB credentials

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

## Quickstart

**Note**: Ensure you follow the [prerequisites](https://github.com/ballerina-platform/module-ballerinax-aws.dynamodb#set-up-dynamodb-credentials) to get the credentials to be used.

To use the `dynamodb` connector in your Ballerina application, modify the `.bal` file as follows:

### Step 1: Import the connector
Import the `ballerinax/aws.dynamodb` package into your Ballerina project.
```ballerina
import ballerinax/aws.dynamodb;
```

### Step 2: Instantiate a new connector
Create a `dynamodb:ConnectionConfig` with the obtained access key id and secret access key to initialize the connector with it.
```ballerina
dynamodb:ConnectionConfig amazonDynamodbConfig = {
    awsCredentials: {
        accessKeyId: "ACCESS_KEY_ID",
        secretAccessKey: "SECRET_ACCESS_KEY"
    },
    region: "REGION"
};

dynamodb:Client amazonDynamodbClient = check new (amazonDynamodbConfig);
```

### Step 3: Invoke the connector operation
Now, utilize the available connector operations.
```ballerina
dynamodb:CreateTableInput createTableInput = {
    tableName: "HighScores",
    attributeDefinitions: [
        {attributeName: "GameID", attributeType: "S"},
        {attributeName: "Score", attributeType: "N"}
    ],
    keySchema: [
        {attributeName: "GameID", keyType: "HASH"},
        {attributeName: "Score", keyType: "RANGE"}
    ],
    provisionedThroughput: {
        readCapacityUnits: 5,
        writeCapacityUnits: 5
    }
};
_ = check amazonDynamodbClient->createTable(createTableInput);
```

## Examples

The `dynamodb` connector provides practical examples illustrating usage in various scenarios. Explore these [examples](https://github.com/ballerina-platform/module-ballerinax-aws.dynamodb/tree/master/examples), covering use cases like creating, reading, updating, deleting data from tables.

1. [Maintain a game score dashboard](https://github.com/ballerina-platform/module-ballerinax-aws.dynamodb/tree/master/examples/game-scores/client.bal)
    Manage a mobile gaming application dashboard that tracks high scores for different games.

For comprehensive information about the connector's functionality, configuration, and usage in Ballerina programs, refer to the `dynamodb` connector's reference guide in [Ballerina Central](https://central.ballerina.io/ballerinax/aws.dynamodb/latest).

## Issues and projects 

The **Issues** and **Projects** tabs are disabled for this repository as this is part of the Ballerina library. To report bugs, request new features, start new discussions, view project boards, etc., visit the Ballerina library [parent repository](https://github.com/ballerina-platform/ballerina-library). 

This repository only contains the source code for the package.

## Build from the source

### Prerequisites

1. Download and install Java SE Development Kit (JDK) version 17. You can download it from either of the following sources:

   * [Oracle JDK](https://www.oracle.com/java/technologies/downloads/)
   * [OpenJDK](https://adoptium.net/)

    > **Note:** After installation, remember to set the `JAVA_HOME` environment variable to the directory where JDK was installed.

2. Download and install [Ballerina Swan Lake](https://ballerina.io/).

3. Download and install [Docker](https://www.docker.com/get-started).

    > **Note**: Ensure that the Docker daemon is running before executing any tests.

### Build options

Execute the commands below to build from the source.

1. To build the package:
   ```
   ./gradlew clean build
   ```

2. To run the tests:
   ```
   ./gradlew clean test
   ```

3. To build the without the tests:
   ```
   ./gradlew clean build -x test
   ```

5. To debug package with a remote debugger:
   ```
   ./gradlew clean build -Pdebug=<port>
   ```

6. To debug with the Ballerina language:
   ```
   ./gradlew clean build -PbalJavaDebug=<port>
   ```

7. Publish the generated artifacts to the local Ballerina Central repository:
    ```
    ./gradlew clean build -PpublishToLocalCentral=true
    ```

8. Publish the generated artifacts to the Ballerina Central repository:
   ```
   ./gradlew clean build -PpublishToCentral=true
   ```

## Contribute to Ballerina

As an open-source project, Ballerina welcomes contributions from the community.

For more information, go to the [contribution guidelines](https://github.com/ballerina-platform/ballerina-lang/blob/master/CONTRIBUTING.md).

## Code of conduct

All the contributors are encouraged to read the [Ballerina Code of Conduct](https://ballerina.io/code-of-conduct).

## Useful links

* For more information go to the [`aws.dynamodb` package](https://lib.ballerina.io/ballerinax/aws.dynamodb/latest).
* For example demonstrations of the usage, go to [Ballerina By Examples](https://ballerina.io/learn/by-example/).
* Chat live with us via our [Discord server](https://discord.gg/ballerinalang).
* Post all technical questions on Stack Overflow with the [#ballerina](https://stackoverflow.com/questions/tagged/ballerina) tag.