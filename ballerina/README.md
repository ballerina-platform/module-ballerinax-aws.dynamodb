## Overview

[Amazon DynamoDB](https://aws.amazon.com/dynamodb/) is a fully managed, serverless, key-value NoSQL database designed to run high-performance applications at any scale. DynamoDB offers built-in security, continuous backups, automated multi-region replication, in-memory caching, and data export tools.

The Amazon DynamoDB connector offers APIs to connect and interact with the [AWS DynamoDB API](https://docs.aws.amazon.com/amazondynamodb/latest/APIReference/Welcome.html) endpoints.

### Key features

- Table lifecycle management: `CreateTable`, `DescribeTable`, `UpdateTable`, `DeleteTable`, and `ListTables`
- Item-level operations: `PutItem`, `GetItem`, `UpdateItem`, and `DeleteItem`
- Auto-paginating Ballerina streams for `Query`, `Scan`, `ListTables`, and `BatchGetItem` — the next page is fetched only once the current one is consumed, and unprocessed batch keys are re-requested automatically
- Batch writes with `BatchWriteItem`, on-demand backups with `CreateBackup`/`DeleteBackup`, time-to-live status with `DescribeTimeToLive`, and account quotas with `DescribeLimits`
- Flexible credential configuration: static keys, AWS credentials file profiles, STS assume-role, web identity (OIDC), IAM Identity Center (SSO), an external credential process, or the default AWS credential provider chain (EKS Pod Identity, ECS task roles, EC2 instance profiles, environment variables)
- Automatic refresh of expiring temporary credentials
- FIPS, dualstack, and custom endpoint support

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
import ballerina/io;
import ballerina/lang.runtime;

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

    // `createTable` is asynchronous: the table stays `CREATING` for a while, and DynamoDB rejects reads and
    // writes against it until it reports `ACTIVE`.
    dynamodb:TableDescription description = check dynamoDb->describeTable("HighScores");
    while description?.TableStatus != dynamodb:ACTIVE {
        runtime:sleep(2);
        description = check dynamoDb->describeTable("HighScores");
    }

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
