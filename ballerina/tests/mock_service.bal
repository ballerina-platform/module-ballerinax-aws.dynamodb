// Copyright (c) 2026, WSO2 LLC. (http://www.wso2.com).
//
// WSO2 LLC. licenses this file to you under the Apache License,
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

import ballerina/http;
import ballerinax/aws;

const int MOCK_PORT = 21100;
const string MOCK_ENDPOINT = "http://localhost:21100";

const string MOCK_REQUEST_ID = "MOCKREQUESTID123";
const string MOCK_BACKUP_ARN = "arn:aws:dynamodb:us-east-1:123456789012:table/BallerinaHighScores/backup/01";

// Table names the mock treats as instructions rather than as tables.
const string TRIGGER_NOT_FOUND = "trigger-not-found";
const string TRIGGER_NON_JSON_ERROR = "trigger-non-json-error";

// A BatchGetItem request naming this table always comes back with its keys unprocessed and no items at all — a
// table that is being throttled continuously.
const string TRIGGER_THROTTLE = "trigger-throttle";

final readonly & aws:EndpointConfig mockEndpoint = {customEndpoint: MOCK_ENDPOINT};

type MockState record {|
    int listTablesCallCount = 0;
    int scanCallCount = 0;
    int queryCallCount = 0;
    int batchGetCallCount = 0;
    string authorizationHeader = "";
    string contentTypeHeader = "";
    string targetHeader = "";
    json requestPayload = ();
|};

isolated MockState mockState = {};

listener http:Listener mockListener = new (MOCK_PORT);

service / on mockListener {
    isolated resource function post .(http:Request request) returns http:Response|error {
        string target = check request.getHeader(TARGET_HEADER);
        json payload = check request.getJsonPayload();
        string authorization = check request.getHeader("authorization");
        string contentType = check request.getHeader(CONTENT_TYPE_HEADER);
        lock {
            mockState.authorizationHeader = authorization;
            mockState.contentTypeHeader = contentType;
            mockState.targetHeader = target;
            mockState.requestPayload = payload.clone();
        }

        // A request naming one of the trigger tables stands in for a service failure.
        json tableName = (<map<json>>payload)["TableName"];
        if tableName == TRIGGER_NOT_FOUND {
            return notFoundResponse();
        }
        if tableName == TRIGGER_NON_JSON_ERROR {
            return nonJsonErrorResponse();
        }

        match target {
            TARGET_CREATE_TABLE => {
                return okResponse({"TableDescription": tableDescription("CREATING")});
            }
            TARGET_DELETE_TABLE => {
                return okResponse({"TableDescription": tableDescription("DELETING")});
            }
            TARGET_DESCRIBE_TABLE => {
                return okResponse({"Table": tableDescription("ACTIVE")});
            }
            TARGET_UPDATE_TABLE => {
                return okResponse({"TableDescription": tableDescription("UPDATING")});
            }
            TARGET_LIST_TABLES => {
                return okResponse(listTablesPage());
            }
            TARGET_PUT_ITEM => {
                return okResponse(itemDescription());
            }
            TARGET_DELETE_ITEM => {
                return okResponse(itemDescription());
            }
            TARGET_UPDATE_ITEM => {
                return okResponse(itemDescription());
            }
            TARGET_GET_ITEM => {
                return okResponse({
                    "Item": highScoreItem("FlappyBird", "500", "PlayerOne"),
                    "ConsumedCapacity": {"TableName": testTableName, "CapacityUnits": 1.0}
                });
            }
            TARGET_QUERY => {
                return okResponse(queryPage());
            }
            TARGET_SCAN => {
                return okResponse(scanPage());
            }
            TARGET_BATCH_GET_ITEM => {
                return okResponse(batchGetPage(payload));
            }
            TARGET_BATCH_WRITE_ITEM => {
                return okResponse({
                    "UnprocessedItems": {},
                    "ConsumedCapacity": [{"TableName": testTableName, "CapacityUnits": 2.0}]
                });
            }
            TARGET_DESCRIBE_LIMITS => {
                return okResponse({
                    "AccountMaxReadCapacityUnits": 80000,
                    "AccountMaxWriteCapacityUnits": 80000,
                    "TableMaxReadCapacityUnits": 40000,
                    "TableMaxWriteCapacityUnits": 40000
                });
            }
            TARGET_CREATE_BACKUP => {
                return okResponse({
                    "BackupDetails": {
                        "BackupArn": MOCK_BACKUP_ARN,
                        "BackupName": "HighScoresBackup",
                        "BackupStatus": "CREATING",
                        "BackupType": "USER",
                        "BackupCreationDateTime": 1767225600.0
                    }
                });
            }
            TARGET_DELETE_BACKUP => {
                return okResponse({
                    "BackupDescription": {
                        "BackupDetails": {
                            "BackupArn": MOCK_BACKUP_ARN,
                            "BackupName": "HighScoresBackup",
                            "BackupStatus": "DELETED",
                            "BackupType": "USER",
                            "BackupCreationDateTime": 1767225600.0
                        },
                        "SourceTableDetails": {"TableName": testTableName, "TableId": "table-id-1"}
                    }
                });
            }
            TARGET_DESCRIBE_TIME_TO_LIVE => {
                return okResponse({
                    "TimeToLiveDescription": {
                        "AttributeName": "ExpiresAt",
                        "TimeToLiveStatus": "ENABLED"
                    }
                });
            }
        }
        return notFoundResponse();
    }
}

isolated function highScoreItem(string gameId, string score, string player) returns json => {
    "GameId": {"S": gameId},
    "Score": {"N": score},
    "PlayerName": {"S": player}
};

isolated function tableDescription(string status) returns json => {
    "TableName": testTableName,
    "TableStatus": status,
    "TableArn": "arn:aws:dynamodb:us-east-1:123456789012:table/" + testTableName,
    "TableId": "table-id-1",
    "ItemCount": 2,
    "TableSizeBytes": 128,
    "CreationDateTime": 1767225600,
    "AttributeDefinitions": [
        {"AttributeName": "GameId", "AttributeType": "S"},
        {"AttributeName": "Score", "AttributeType": "N"}
    ],
    "KeySchema": [
        {"AttributeName": "GameId", "KeyType": "HASH"},
        {"AttributeName": "Score", "KeyType": "RANGE"}
    ],
    "ProvisionedThroughput": {"ReadCapacityUnits": 5, "WriteCapacityUnits": 5}
};

isolated function itemDescription() returns json => {
    "Attributes": highScoreItem("FlappyBird", "500", "PlayerOne"),
    "ConsumedCapacity": {"TableName": testTableName, "CapacityUnits": 1.0}
};

// Page 1 carries a table and a continuation token; page 2 is empty yet still carries a token — a valid response the
// service does return, and the shape that used to panic the iterator; page 3 closes the result set.
isolated function listTablesPage() returns json {
    int call;
    lock {
        mockState.listTablesCallCount += 1;
        call = mockState.listTablesCallCount;
    }
    if call == 1 {
        return {"TableNames": [testTableName], "LastEvaluatedTableName": testTableName};
    }
    if call == 2 {
        return {"TableNames": [], "LastEvaluatedTableName": testTableName};
    }
    return {"TableNames": ["OtherTable"]};
}

// Two pages of scan results, the second closing the result set.
isolated function scanPage() returns json {
    int call;
    lock {
        mockState.scanCallCount += 1;
        call = mockState.scanCallCount;
    }
    if call == 1 {
        return {
            "Items": [highScoreItem("FlappyBird", "500", "PlayerOne")],
            "Count": 1,
            "ScannedCount": 1,
            "LastEvaluatedKey": {"GameId": {"S": "FlappyBird"}, "Score": {"N": "500"}},
            "ConsumedCapacity": {"TableName": testTableName, "CapacityUnits": 1.0}
        };
    }
    return {
        "Items": [highScoreItem("Tetris", "900", "PlayerTwo")],
        "Count": 1,
        "ScannedCount": 1,
        "ConsumedCapacity": {"TableName": testTableName, "CapacityUnits": 1.0}
    };
}

// An empty first page that still carries a continuation token, then the results, then the close.
isolated function queryPage() returns json {
    int call;
    lock {
        mockState.queryCallCount += 1;
        call = mockState.queryCallCount;
    }
    if call == 1 {
        return {
            "Items": [],
            "Count": 0,
            "LastEvaluatedKey": {"GameId": {"S": "FlappyBird"}, "Score": {"N": "100"}}
        };
    }
    if call == 2 {
        return {
            "Items": [
                highScoreItem("FlappyBird", "500", "PlayerOne"),
                highScoreItem("FlappyBird", "400", "PlayerThree")
            ],
            "Count": 2,
            "LastEvaluatedKey": {"GameId": {"S": "FlappyBird"}, "Score": {"N": "400"}},
            "ConsumedCapacity": {"TableName": testTableName, "CapacityUnits": 1.0}
        };
    }
    return {"Items": [], "Count": 0};
}

// The first batch leaves one key unprocessed, which the iterator must re-request.
isolated function batchGetPage(json payload) returns json {
    int call;
    lock {
        mockState.batchGetCallCount += 1;
        call = mockState.batchGetCallCount;
    }
    json requestItems = (<map<json>>payload)["RequestItems"];
    if requestItems is map<json> && requestItems.hasKey(TRIGGER_THROTTLE) {
        return {
            "Responses": {},
            "UnprocessedKeys": {
                [TRIGGER_THROTTLE]: {"Keys": [{"GameId": {"S": "Tetris"}, "Score": {"N": "900"}}]}
            }
        };
    }
    if call == 1 {
        return {
            "Responses": {[testTableName]: [highScoreItem("FlappyBird", "500", "PlayerOne")]},
            "UnprocessedKeys": {
                [testTableName]: {"Keys": [{"GameId": {"S": "Tetris"}, "Score": {"N": "900"}}]}
            },
            "ConsumedCapacity": [{"TableName": testTableName, "CapacityUnits": 1.0}]
        };
    }
    return {
        "Responses": {[testTableName]: [highScoreItem("Tetris", "900", "PlayerTwo")]},
        "UnprocessedKeys": {},
        "ConsumedCapacity": [{"TableName": testTableName, "CapacityUnits": 1.0}]
    };
}

isolated function okResponse(json payload) returns http:Response {
    http:Response response = new;
    response.statusCode = http:STATUS_OK;
    response.setJsonPayload(payload);
    return response;
}

isolated function notFoundResponse() returns http:Response {
    http:Response response = new;
    response.statusCode = http:STATUS_BAD_REQUEST;
    response.setHeader(REQUEST_ID_HEADER, MOCK_REQUEST_ID);
    response.setJsonPayload({
        "__type": "com.amazonaws.dynamodb.v20120810#ResourceNotFoundException",
        "message": "Requested resource not found"
    });
    return response;
}

// A failure whose body is not JSON at all — what a gateway in front of the endpoint would return.
isolated function nonJsonErrorResponse() returns http:Response {
    http:Response response = new;
    response.statusCode = http:STATUS_BAD_GATEWAY;
    response.setTextPayload("<html><body>502 Bad Gateway</body></html>", "text/html");
    return response;
}

isolated function newMockClient(BatchRetryConfig? batchRetry = ()) returns Client|error {
    if batchRetry is BatchRetryConfig {
        return new ({
            region: awsRegion,
            auth: {accessKeyId: "MOCKACCESSKEYID", secretAccessKey: "mock-secret-access-key"},
            endpoint: mockEndpoint,
            batchRetry: batchRetry
        });
    }
    return new ({
        region: awsRegion,
        auth: {accessKeyId: "MOCKACCESSKEYID", secretAccessKey: "mock-secret-access-key"},
        endpoint: mockEndpoint
    });
}

isolated function resetMockState() {
    lock {
        mockState = {};
    }
}

isolated function lastRequestPayload() returns json {
    lock {
        return mockState.requestPayload.clone();
    }
}

isolated function lastTargetHeader() returns string {
    lock {
        return mockState.targetHeader;
    }
}

isolated function lastAuthorizationHeader() returns string {
    lock {
        return mockState.authorizationHeader;
    }
}

isolated function lastContentTypeHeader() returns string {
    lock {
        return mockState.contentTypeHeader;
    }
}

isolated function listTablesCallCount() returns int {
    lock {
        return mockState.listTablesCallCount;
    }
}

isolated function scanCallCount() returns int {
    lock {
        return mockState.scanCallCount;
    }
}

isolated function batchGetCallCount() returns int {
    lock {
        return mockState.batchGetCallCount;
    }
}
