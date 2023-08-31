## Overview
The Ballerina AWS DynamoDB connector provides the capability to programatically handle [AWS DynamoDB](hhttps://aws.amazon.com/dynamodb/) related operations.

This module supports [Amazon DynamoDB REST API 20120810](https://docs.aws.amazon.com/amazondynamodb/latest/APIReference/Welcome.html).
 
## Prerequisites
Before using this connector in your Ballerina application, complete the following:
1. Create an [AWS account](https://portal.aws.amazon.com/billing/signup?nc2=h_ct&src=default&redirect_url=https%3A%2F%2Faws.amazon.com%2Fregistration-confirmation#/start)
2. [Obtain tokens](https://docs.aws.amazon.com/IAM/latest/UserGuide/id_credentials_access-keys.html)

## Quickstart
To use the AWS DynamoDB connector in your Ballerina application, update the .bal file as follows:

### Step 1: Import connector
Import the `ballerinax/aws.dynamodb` module into the Ballerina project.
```ballerina
import ballerinax/aws.dynamodb;
```

### Step 2: Create a new connector instance
Create an `dynamodb:ConnectionConfig` with the tokens obtained, and initialize the connector with it.
```ballerina
dynamodb:ConnectionConfig amazonDynamodbConfig = {
    awsCredentials: {
        accessKeyId: "<ACCESS_KEY_ID>",
        secretAccessKey: "<SECRET_ACCESS_KEY>"

    },
    region: "<REGION>"
};

dynamodb:Client amazonDynamoDBClient = check new(amazonDynamodbConfig);
```

### Step 3: Invoke connector operation
1. Now you can use the operations available within the connector. Note that they are in the form of remote operations.  
Following is an example on how to create table in DynamoDB using the connector.

    ```ballerina

    public function main() returns error? {
        dynamodb:TableCreateRequest payload = {
            AttributeDefinitions: [
                    {
                        AttributeName: "ForumName",
                        AttributeType: "S"
                    },
                    {
                        AttributeName: "Subject",
                        AttributeType: "S"
                    },
                    {
                        AttributeName: "LastPostDateTime",
                        AttributeType: "S"
                    }
                ],
                TableName: mainTable,
                KeySchema: [
                    {
                        AttributeName: "ForumName",
                        KeyType: HASH
                    },
                    {
                        AttributeName: "Subject",
                        KeyType: RANGE
                    }
                ],
                LocalSecondaryIndexes: [
                    {
                        IndexName: "LastPostIndex",
                        KeySchema: [
                            {
                                AttributeName: "ForumName",
                                KeyType: HASH
                            },
                            {
                                AttributeName: "LastPostDateTime",
                                KeyType: RANGE
                            }
                        ],
                        Projection: {
                            ProjectionType: KEYS_ONLY
                        }
                    }
                ],
                ProvisionedThroughput: {
                    ReadCapacityUnits: 5,
                    WriteCapacityUnits: 5
                },
                Tags: [
                    {
                        Key: "Owner",
                        Value: "BlueTeam"
                    }
                ]
            };
        dynamodb:TableCreateResponse createTablesResult = check dynamoDBClient->createTable(payload);
    }
    ```
2. Use `bal run` command to compile and run the Ballerina program.
