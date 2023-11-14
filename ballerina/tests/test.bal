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

import ballerina/lang.runtime;
import ballerina/log;
import ballerina/os;
import ballerina/test;

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
function testCreateTable() returns error? {
    CreateTableInput payload = {
        attributeDefinitions: [
            {
                attributeName: "ForumName",
                attributeType: "S"
            },
            {
                attributeName: "Subject",
                attributeType: "S"
            },
            {
                attributeName: "LastPostDateTime",
                attributeType: "S"
            }
        ],
        tableName: mainTable,
        keySchema: [
            {
                attributeName: "ForumName",
                keyType: HASH
            },
            {
                attributeName: "Subject",
                keyType: RANGE
            }
        ],
        localSecondaryIndexes: [
            {
                indexName: "LastPostIndex",
                keySchema: [
                    {
                        attributeName: "ForumName",
                        keyType: HASH
                    },
                    {
                        attributeName: "LastPostDateTime",
                        keyType: RANGE
                    }
                ],
                projection: {
                    projectionType: KEYS_ONLY
                }
            }
        ],
        provisionedThroughput: {
            readCapacityUnits: 5,
            writeCapacityUnits: 5
        },
        tags: [
            {
                key: "Owner",
                value: "BlueTeam"
            }
        ]
    };
    TableDescription createTablesResult = check dynamoDBClient->createTable(payload);
    test:assertEquals(createTablesResult?.tableName, mainTable, "Thread table is not created.");
    test:assertEquals(createTablesResult?.tableStatus, CREATING, "Table is not created.");
    payload.tableName = secondaryTable;
    createTablesResult = check dynamoDBClient->createTable(payload);
    test:assertEquals(createTablesResult?.tableName, secondaryTable,
                    "SecondaryThread table is not created.");
    log:printInfo("Testing CreateTable is completed.");
}

@test:Config {
    dependsOn: [testCreateTable]
}
function testDescribeTable() returns error? {
    TableDescription response = check dynamoDBClient->describeTable(mainTable);
    test:assertEquals(response?.tableName, mainTable, "Expected table is not described.");
    log:printInfo("Testing DescribeTable is completed.");
}

@test:Config {
    dependsOn: [testDescribeTable]
}
function updateTable() returns error? {
    _ = check executeWithRetry(testUpdateTable, 20, 3);
}

function testUpdateTable() returns error? {
    UpdateTableInput request = {
        tableName: mainTable,
        provisionedThroughput: {
            readCapacityUnits: 10,
            writeCapacityUnits: 10
        }
    };
    TableDescription response = check dynamoDBClient->updateTable(request);
    ProvisionedThroughputDescription? provisionedThroughput = response?.provisionedThroughput;
    if provisionedThroughput !is () {
        test:assertEquals(provisionedThroughput?.readCapacityUnits, 5, "Read Capacity Units are not updated in table.");
        test:assertEquals(provisionedThroughput?.writeCapacityUnits, 5, "Write Capacity Units are not updated in table.");
    }
    log:printInfo("Testing UpdateTable is completed.");
}

@test:Config {
    dependsOn: [updateTable]
}
function testListTables() returns error? {
    stream<string, error?> response = check dynamoDBClient->listTables();
    test:assertTrue(response.next() is record {|string value;|}, "Expected result is not obtained.");
    check response.forEach(function(string tableName) {
        log:printInfo(tableName);
    });
    log:printInfo("Testing ListTables is completed.");
}

@test:Config {
    dependsOn: [testListTables]
}
function testPutItem() returns error? {
    CreateItemInput request = {
        tableName: mainTable,
        item: {
            "LastPostDateTime": {
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
        conditionExpression: "ForumName <> :f and Subject <> :s",
        returnValues: ALL_OLD,
        returnItemCollectionMetrics: SIZE,
        returnConsumedCapacity: TOTAL,
        expressionAttributeValues: {
            ":f": {
                "S": "Amazon DynamoDB"
            },
            ":s": {
                "S": "How do I update multiple items?"
            }
        }
    };

    ItemDescription response = check dynamoDBClient->createItem(request);
    log:printInfo(response.toString());
    log:printInfo("Testing CreateItem is completed.");
}

@test:Config {
    dependsOn: [testPutItem]
}
function testGetItem() returns error? {
    GetItemInput request = {
        tableName: mainTable,
        'key: {
            "ForumName": {
                "S": "Amazon DynamoDB"
            },
            "Subject": {
                "S": "How do I update multiple items?"
            }
        },
        projectionExpression: "LastPostDateTime, Message, Tags",
        consistentRead: true,
        returnConsumedCapacity: TOTAL
    };
    GetItemOutput response = check dynamoDBClient->getItem(request);
    log:printInfo(response?.item.toString());
    log:printInfo("Testing GetItem is completed.");
}

@test:Config {
    dependsOn: [testGetItem]
}
function testUpdateItem() returns error? {
    UpdateItemInput request = {
        tableName: mainTable,
        'key: {
            "ForumName": {
                "S": "Amazon DynamoDB"
            },
            "Subject": {
                "S": "How do I update multiple items?"
            }
        },
        updateExpression: "set LastPostedBy = :val1",
        conditionExpression: "LastPostedBy = :val2",
        expressionAttributeValues: {
            ":val1": {
                "S": "alice@example.com"
            },
            ":val2": {
                "S": "fred@example.com"
            }
        },
        returnValues: ALL_NEW,
        returnConsumedCapacity: TOTAL,
        returnItemCollectionMetrics: SIZE
    };
    ItemDescription response = check dynamoDBClient->updateItem(request);
    log:printInfo(response.toString());
    log:printInfo("Testing UpdateItem is completed.");
}

@test:Config {
    dependsOn: [testUpdateItem]
}
function testQuery() returns error? {
    QueryInput request = {
        tableName: mainTable,
        consistentRead: true,
        keyConditionExpression: "ForumName = :val",
        expressionAttributeValues: {":val": {"S": "Amazon DynamoDB"}}
    };
    stream<QueryOutput, error?> response = check dynamoDBClient->query(request);
    check response.forEach(function(QueryOutput resp) {
        test:assertTrue(resp?.item is map<AttributeValue>);
    });
    log:printInfo("Testing Query is completed.");
}

@test:Config {
    dependsOn: [testQuery]
}
function testScan() returns error? {
    ScanInput request = {
        tableName: mainTable,
        filterExpression: "LastPostedBy = :val",
        expressionAttributeValues: {":val": {"S": "alice@example.com"}},
        returnConsumedCapacity: TOTAL
    };

    stream<ScanOutput, error?> response = check dynamoDBClient->scan(request);
    check response.forEach(function(ScanOutput resp) {
        test:assertTrue(resp?.item is map<AttributeValue>);
    });
    log:printInfo("Testing Scan is completed.");
}

@test:Config {
    dependsOn: [testScan]
}
function testWriteBatchItems() returns error? {
    WriteBatchItemInput request = {
        requestItems: {
            "SecondaryThread": [
                {
                    putRequest: {
                        item: {
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
                    putRequest: {
                        item: {
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
                    putRequest: {
                        item: {
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
                    putRequest: {
                        item: {
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
        returnConsumedCapacity: TOTAL
    };

    WriteBatchItemOutput response = check dynamoDBClient->writeBatchItem(request);
    log:printInfo(response.toString());
    log:printInfo("Testing WriteBatchItems(put) is completed.");
}

@test:Config {
    dependsOn: [testWriteBatchItems]
}
function testGetBatchItems() returns error? {
    GetBatchItemInput request = {
        requestItems: {
            "Thread": {
                keys: [
                    {
                        "ForumName": {"S": "Amazon DynamoDB"},
                        "Subject": {"S": "How do I update multiple items?"}
                    }
                ],
                projectionExpression: "ForumName, Message"
            },
            "SecondaryThread": {
                keys: [
                    {
                        "ForumName": {"S": "Amazon S3"},
                        "Subject": {"S": "How do I update multiple items?"}
                    }
                ],
                projectionExpression: "ForumName, Message, LastPostedBy"
            }
        },
        returnConsumedCapacity: TOTAL
    };

    stream<BatchItem, error?> response = check dynamoDBClient->getBatchItem(request);
    check response.forEach(function(BatchItem item) {
        log:printInfo(item?.item.toString());
    });
    log:printInfo("Testing BatchGetItem is completed.");
}

@test:Config {
    dependsOn: [testGetBatchItems]
}
function testDeleteItem() returns error? {
    DeleteItemInput request = {
        tableName: mainTable,
        'key: {
            "ForumName": {
                "S": "Amazon DynamoDB"
            },
            "Subject": {
                "S": "How do I update multiple items?"
            }
        },
        returnConsumedCapacity: TOTAL,
        returnItemCollectionMetrics: SIZE,
        returnValues: ALL_OLD
    };
    ItemDescription response = check dynamoDBClient->deleteItem(request);
    log:printInfo(response.toString());
    log:printInfo("Testing DeleteItem is completed.");
}

@test:Config {}
function testDescribeLimits() returns error? {
    LimitDescription response = check dynamoDBClient->describeLimits();
    test:assertTrue(response?.accountMaxReadCapacityUnits is int, "AccountMaxReadCapacityUnits in DescribeLimits is " +
                    "not an integer.");
    test:assertTrue(response?.accountMaxWriteCapacityUnits is int, "AccountMaxWriteCapacityUnits in DescribeLimits is " +
                    "not an integer.");
    test:assertTrue(response?.tableMaxReadCapacityUnits is int, "TableMaxReadCapacityUnits in DescribeLimits is " +
                    "not an integer.");
    test:assertTrue(response?.tableMaxWriteCapacityUnits is int, "TableMaxWriteCapacityUnits in DescribeLimits is " +
                    "not an integer.");
    log:printInfo("Testing DescribeLimits is completed.");
}

@test:AfterSuite
function deleteTables() returns error? {
    _ = check executeWithRetry(testDeleteTable, 20, 3);
}

function testDeleteTable() returns error? {
    TableDescription response = check dynamoDBClient->deleteTable(mainTable);
    log:printInfo(response.toString());
    test:assertEquals(response?.tableName, mainTable, "Expected table is not deleted.");
    response = check dynamoDBClient->deleteTable(secondaryTable);
    log:printInfo(response.toString());
    test:assertEquals(response?.tableName, secondaryTable, "Expected table is not deleted.");
    log:printInfo("Testing DeleteTable is completed.");
}

# Executes a given function with retry. If there is no error the function will 
# immediately return. If there's errors it will retry as per given parameters. 
#
# + testFunc - Test function to execute
# + delayBetweenRetries - Time delay between two retries in seconds
# + maxRetryCount - Maximum count to retry before giving up
# + errorMsg - (Optional) Part or exact error message to check. Retry will happen 
# only if this matches with the error that is returned by executing the  testFunc. 
# If not provided, retry will happen for any error returned by the testFunc. 
# + return - Stream of Calendars on success or else an error
function executeWithRetry(function () returns error? testFunc, decimal delayBetweenRetries,
        int maxRetryCount, string? errorMsg = ()) returns error? {

    int currentRetryCount = 0;
    error? testResult = ();
    while (currentRetryCount < maxRetryCount) {
        if currentRetryCount > 0 {
            runtime:sleep(delayBetweenRetries);
            log:printWarn("Function returned an error. Retrying for "
                + (currentRetryCount + 1).toString() + "th time");
        }
        testResult = testFunc();
        currentRetryCount = currentRetryCount + 1;
        if testResult is error {
            if errorMsg == () {
                continue;
            } else {
                if string:includes(testResult.message(), errorMsg, 0) {
                    continue;
                } else {
                    break;
                }
            }
        } else {
            break;
        }
    }
    return testResult;
}

@test:Config {
    dependsOn: [testCreateTable]
}
function testCreateBackupAndDeleteBackup() returns error? {
    CreateBackupInput backupRequest = {
        tableName: "Thread",
        backupName: "ThreadBackup"
    };
    BackupDetails response = check dynamoDBClient->createBackup(backupRequest);
    test:assertEquals(response.backupName, "ThreadBackup");
    string backupArn = response.backupArn;
    BackupDescription backupDescription = check dynamoDBClient->deleteBackup(backupArn);
    test:assertEquals(backupDescription.backupDetails?.backupName, "ThreadBackup");
}

@test:Config {
    dependsOn: [testCreateTable]
}
function testTimeToLive() returns error? {
    TTLDescription response = check dynamoDBClient->getTTL("Thread");
    test:assertEquals(response.timeToLiveStatus, "DISABLED");
}
