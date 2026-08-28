// Copyright (c) 2021, WSO2 LLC. (http://www.wso2.com).
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

import ballerina/lang.runtime;
import ballerina/random;
import ballerina/test;
import ballerinax/aws;
import ballerinax/aws.auth;

@test:Config {groups: ["init"]}
isolated function testInitUsingStaticAuthAndClose() returns error? {
    Client dynamoDbClient = check newMockClient();
    check dynamoDbClient.close();
}

@test:Config {groups: ["init"]}
isolated function testUnresolvableCredentialsFailInit() {
    Client|error result = new ({
        region: awsRegion,
        auth: {profileName: "no-such-profile", credentialsFilePath: "./tests/resources/no-such-credentials"},
        endpoint: mockEndpoint
    });
    if result is Client {
        test:assertFail("expected an error when the credentials cannot be resolved");
    }
    test:assertTrue(result is auth:CredentialResolutionError, "unexpected error: " + result.message());
}

@test:Config {groups: ["init"]}
isolated function testInitUsingPlainRegionString() returns error? {
    Client dynamoDbClient = check new ({
        region: "us-east-1",
        auth: {accessKeyId: "MOCKACCESSKEYID", secretAccessKey: "mock-secret-access-key"},
        endpoint: mockEndpoint
    });
    check dynamoDbClient.close();
}

@test:Config {groups: ["operations", "table"]}
isolated function testCreateTable() returns error? {
    resetMockState();
    TableDescription description = check dynamoDb->createTable({
        TableName: testTableName,
        AttributeDefinitions: [
            {AttributeName: "GameId", AttributeType: S},
            {AttributeName: "Score", AttributeType: N}
        ],
        KeySchema: [
            {AttributeName: "GameId", KeyType: HASH},
            {AttributeName: "Score", KeyType: RANGE}
        ],
        ProvisionedThroughput: {ReadCapacityUnits: 5, WriteCapacityUnits: 5}
    });
    test:assertEquals(description?.TableName, testTableName);
    test:assertEquals(description?.TableStatus, CREATING);
    test:assertEquals(lastTargetHeader(), TARGET_CREATE_TABLE);

    // The request must carry the AWS wire names verbatim.
    map<json> payload = check lastRequestPayload().ensureType();
    test:assertEquals(payload["TableName"], testTableName);
    test:assertTrue(payload.hasKey("AttributeDefinitions"));
    test:assertTrue(payload.hasKey("KeySchema"));
}

@test:Config {groups: ["operations", "table"]}
isolated function testDescribeTable() returns error? {
    resetMockState();
    TableDescription description = check dynamoDb->describeTable(testTableName);
    test:assertEquals(description?.TableName, testTableName);
    test:assertEquals(description?.TableStatus, ACTIVE);
    test:assertEquals(description?.ItemCount, 2);
    KeySchemaElement[] keySchema = check description?.KeySchema.ensureType();
    test:assertEquals(keySchema.length(), 2);
    test:assertEquals(keySchema[0].AttributeName, "GameId");
    test:assertEquals(keySchema[0].KeyType, HASH);
    test:assertEquals(lastTargetHeader(), TARGET_DESCRIBE_TABLE);
}

@test:Config {groups: ["operations", "table"]}
isolated function testUpdateTable() returns error? {
    resetMockState();
    TableDescription description = check dynamoDb->updateTable({
        TableName: testTableName,
        ProvisionedThroughput: {ReadCapacityUnits: 10, WriteCapacityUnits: 10}
    });
    test:assertEquals(description?.TableStatus, UPDATING);
    test:assertEquals(lastTargetHeader(), TARGET_UPDATE_TABLE);
}

@test:Config {groups: ["operations", "table"]}
isolated function testDeleteTable() returns error? {
    resetMockState();
    TableDescription description = check dynamoDb->deleteTable(testTableName);
    test:assertEquals(description?.TableStatus, DELETING);
    test:assertEquals(lastTargetHeader(), TARGET_DELETE_TABLE);

    map<json> payload = check lastRequestPayload().ensureType();
    test:assertEquals(payload["TableName"], testTableName);
}

// The result set is three pages, the middle one empty but still carrying a continuation token. That page must be
// skipped rather than mistaken for the end of the result set — and must not be indexed into.
@test:Config {groups: ["operations", "table"]}
isolated function testListTablesPaginatesAcrossAnEmptyPage() returns error? {
    resetMockState();
    stream<string, Error?> tables = check dynamoDb->listTables();
    string[] names = [];
    check from string name in tables
        do {
            names.push(name);
        };
    test:assertEquals(names, [testTableName, "OtherTable"]);
    test:assertEquals(listTablesCallCount(), 3, "expected all three pages to be fetched");
}

@test:Config {groups: ["operations", "item"]}
isolated function testCreateItem() returns error? {
    resetMockState();
    ItemDescription item = check dynamoDb->createItem({
        TableName: testTableName,
        Item: {"GameId": {S: "FlappyBird"}, "Score": {N: "500"}, "PlayerName": {S: "PlayerOne"}}
    });
    map<AttributeValue> attributes = check item?.Attributes.ensureType();
    test:assertEquals(attributes["GameId"]?.S, "FlappyBird");
    test:assertEquals(lastTargetHeader(), TARGET_PUT_ITEM);
}

@test:Config {groups: ["operations", "item"]}
isolated function testGetItem() returns error? {
    resetMockState();
    ItemGetOutput output = check dynamoDb->getItem({
        TableName: testTableName,
        Key: {"GameId": {S: "FlappyBird"}, "Score": {N: "500"}}
    });
    map<AttributeValue> item = check output?.Item.ensureType();
    // Attribute names are user data and must survive the round trip verbatim.
    test:assertTrue(item.hasKey("PlayerName"), "expected the PlayerName attribute name to be preserved");
    test:assertEquals(item["PlayerName"]?.S, "PlayerOne");
    test:assertEquals(item["Score"]?.N, "500");
    test:assertEquals(lastTargetHeader(), TARGET_GET_ITEM);
}

@test:Config {groups: ["operations", "item"]}
isolated function testUpdateItem() returns error? {
    resetMockState();
    ItemDescription item = check dynamoDb->updateItem({
        TableName: testTableName,
        Key: {"GameId": {S: "FlappyBird"}, "Score": {N: "500"}},
        UpdateExpression: "SET PlayerName = :name",
        ExpressionAttributeValues: {":name": {S: "NewPlayer"}}
    });
    test:assertTrue(item?.Attributes is map<AttributeValue>);
    test:assertEquals(lastTargetHeader(), TARGET_UPDATE_ITEM);

    map<json> payload = check lastRequestPayload().ensureType();
    test:assertEquals(payload["UpdateExpression"], "SET PlayerName = :name");
}

@test:Config {groups: ["operations", "item"]}
isolated function testDeleteItem() returns error? {
    resetMockState();
    ItemDescription item = check dynamoDb->deleteItem({
        TableName: testTableName,
        Key: {"GameId": {S: "FlappyBird"}, "Score": {N: "500"}}
    });
    test:assertTrue(item?.Attributes is map<AttributeValue>);
    test:assertEquals(lastTargetHeader(), TARGET_DELETE_ITEM);
}

// The first query page comes back empty while still carrying a continuation token.
@test:Config {groups: ["operations", "query"]}
isolated function testQueryPaginatesAcrossAnEmptyPage() returns error? {
    resetMockState();
    stream<QueryOutput, Error?> results = check dynamoDb->query({
        TableName: testTableName,
        KeyConditionExpression: "GameId = :gameId",
        ExpressionAttributeValues: {":gameId": {S: "FlappyBird"}}
    });
    string[] players = [];
    check from QueryOutput result in results
        do {
            map<AttributeValue> item = check result?.Item.ensureType();
            players.push(item["PlayerName"]?.S ?: "");
        };
    test:assertEquals(players, ["PlayerOne", "PlayerThree"]);
}

@test:Config {groups: ["operations", "scan"]}
isolated function testScanPaginates() returns error? {
    resetMockState();
    stream<ScanOutput, Error?> results = check dynamoDb->scan({TableName: testTableName});
    string[] games = [];
    check from ScanOutput result in results
        do {
            map<AttributeValue> item = check result?.Item.ensureType();
            games.push(item["GameId"]?.S ?: "");
        };
    test:assertEquals(games, ["FlappyBird", "Tetris"]);
    test:assertEquals(scanCallCount(), 2, "expected both scan pages to be fetched");
}

// The first batch leaves one key unprocessed; the iterator must re-request exactly those keys.
@test:Config {groups: ["operations", "batch"]}
isolated function testGetBatchItemsRetriesUnprocessedKeys() returns error? {
    resetMockState();
    stream<BatchItem, Error?> results = check dynamoDb->getBatchItems({
        RequestItems: {
            [testTableName]: {
                Keys: [
                    {"GameId": {S: "FlappyBird"}, "Score": {N: "500"}},
                    {"GameId": {S: "Tetris"}, "Score": {N: "900"}}
                ]
            }
        }
    });
    string[] games = [];
    check from BatchItem result in results
        do {
            test:assertEquals(result?.TableName, testTableName);
            map<AttributeValue> item = check result?.Item.ensureType();
            games.push(item["GameId"]?.S ?: "");
        };
    test:assertEquals(games, ["FlappyBird", "Tetris"]);
    test:assertEquals(batchGetCallCount(), 2, "expected the unprocessed keys to be re-requested");

    // The retry must ask only for what was left unprocessed, not for the original key set again.
    map<json> payload = check lastRequestPayload().ensureType();
    map<json> requestItems = check payload["RequestItems"].ensureType();
    map<json> tableRequest = check requestItems[testTableName].ensureType();
    json[] keys = check tableRequest["Keys"].ensureType();
    test:assertEquals(keys.length(), 1);
}

// A table that is throttled continuously hands back the same keys unprocessed with no items. The iterator must
// give up rather than re-request them in a tight loop, which is what AWS warns against.
@test:Config {groups: ["operations", "batch"]}
isolated function testGetBatchItemsGivesUpOnPersistentThrottling() returns error? {
    resetMockState();
    stream<BatchItem, Error?> results = check dynamoDb->getBatchItems({
        RequestItems: {[TRIGGER_THROTTLE]: {Keys: [{"GameId": {S: "Tetris"}, "Score": {N: "900"}}]}}
    });

    // The first fetch succeeds — it simply serves nothing — so the failure surfaces as the stream is consumed.
    record {|BatchItem value;|}|Error? next = results.next();
    if next !is Error {
        test:assertFail("expected the throttled batch to be abandoned");
    }
    test:assertTrue(next.message().includes("consecutive attempt(s)"), "unexpected: " + next.message());
    test:assertTrue(next.message().includes("1 key(s) still unprocessed"),
            "the error should say how much of the batch was left: " + next.message());

    // Bounded: the initial fetch plus its retries, rather than an unbounded spin.
    test:assertEquals(batchGetCallCount(), DEFAULT_MAX_UNPRODUCTIVE_BATCH_ATTEMPTS + 1);
}

// The retry budget is configurable, so a caller that wants to fail fast can say so.
@test:Config {groups: ["operations", "batch"]}
isolated function testBatchRetryBudgetIsConfigurable() returns error? {
    resetMockState();
    Client failFast = check newMockClient({initialInterval: 0.001, maxInterval: 0.002, maxUnproductiveAttempts: 2});
    stream<BatchItem, Error?> results = check failFast->getBatchItems({
        RequestItems: {[TRIGGER_THROTTLE]: {Keys: [{"GameId": {S: "Tetris"}, "Score": {N: "900"}}]}}
    });
    record {|BatchItem value;|}|Error? next = results.next();
    if next !is Error {
        test:assertFail("expected the throttled batch to be abandoned");
    }
    test:assertTrue(next.message().includes("no items in 3 consecutive attempt(s)"), "unexpected: " + next.message());
    test:assertEquals(batchGetCallCount(), 3, "expected the initial fetch plus the two configured retries");
    check failFast.close();
}

// A budget of zero abandons the batch on the very first empty response. The initial request is that response, so
// the failure surfaces from `getBatchItems` itself rather than from the stream.
@test:Config {groups: ["operations", "batch"]}
isolated function testBatchRetryBudgetOfZeroFailsImmediately() returns error? {
    resetMockState();
    Client noRetry = check newMockClient({maxUnproductiveAttempts: 0});
    stream<BatchItem, Error?>|Error results = noRetry->getBatchItems({
        RequestItems: {[TRIGGER_THROTTLE]: {Keys: [{"GameId": {S: "Tetris"}, "Score": {N: "900"}}]}}
    });
    if results !is Error {
        test:assertFail("expected the batch to be abandoned without retrying");
    }
    test:assertEquals(batchGetCallCount(), 1, "expected no retry beyond the initial request");
    check noRetry.close();
}

// A wait has to be positive to be a wait, and a negative budget is meaningless: both fall back to the default,
// rather than being taken literally and disabling the backoff or the bound.
@test:Config {groups: ["operations", "batch"]}
isolated function testInvalidBatchRetryConfigFallsBackToDefaults() returns error? {
    resetMockState();
    Client invalid = check newMockClient({initialInterval: 0, maxInterval: -1, maxUnproductiveAttempts: -5});
    stream<BatchItem, Error?> results = check invalid->getBatchItems({
        RequestItems: {[TRIGGER_THROTTLE]: {Keys: [{"GameId": {S: "Tetris"}, "Score": {N: "900"}}]}}
    });
    record {|BatchItem value;|}|Error? next = results.next();
    if next !is Error {
        test:assertFail("expected the throttled batch to be abandoned");
    }
    test:assertTrue(next.message().includes(string `no items in ${DEFAULT_MAX_UNPRODUCTIVE_BATCH_ATTEMPTS + 1} consecutive`),
            "unexpected: " + next.message());
    test:assertEquals(batchGetCallCount(), DEFAULT_MAX_UNPRODUCTIVE_BATCH_ATTEMPTS + 1);
    check invalid.close();
}

@test:Config {groups: ["operations", "batch"]}
isolated function testWriteBatchItems() returns error? {
    resetMockState();
    BatchItemInsertOutput output = check dynamoDb->writeBatchItems({
        RequestItems: {
            [testTableName]: [
                {PutRequest: {Item: {"GameId": {S: "Tetris"}, "Score": {N: "900"}}}},
                {DeleteRequest: {Key: {"GameId": {S: "FlappyBird"}, "Score": {N: "100"}}}}
            ]
        }
    });
    test:assertEquals(output?.UnprocessedItems, {});
    test:assertEquals(lastTargetHeader(), TARGET_BATCH_WRITE_ITEM);
}

@test:Config {groups: ["operations", "limits"]}
isolated function testDescribeLimits() returns error? {
    resetMockState();
    LimitDescription limits = check dynamoDb->describeLimits();
    test:assertEquals(limits?.AccountMaxReadCapacityUnits, 80000);
    test:assertEquals(limits?.TableMaxWriteCapacityUnits, 40000);
    test:assertEquals(lastTargetHeader(), TARGET_DESCRIBE_LIMITS);
    // `DescribeLimits` takes no parameters, so the body must be an empty JSON object rather than an empty string.
    test:assertEquals(lastRequestPayload(), {});
}

@test:Config {groups: ["operations", "backup"]}
isolated function testCreateBackup() returns error? {
    resetMockState();
    BackupDetails details = check dynamoDb->createBackup({
        TableName: testTableName,
        BackupName: "HighScoresBackup"
    });
    test:assertEquals(details.BackupArn, MOCK_BACKUP_ARN);
    test:assertEquals(details.BackupStatus, "CREATING");
    test:assertEquals(lastTargetHeader(), TARGET_CREATE_BACKUP);
}

@test:Config {groups: ["operations", "backup"]}
isolated function testDeleteBackup() returns error? {
    resetMockState();
    BackupDescription description = check dynamoDb->deleteBackup(MOCK_BACKUP_ARN);
    BackupDetails details = check description?.BackupDetails.ensureType();
    test:assertEquals(details.BackupStatus, "DELETED");
    test:assertEquals(lastTargetHeader(), TARGET_DELETE_BACKUP);

    map<json> payload = check lastRequestPayload().ensureType();
    test:assertEquals(payload["BackupArn"], MOCK_BACKUP_ARN);
}

@test:Config {groups: ["operations", "ttl"]}
isolated function testGetTTL() returns error? {
    resetMockState();
    TTLDescription ttl = check dynamoDb->getTTL(testTableName);
    test:assertEquals(ttl?.AttributeName, "ExpiresAt");
    test:assertEquals(ttl?.TimeToLiveStatus, ENABLED);
    test:assertEquals(lastTargetHeader(), TARGET_DESCRIBE_TIME_TO_LIVE);
}

@test:Config {groups: ["protocol"]}
isolated function testRequestIsSignedWithSigV4() returns error? {
    resetMockState();
    _ = check dynamoDb->describeTable(testTableName);
    string authorization = lastAuthorizationHeader();
    test:assertTrue(authorization.startsWith("AWS4-HMAC-SHA256 "), "unexpected scheme: " + authorization);
    test:assertTrue(authorization.includes("Credential=MOCKACCESSKEYID/"), "unexpected credential: " + authorization);
    // The credential scope must name the DynamoDB signing service and terminate with `aws4_request`.
    test:assertTrue(authorization.includes("/dynamodb/aws4_request"), "unexpected scope: " + authorization);
    test:assertTrue(authorization.includes("Signature="), "missing signature: " + authorization);
}

// DynamoDB speaks the AWS JSON 1.0 protocol, not plain `application/json`.
@test:Config {groups: ["protocol"]}
isolated function testRequestUsesJson10ContentType() returns error? {
    resetMockState();
    _ = check dynamoDb->describeTable(testTableName);
    test:assertEquals(lastContentTypeHeader(), "application/x-amz-json-1.0");
}

@test:Config {groups: ["errors"]}
isolated function testServiceFailureSurfacesStatusRequestIdAndBody() returns error? {
    resetMockState();
    TableDescription|Error result = dynamoDb->describeTable(TRIGGER_NOT_FOUND);
    if result is TableDescription {
        test:assertFail("expected the service failure to be reported as an error");
    }
    test:assertEquals(result.message(), "The DynamoDB operation failed with status 400");

    aws:ErrorDetails detail = result.detail();
    test:assertEquals(detail.httpStatusCode, 400);
    test:assertEquals(detail.requestId, MOCK_REQUEST_ID);

    // The qualified `__type` is reduced to the bare exception name.
    test:assertEquals(detail.errorCode, "ResourceNotFoundException");
    test:assertEquals(detail.errorMessage, "Requested resource not found");
}

// A failure body that is not the service's JSON 1.0 error document must still be reported, not swallowed.
@test:Config {groups: ["errors"]}
isolated function testNonJsonServiceFailureIsReported() returns error? {
    resetMockState();
    TableDescription|Error result = dynamoDb->describeTable(TRIGGER_NON_JSON_ERROR);
    if result is TableDescription {
        test:assertFail("expected the gateway failure to be reported as an error");
    }
    test:assertEquals(result.message(), "The DynamoDB operation failed with status 502");

    aws:ErrorDetails detail = result.detail();
    test:assertEquals(detail.httpStatusCode, 502);
    // A body that is not the service's JSON 1.0 error document has no exception name to report, so the body
    // itself becomes the message rather than being dropped.
    test:assertEquals(detail.errorCode, "");
    string errorMessage = check detail.errorMessage.ensureType();
    test:assertTrue(errorMessage.includes("Bad Gateway"), "unexpected message: " + errorMessage);
}

// A failure raised while paginating must surface through the stream rather than truncating it silently.
@test:Config {groups: ["errors"]}
isolated function testStreamSurfacesServiceFailure() returns error? {
    resetMockState();
    // The first page is fetched eagerly, so a failure on it surfaces from the `scan` call itself.
    stream<ScanOutput, Error?>|Error results = dynamoDb->scan({TableName: TRIGGER_NOT_FOUND});
    if results !is Error {
        test:assertFail("expected the scan failure to be reported as an error");
    }
    test:assertEquals(results.message(), "The DynamoDB operation failed with status 400");
}

@test:Config {groups: ["errors"]}
isolated function testRequestGenerationErrorIsAnError() {
    // The distinct error subtypes must remain assignable to the module's generic `Error`.
    Error requestGeneration = error RequestGenerationError("cannot sign");
    Error responseHandling = error ResponseHandlingError("cannot bind");
    test:assertTrue(requestGeneration is RequestGenerationError);
    test:assertTrue(responseHandling is ResponseHandlingError);

    // Nothing reached the service on these two, so every detail field stays unset.
    test:assertEquals(requestGeneration.detail(), <aws:ErrorDetails>{});
    test:assertEquals(responseHandling.detail(), <aws:ErrorDetails>{});
}

@test:Config {groups: ["live"], enable: isLiveServer}
function testLiveTableRoundTrip() returns error? {
    Client liveClient = check newLiveClient();
    // A fixed name collides when two runs overlap, and a table left behind by an earlier failure blocks every
    // later run with `ResourceInUseException`. The shared prefix keeps any straggler easy to find.
    string tableName = string `${testTableName}Live${check random:createIntInRange(1, 1000000000)}`;

    string? playerName = ();
    do {
        _ = check liveClient->createTable({
            TableName: tableName,
            AttributeDefinitions: [{AttributeName: "GameId", AttributeType: S}],
            KeySchema: [{AttributeName: "GameId", KeyType: HASH}],
            BillingMode: PAY_PER_REQUEST
        });
        check waitUntilTableActive(liveClient, tableName);

        _ = check liveClient->createItem({
            TableName: tableName,
            Item: {"GameId": {S: "FlappyBird"}, "PlayerName": {S: "PlayerOne"}}
        });

        ItemGetOutput output = check liveClient->getItem({
            TableName: tableName,
            Key: {"GameId": {S: "FlappyBird"}},
            ConsistentRead: true
        });
        map<AttributeValue> item = check output?.Item.ensureType();
        playerName = item["PlayerName"]?.S;

        _ = check liveClient->deleteItem({TableName: tableName, Key: {"GameId": {S: "FlappyBird"}}});
    } on fail error e {
        // Best effort: the table may never have been created, so its deletion is allowed to fail too. Without
        // this, a run that failed part way leaves the table behind in the shared account.
        do {
            _ = check liveClient->deleteTable(tableName);
            check liveClient.close();
        } on fail {
            // Nothing further to do here — the original failure is the one worth reporting.
        }
        return e;
    }

    _ = check liveClient->deleteTable(tableName);
    check liveClient.close();

    // Asserted only once the table is gone: a failed assertion panics, and `on fail` does not catch a panic.
    test:assertEquals(playerName, "PlayerOne");
}

@test:Config {groups: ["live"], enable: isLiveServer}
function testLiveDescribeLimits() returns error? {
    Client liveClient = check newLiveClient();
    LimitDescription limits = check liveClient->describeLimits();
    test:assertTrue(limits?.AccountMaxReadCapacityUnits is int);
    check liveClient.close();
}

// A freshly created table is not immediately usable; poll DescribeTable until it goes ACTIVE.
function waitUntilTableActive(Client liveClient, string tableName) returns error? {
    foreach int _ in 0 ..< 60 {
        TableDescription description = check liveClient->describeTable(tableName);
        if description?.TableStatus == ACTIVE {
            return;
        }
        runtime:sleep(2);
    }
    return error("the table did not become ACTIVE within the expected time");
}
