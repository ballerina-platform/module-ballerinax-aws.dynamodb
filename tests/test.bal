// Copyright (c) 2021, WSO2 Inc. (http://www.wso2.org) All Rights Reserved.
//
// WSO2 Inc. licenses this file to you under the Apache License,
// Version 2.0 (the "License"); you may not use this file except
// in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing,
// software distributed under the License is distributed on an
// "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
// KIND, either express or implied.  See the License for the
// specific language governing permissions and limitations
// under the License.

import ballerina/test;
import ballerina/log;
import ballerina/lang.runtime;
import ballerina/os;

configurable string accessKeyId = os:getEnv("ACCESS_KEY_ID");
configurable string secretAccessKey = os:getEnv("SECRET_ACCESS_KEY");
configurable string region = os:getEnv("REGION");

final string mainTable = "Thread";
final string secondaryTable = "SecondaryThread";

ConnectionConfig config = {
    awsCredentials: {accessKeyId: accessKeyId, secretAccessKey: secretAccessKey},
    region: region
};

Client dynamoDBClient = check new (config);

@test:Config {}
function testCreateTable() returns error?{
    TableCreateRequest payload = {
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
    TableCreateResponse createTablesResult = check dynamoDBClient->createTable(payload);
    test:assertEquals(createTablesResult.TableDescription?.TableName, mainTable, "Thread table is not created.");
    test:assertEquals(createTablesResult.TableDescription?.TableStatus, CREATING, "Table is not created.");
    payload.TableName = secondaryTable;
    createTablesResult = check dynamoDBClient->createTable(payload);
    test:assertEquals(createTablesResult.TableDescription?.TableName, secondaryTable,
                      "SecondaryThread table is not created.");
    runtime:sleep(20);
    log:printInfo("Testing CreateTable is completed.");
}

@test:Config{
    dependsOn: [testCreateTable]
}
function testDescribeTable() returns error?{
    TableDescribeResponse response = check dynamoDBClient->describeTable(mainTable);
    test:assertEquals(response.Table?.TableName, mainTable, "Expected table is not described.");
    log:printInfo("Testing DescribeTable is completed.");
}

@test:Config{
    dependsOn: [testDescribeTable]
}
function testUpdateTable() returns error? {
    TableUpdateRequest request = {
        TableName: mainTable,
        ProvisionedThroughput: {
            ReadCapacityUnits: 10,
            WriteCapacityUnits: 10
        }
    };
    TableUpdateResponse response = check dynamoDBClient->updateTable(request);
    ProvisionedThroughputDescription? provisionedThroughput = response.TableDescription?.ProvisionedThroughput;
    if provisionedThroughput !is () {
        test:assertEquals(provisionedThroughput?.ReadCapacityUnits, 5, "Read Capacity Units are not updated in table.");
        test:assertEquals(provisionedThroughput?.WriteCapacityUnits, 5, "Write Capacity Units are not updated in table.");
    }
    log:printInfo("Testing UpdateTable is completed.");
}

@test:Config {
    dependsOn: [testUpdateTable]
}
function testListTables() returns error?{
    stream<string, error?> response = check dynamoDBClient->listTables();
    test:assertTrue(response.next() is record {| string value; |}, "Expected result is not obtained.");
    check response.forEach(function (string tableName){
        log:printInfo(tableName);
    });
    log:printInfo("Testing ListTables is completed.");
}

@test:Config{
    dependsOn: [testListTables]
}
function testPutItem() returns error? {
    ItemCreateRequest request = {
        TableName: mainTable,
        Item: {
            "LastPostDateTime" : {
                "S": "201303190422"
            },
            "Tags": {
                "SS": [
                    "Update",
                    "Multiple Items",
                    "HelpMe"
                ]
            },
            "ForumName": {
                "S": "Amazon DynamoDB"
            },
            "Message": {
                "S": "I want to update multiple items in a single call. What's the best way to do that?"
            },
            "Subject": {
                "S": "How do I update multiple items?"
            },
            "LastPostedBy": {
                "S": "fred@example.com"
            }
        },
        ConditionExpression: "ForumName <> :f and Subject <> :s",
        ReturnValues: ALL_OLD,
        ReturnItemCollectionMetrics: SIZE,
        ReturnConsumedCapacity: TOTAL,
        ExpressionAttributeValues: {
            ":f": {
                "S": "Amazon DynamoDB"
            },
            ":s": {
                "S": "How do I update multiple items?"
            }
        }
    };

    ItemDescription response = check dynamoDBClient->putItem(request);
    log:printInfo(response.toString());
    log:printInfo("Testing CreateItem is completed.");
}

@test:Config{
    dependsOn: [testPutItem]
}
function testGetItem() returns error? {
    ItemGetRequest request = {
        TableName: mainTable,
        Key: {
            "ForumName": {
            "S": "Amazon DynamoDB"
            },
            "Subject": {
            "S": "How do I update multiple items?"
            }
        },
        ProjectionExpression: "LastPostDateTime, Message, Tags",
        ConsistentRead: true,
        ReturnConsumedCapacity: TOTAL
    };
    ItemGetResponse response = check dynamoDBClient->getItem(request);
    log:printInfo(response?.Item.toString());
    log:printInfo("Testing GetItem is completed.");
}

@test:Config{
    dependsOn: [testGetItem]
}
function testUpdateItem() returns error? {
    ItemUpdateRequest request = {
        TableName: mainTable,
        Key: {
            "ForumName": {
                "S": "Amazon DynamoDB"
            },
            "Subject": {
                "S": "How do I update multiple items?"
            }
        },
        UpdateExpression: "set LastPostedBy = :val1",
        ConditionExpression: "LastPostedBy = :val2",
        ExpressionAttributeValues: {
            ":val1": {
                "S": "alice@example.com"
            },
            ":val2": {
                "S": "fred@example.com"
            }
        },
        ReturnValues: ALL_NEW,
        ReturnConsumedCapacity: TOTAL,
        ReturnItemCollectionMetrics: SIZE
    };
    ItemDescription response = check dynamoDBClient->updateItem(request);
    log:printInfo(response.toString());
    log:printInfo("Testing UpdateItem is completed.");
}

@test:Config{
    dependsOn: [testUpdateItem]
}
function testQuery() returns error? {
    QueryRequest request = {
        TableName: mainTable,
        ConsistentRead: true,
        KeyConditionExpression: "ForumName = :val",
        ExpressionAttributeValues: {":val": {"S": "Amazon DynamoDB"}}
    };
    stream<QueryResponse, error?> response = check dynamoDBClient->query(request);
    check response.forEach(function(QueryResponse resp){
        test:assertTrue(resp?.Item is map<AttributeValue>);
    });
    log:printInfo("Testing Query is completed.");
}
@test:Config{
    dependsOn: [testQuery]
}
function testScan() returns error? {
    ScanRequest request = {
        TableName: mainTable,
        FilterExpression: "LastPostedBy = :val",
        ExpressionAttributeValues: {":val": {"S": "alice@example.com"}},
        ReturnConsumedCapacity: TOTAL
    };

    stream<ScanResponse, error?> response = check dynamoDBClient->scan(request);
    check response.forEach(function(ScanResponse resp){
        test:assertTrue(resp?.Item is map<AttributeValue>);
    });
    log:printInfo("Testing Scan is completed.");
}
@test:Config{
    dependsOn: [testScan]
}
function testWriteBatchItems() returns error? {
    ItemsBatchWriteRequest request = {
        RequestItems: {
            "SecondaryThread" :[
                {
                    PutRequest: {
                        Item: {
                            "LastPostDateTime": {
                                "S": "201303190423"
                            },
                            "Tags": {
                                "SS": [
                                        "Update",
                                        "Multiple Items",
                                        "HelpMe"
                                    ]
                                },
                            "ForumName": {
                                    "S": "Amazon S3"
                                },
                            "Message": {
                                    "S": "I want to update multiple items in a single call. What's the best way to do that?"
                                },
                            "Subject": {
                                    "S": "How do I update multiple items?"
                                },
                            "LastPostedBy": {
                                    "S": "john@example.com"
                                }
                            }
                        }
                    },
                {
                    PutRequest: {
                        Item: {
                            "LastPostDateTime": {
                                "S": "201303190423"
                            },
                            "Tags": {
                                "SS": [
                                        "Update",
                                        "Multiple Items",
                                        "HelpMe"
                                    ]
                                },
                            "ForumName": {
                                    "S": "Amazon DynamoDB"
                                },
                            "Message": {
                                    "S": "I want to update multiple items in a single call. What's the best way to do that?"
                                },
                            "Subject": {
                                    "S": "How do I update multiple items?"
                                },
                            "LastPostedBy": {
                                    "S": "fred@example.com"
                                }
                            }
                        }
                    },
                {
                    PutRequest: {
                        Item: {
                            "LastPostDateTime": {
                                "S": "201303190423"
                            },
                            "Tags": {
                                "SS": [
                                        "Update",
                                        "Multiple Items",
                                        "HelpMe"
                                    ]
                                },
                            "ForumName": {
                                    "S": "Amazon SimpleDB"
                                },
                            "Message": {
                                    "S": "I want to update multiple items in a single call. What's the best way to do that?"
                                },
                            "Subject": {
                                    "S": "How do I update multiple items?"
                                },
                            "LastPostedBy": {
                                    "S": "james@example.com"
                                }
                            }
                        }
                    },
                {
                    PutRequest: {
                        Item: {
                            "LastPostDateTime": {
                                "S": "201303190423"
                            },
                            "Tags": {
                                "SS": [
                                        "Update",
                                        "Multiple Items",
                                        "HelpMe"
                                    ]
                                },
                            "ForumName": {
                                    "S": "Amazon SES"
                                },
                            "Message": {
                                    "S": "I want to send an email using AWS SES. What's the best way to do that?"
                                },
                            "Subject": {
                                    "S": "How do I send a mail?"
                                },
                            "LastPostedBy": {
                                    "S": "anne@example.com"
                                }
                            }
                        }                                                                     
                    }
            ]
        },
        ReturnConsumedCapacity: TOTAL
    };

    ItemsBatchWriteResponse response = check dynamoDBClient->writeBatchItems(request);
    log:printInfo(response.toString());
    log:printInfo("Testing WriteBatchItems(put) is completed.");
}
@test:Config{
    dependsOn: [testWriteBatchItems]
}
function testGetBatchItems() returns error? {
    ItemsBatchGetRequest request = {
        RequestItems: {
            "Thread": {
                Keys: [
                    {
                        "ForumName":{"S":"Amazon DynamoDB"},
                        "Subject":{"S":"How do I update multiple items?"}
                    }
                ],
                ProjectionExpression:"ForumName, Message"
            },
            "SecondaryThread": {
                Keys: [
                    {
                        "ForumName":{"S":"Amazon S3"},
                        "Subject":{"S":"How do I update multiple items?"}
                    }
                ],
                ProjectionExpression:"ForumName, Message, LastPostedBy"
            }
        },
        ReturnConsumedCapacity: TOTAL
    };

    stream<ItemByBatchGet, error?> response = check dynamoDBClient->getBatchItems(request);
    check response.forEach( function (ItemByBatchGet item) {
        log:printInfo(item?.Item.toString());
    });
    log:printInfo("Testing BatchGetItem is completed.");
}
@test:Config{
    dependsOn: [testGetBatchItems]
}
function testDeleteItem() returns error? {
    ItemDeleteRequest request = {
        TableName: mainTable,
        Key: {
            "ForumName": {
                "S": "Amazon DynamoDB"
            },
            "Subject": {
                "S": "How do I update multiple items?"
            }
        },
        ReturnConsumedCapacity: TOTAL,
        ReturnItemCollectionMetrics: SIZE,
        ReturnValues: ALL_OLD
    };
    ItemDescription response = check dynamoDBClient->deleteItem(request);
    log:printInfo(response.toString());
    log:printInfo("Testing DeleteItem is completed.");
}

@test:Config{}
function testDescribeLimits() returns error? {
    LimitDescribtion response = check dynamoDBClient->describeLimits();
    test:assertTrue(response?.AccountMaxReadCapacityUnits is int, "AccountMaxReadCapacityUnits in DescribeLimits is " +
                    "not an integer.");
    test:assertTrue(response?.AccountMaxWriteCapacityUnits is int, "AccountMaxWriteCapacityUnits in DescribeLimits is " +
                    "not an integer.");
    test:assertTrue(response?.TableMaxReadCapacityUnits is int, "TableMaxReadCapacityUnits in DescribeLimits is " +
                    "not an integer.");
    test:assertTrue(response?.TableMaxWriteCapacityUnits is int, "TableMaxWriteCapacityUnits in DescribeLimits is " +
                    "not an integer.");
    log:printInfo("Testing DescribeLimits is completed.");                                               
}

@test:AfterSuite
function testDeleteTable() returns error? {
    TableDeleteResponse response = check dynamoDBClient->deleteTable(mainTable);
    log:printInfo(response.toString());
    test:assertEquals(response.TableDescription?.TableName, mainTable, "Expected table is not deleted.");
    response = check dynamoDBClient->deleteTable(secondaryTable);
    log:printInfo(response.toString());
    test:assertEquals(response.TableDescription?.TableName, secondaryTable, "Expected table is not deleted.");
    log:printInfo("Testing DeleteTable is completed.");
}
