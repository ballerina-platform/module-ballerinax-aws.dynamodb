# Ballerina Amazon DynamoDB Connector

[![Build](https://github.com/ballerina-platform/module-ballerinax-aws.dynamodb/actions/workflows/ci.yml/badge.svg)](https://github.com/ballerina-platform/module-ballerinax-aws.dynamodb/actions/workflows/ci.yml)
[![codecov](https://codecov.io/gh/ballerina-platform/module-ballerinax-aws.dynamodb/branch/main/graph/badge.svg)](https://codecov.io/gh/ballerina-platform/module-ballerinax-aws.dynamodb)
[![GitHub Last Commit](https://img.shields.io/github/last-commit/ballerina-platform/module-ballerinax-aws.dynamodb.svg)](https://github.com/ballerina-platform/module-ballerinax-aws.dynamodb/commits/main)
[![GitHub Issues](https://img.shields.io/github/issues/ballerina-platform/ballerina-library/module/aws.dynamodb.svg?label=Open%20Issues)](https://github.com/ballerina-platform/ballerina-library/labels/module%2Faws.dynamodb)

## Overview

[Amazon DynamoDB](https://aws.amazon.com/dynamodb/) is a fully managed, serverless, key-value NoSQL database designed to run high-performance applications at any scale. DynamoDB offers built-in security, continuous backups, automated multi-region replication, in-memory caching, and data export tools.

The Amazon DynamoDB connector offers APIs to connect and interact with the [AWS DynamoDB API](https://docs.aws.amazon.com/amazondynamodb/latest/APIReference/Welcome.html) endpoints.

## Setup guide

### Create a DynamoDB table

You can create the table this connector operates on either through the connector itself (`createTable`) or ahead of time in the [DynamoDB console](https://console.aws.amazon.com/dynamodbv2). A table is defined by its primary key, which is either a partition key on its own or a partition key together with a sort key. Every attribute named in the key schema must also appear in the attribute definitions.

### Obtain IAM user credentials

To create an IAM user and generate an access key, follow the [obtaining IAM user credentials](https://central.ballerina.io/ballerinax/aws/latest#obtaining-iam-user-credentials) guide.

Attach the DynamoDB permissions your application needs to the user. The control-plane actions (creating and describing tables) and the data-plane actions (reading and writing items) are granted separately:

```json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "dynamodb:CreateTable",
                "dynamodb:DescribeTable",
                "dynamodb:UpdateTable",
                "dynamodb:DeleteTable",
                "dynamodb:DescribeTimeToLive",
                "dynamodb:CreateBackup",
                "dynamodb:DeleteBackup",
                "dynamodb:PutItem",
                "dynamodb:GetItem",
                "dynamodb:UpdateItem",
                "dynamodb:DeleteItem",
                "dynamodb:Query",
                "dynamodb:Scan",
                "dynamodb:BatchGetItem",
                "dynamodb:BatchWriteItem"
            ],
            "Resource": "arn:aws:dynamodb:<REGION>:<ACCOUNT_ID>:table/<TABLE_NAME>"
        },
        {
            "Effect": "Allow",
            "Action": [
                "dynamodb:ListTables",
                "dynamodb:DescribeLimits"
            ],
            "Resource": "*"
        }
    ]
}
```

> **Note:** `dynamodb:ListTables` and `dynamodb:DescribeLimits` are in a statement of their own because they are
> account-level actions and cannot be scoped to a table ARN — AWS denies them when the resource is anything other
> than `*`. Omit that statement entirely if your application calls neither operation.

## Quickstart

To use the `aws.dynamodb` connector in your Ballerina project, modify the `.bal` file as follows:

### Step 1: Import the connector

Import `ballerinax/aws` & `ballerinax/aws.dynamodb` packages into your Ballerina project.

```ballerina
import ballerinax/aws;
import ballerinax/aws.dynamodb;
```

### Step 2: Instantiate a new connector

Create a new `dynamodb:Client` by providing the region and authentication configurations.

```ballerina
configurable string accessKeyId = ?;
configurable string secretAccessKey = ?;

dynamodb:Client dynamoDb = check new ({
    region: aws:US_EAST_1,
    auth: {
        accessKeyId,
        secretAccessKey
    }
});
```

### Step 3: Invoke the connector operation

Create a table, write an item into it, then read the item back.

```ballerina
public function main() returns error? {
    _ = check dynamoDb->createTable({
        TableName: "HighScores",
        AttributeDefinitions: [
            {AttributeName: "GameId", AttributeType: dynamodb:S},
            {AttributeName: "Score", AttributeType: dynamodb:N}
        ],
        KeySchema: [
            {AttributeName: "GameId", KeyType: dynamodb:HASH},
            {AttributeName: "Score", KeyType: dynamodb:RANGE}
        ],
        BillingMode: dynamodb:PAY_PER_REQUEST
    });

    _ = check dynamoDb->createItem({
        TableName: "HighScores",
        Item: {
            "GameId": {S: "FlappyBird"},
            "Score": {N: "500"},
            "PlayerName": {S: "PlayerOne"}
        }
    });

    // `query` returns an auto-paginating stream; the next page is fetched only once this one is consumed.
    stream<dynamodb:QueryOutput, dynamodb:Error?> scores = check dynamoDb->query({
        TableName: "HighScores",
        KeyConditionExpression: "GameId = :gameId",
        ExpressionAttributeValues: {":gameId": {S: "FlappyBird"}},
        ScanIndexForward: false
    });

    check from dynamodb:QueryOutput result in scores
        do {
            map<dynamodb:AttributeValue> item = check result?.Item.ensureType();
            io:println(item["PlayerName"]?.S, " scored ", item["Score"]?.N);
        };
}
```

### Step 4: Run the Ballerina application

Use the following command to compile and run the Ballerina program.

```bash
bal run
```

### Alternative authentication methods

#### Profile-based authentication

You can use AWS profile-based authentication as an alternative to static credentials.

```ballerina
dynamodb:Client dynamoDb = check new ({
    region: aws:US_EAST_1,
    auth: {
        profileName: "myAwsProfile",
        credentialsFilePath: "/path/to/custom/credentials"
    }
});
```

#### Default credential provider chain

Resolves credentials automatically from the AWS SDK's default chain. This is the recommended option when the application runs on AWS infrastructure, since no long-lived credentials need to be stored with the application.

```ballerina
import ballerinax/aws.auth;

dynamodb:Client dynamoDb = check new ({
    region: aws:US_EAST_1,
    auth: auth:DEFAULT_CREDENTIALS
});
```

> **Note:** Beyond the three options above, the `auth` field also accepts `auth:AssumeRoleConfig` (STS assume-role), `auth:WebIdentityConfig` (web identity / OIDC), `auth:SsoAuthConfig` (IAM Identity Center), and `auth:ProcessAuthConfig` (external credential process). See the [`Ballerina AWS`](https://central.ballerina.io/ballerinax/aws/latest) documentation for details.

## Examples

The `aws.dynamodb` connector provides practical examples illustrating usage in various scenarios. Explore these [examples](https://github.com/ballerina-platform/module-ballerinax-aws.dynamodb/tree/main/examples).

1. [Mobile game high scores](https://github.com/ballerina-platform/module-ballerinax-aws.dynamodb/tree/main/examples/game-scores)
   This example shows how to manage a high-score table for a mobile game: creating the table, recording scores, querying the leaderboard, and updating and deleting entries.

2. [Catalog bulk loader](https://github.com/ballerina-platform/module-ballerinax-aws.dynamodb/tree/main/examples/catalog-bulk-load)
   This example shows how to load a product catalog with `writeBatchItems`, read it back with `getBatchItems`, and scan the whole table. It runs on the default credential provider chain, so it works unchanged on EC2, ECS, and EKS.

## Issues and projects

The **Issues** and **Projects** tabs are disabled for this repository as this is part of the Ballerina library. To report bugs, request new features, start new discussions, view project boards, etc., visit the Ballerina library [parent repository](https://github.com/ballerina-platform/ballerina-library).

This repository only contains the source code for the package.

## Build from the source

### Prerequisites

1. Download and install Java SE Development Kit (JDK) version 21. You can download it from either of the following sources:

    * [Oracle JDK](https://www.oracle.com/java/technologies/downloads/)
    * [OpenJDK](https://adoptium.net/)

   > **Note:** After installation, remember to set the `JAVA_HOME` environment variable to the directory where JDK was installed.

2. Download and install [Ballerina Swan Lake](https://ballerina.io/).

3. Download and install [Docker](https://www.docker.com/get-started).

   > **Note**: Ensure that the Docker daemon is running before executing any tests.

### Build options

Execute the commands below to build from the source.

1. To build the package:
   ```bash
   ./gradlew clean build
   ```

2. To run the tests:
   ```bash
   ./gradlew clean test
   ```

3. To build the without the tests:
   ```bash
   ./gradlew clean build -x test
   ```

4. To debug package with a remote debugger:
   ```bash
   ./gradlew clean build -Pdebug=<port>
   ```

5. To debug with the Ballerina language:
   ```bash
   ./gradlew clean build -PbalJavaDebug=<port>
   ```

6. Publish the generated artifacts to the local Ballerina Central repository:
    ```bash
    ./gradlew clean build -PpublishToLocalCentral=true
    ```

7. Publish the generated artifacts to the Ballerina Central repository:
   ```bash
   ./gradlew clean build -PpublishToCentral=true
   ```

## Contribute to Ballerina

As an open-source project, Ballerina welcomes contributions from the community.

For more information, go to the [contribution guidelines](https://github.com/ballerina-platform/ballerina-lang/blob/master/CONTRIBUTING.md).

## Code of conduct

All the contributors are encouraged to read the [Ballerina Code of Conduct](https://ballerina.io/code-of-conduct).

## Useful links

* For more information go to the [`aws.dynamodb` package](https://central.ballerina.io/ballerinax/aws.dynamodb/latest).
* For example demonstrations of the usage, go to [Ballerina By Examples](https://ballerina.io/learn/by-example/).
* Chat live with us via our [Discord server](https://discord.gg/ballerinalang).
* Post all technical questions on Stack Overflow with the [#ballerina](https://stackoverflow.com/questions/tagged/ballerina) tag.
