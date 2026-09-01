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

import ballerina/http;
import ballerinax/aws;
import ballerinax/aws.auth;

# The Ballerina AWS DynamoDB connector provides the capability to programmatically manage Amazon DynamoDB tables
# and the items they hold.
@display {label: "Amazon DynamoDB", iconPath: "icon.png"}
public isolated client class Client {
    private final http:Client awsDynamoDb;
    private final auth:CredentialProvider credentialProvider;
    private final aws:Region|string region;
    private final string host;
    private final readonly & BatchRetryConfig batchRetry;

    # Initializes the connector.
    # ```ballerina
    # dynamodb:Client dynamoDb = check new ({
    #     auth: {
    #         accessKeyId: "<AWS_ACCESS_KEY_ID>",
    #         secretAccessKey: "<AWS_SECRET_ACCESS_KEY>"
    #     },
    #     region: aws:US_EAST_1
    # });
    # ```
    #
    # + config - Configuration required to initialize the client
    # + return - An `error` on failure of initialization, or else `()`
    public isolated function init(ConnectionConfig config) returns error? {
        http:ClientConfiguration httpClientConfig = {httpVersion: config.httpVersion, http1Settings: config.http1Settings, http2Settings: config.http2Settings, timeout: config.timeout, forwarded: config.forwarded, followRedirects: config.followRedirects, poolConfig: config.poolConfig, cache: config.cache, compression: config.compression, circuitBreaker: config.circuitBreaker, retryConfig: config.retryConfig, cookieConfig: config.cookieConfig, responseLimits: config.responseLimits, secureSocket: config.secureSocket, proxy: config.proxy, socketConfig: config.socketConfig, validation: config.validation, laxDataBinding: config.laxDataBinding};
        self.region = config.region;
        // Both resolvers default the config to `{}`, which is what an absent `endpoint` means.
        aws:EndpointConfig endpointConfig = config.endpoint ?: {};
        self.host = aws:resolveEndpointHost(SERVICE_NAME, config.region, endpointConfig);
        string baseURL = aws:resolveEndpoint(SERVICE_NAME, config.region, endpointConfig);
        self.batchRetry = config.batchRetry.cloneReadOnly();
        self.awsDynamoDb = check new (baseURL, httpClientConfig);
        self.credentialProvider = check new (config.auth);
    }

    # Creates a table. The CreateTable operation adds a new table to your account. In an AWS account, table names must
    # be unique within each Region. That is, you can have two tables with same name if you create the tables in
    # diﬀerent Regions.
    # ```ballerina
    # dynamodb:TableDescription description = check dynamoDb->createTable({
    #     TableName: "HighScores",
    #     AttributeDefinitions: [{AttributeName: "GameId", AttributeType: "S"}],
    #     KeySchema: [{AttributeName: "GameId", KeyType: "HASH"}],
    #     BillingMode: "PAY_PER_REQUEST"
    # });
    # ```
    #
    # + tableCreationInput - The request payload to create a table
    # + return - If success, `dynamodb:TableDescription` record, else an `dynamodb:Error`
    remote isolated function createTable(TableCreateInput tableCreationInput) returns TableDescription|Error {
        json response = check self.execute(TARGET_CREATE_TABLE, tableCreationInput.toJson());
        do {
            json tableDescription = check response.TableDescription;
            return check tableDescription.fromJsonWithType();
        } on fail error e {
            return error ResponseHandlingError(string `Error occurred while processing the CreateTable response: ${
                    e.message()}`, e);
        }
    }

    # Deletes a table.
    # ```ballerina
    # dynamodb:TableDescription description = check dynamoDb->deleteTable("HighScores");
    # ```
    #
    # + tableName - The name of the table to delete
    # + return - If success, `dynamodb:TableDescription` record, else an `dynamodb:Error`
    remote isolated function deleteTable(string tableName) returns TableDescription|Error {
        json response = check self.execute(TARGET_DELETE_TABLE, {"TableName": tableName});
        do {
            json tableDescription = check response.TableDescription;
            return check tableDescription.fromJsonWithType();
        } on fail error e {
            return error ResponseHandlingError(string `Error occurred while processing the DeleteTable response: ${
                    e.message()}`, e);
        }
    }

    # Describes a table.
    # ```ballerina
    # dynamodb:TableDescription description = check dynamoDb->describeTable("HighScores");
    # ```
    #
    # + tableName - The name of the table to describe
    # + return - If success, `dynamodb:TableDescription` record, else an `dynamodb:Error`
    remote isolated function describeTable(string tableName) returns TableDescription|Error {
        json response = check self.execute(TARGET_DESCRIBE_TABLE, {"TableName": tableName});
        do {
            json tableDescription = check response.Table;
            return check tableDescription.fromJsonWithType();
        } on fail error e {
            return error ResponseHandlingError(string `Error occurred while processing the DescribeTable response: ${
                    e.message()}`, e);
        }
    }

    # Lists all tables. The returned stream fetches the next page of table names only once the current page has been
    # consumed.
    # ```ballerina
    # stream<string, dynamodb:Error?> tables = check dynamoDb->listTables();
    # ```
    #
    # + return - If success, `stream<string, dynamodb:Error?>`, else an `dynamodb:Error`
    remote isolated function listTables() returns stream<string, Error?>|Error {
        TableStream tableStream = check new (self.listTablesPage);
        return new stream<string, Error?>(tableStream);
    }

    # Updates a table.
    # ```ballerina
    # dynamodb:TableDescription description = check dynamoDb->updateTable({
    #     TableName: "HighScores",
    #     BillingMode: "PAY_PER_REQUEST"
    # });
    # ```
    #
    # + tableUpdateInput - The request payload to update a table
    # + return - If success, `dynamodb:TableDescription` record, else an `dynamodb:Error`
    remote isolated function updateTable(TableUpdateInput tableUpdateInput) returns TableDescription|Error {
        json response = check self.execute(TARGET_UPDATE_TABLE, tableUpdateInput.toJson());
        do {
            json tableDescription = check response.TableDescription;
            return check tableDescription.fromJsonWithType();
        } on fail error e {
            return error ResponseHandlingError(string `Error occurred while processing the UpdateTable response: ${
                    e.message()}`, e);
        }
    }

    # Creates a new item, or replaces an old item with a new item. If an item that has the same primary key as the new
    # item already exists in the speciﬁed table, the new item completely replaces the existing item. You can perform a
    # conditional put operation (add a new item if one with the speciﬁed primary key doesn't exist), or replace an
    # existing item if it has certain attribute values.
    # ```ballerina
    # dynamodb:ItemDescription item = check dynamoDb->createItem({
    #     TableName: "HighScores",
    #     Item: {"GameId": {S: "FlappyBird"}, "Score": {N: "500"}}
    # });
    # ```
    #
    # + itemCreateInput - The request payload to create an item
    # + return - If success, `dynamodb:ItemDescription` record, else an `dynamodb:Error`
    remote isolated function createItem(ItemCreateInput itemCreateInput) returns ItemDescription|Error {
        json response = check self.execute(TARGET_PUT_ITEM, itemCreateInput.toJson());
        do {
            return check response.fromJsonWithType();
        } on fail error e {
            return error ResponseHandlingError(string `Error occurred while processing the PutItem response: ${
                    e.message()}`, e);
        }
    }

    # Gets an item.
    # ```ballerina
    # dynamodb:ItemGetOutput item = check dynamoDb->getItem({
    #     TableName: "HighScores",
    #     Key: {"GameId": {S: "FlappyBird"}, "Score": {N: "500"}}
    # });
    # ```
    #
    # + itemGetInput - The request payload to get an item
    # + return - If success, `dynamodb:ItemGetOutput` record, else an `dynamodb:Error`
    remote isolated function getItem(ItemGetInput itemGetInput) returns ItemGetOutput|Error {
        json response = check self.execute(TARGET_GET_ITEM, itemGetInput.toJson());
        do {
            return check response.fromJsonWithType();
        } on fail error e {
            return error ResponseHandlingError(string `Error occurred while processing the GetItem response: ${
                    e.message()}`, e);
        }
    }

    # Deletes an item.
    # ```ballerina
    # dynamodb:ItemDescription item = check dynamoDb->deleteItem({
    #     TableName: "HighScores",
    #     Key: {"GameId": {S: "FlappyBird"}, "Score": {N: "500"}}
    # });
    # ```
    #
    # + itemDeleteInput - The request payload to delete an item
    # + return - If success, `dynamodb:ItemDescription` record, else an `dynamodb:Error`
    remote isolated function deleteItem(ItemDeleteInput itemDeleteInput) returns ItemDescription|Error {
        json response = check self.execute(TARGET_DELETE_ITEM, itemDeleteInput.toJson());
        do {
            return check response.fromJsonWithType();
        } on fail error e {
            return error ResponseHandlingError(string `Error occurred while processing the DeleteItem response: ${
                    e.message()}`, e);
        }
    }

    # Updates an item.
    # ```ballerina
    # dynamodb:ItemDescription item = check dynamoDb->updateItem({
    #     TableName: "HighScores",
    #     Key: {"GameId": {S: "FlappyBird"}, "Score": {N: "500"}},
    #     UpdateExpression: "SET PlayerName = :name",
    #     ExpressionAttributeValues: {":name": {S: "NewPlayer"}}
    # });
    # ```
    #
    # + itemUpdateInput - The request payload to update an item
    # + return - If success, `dynamodb:ItemDescription` record, else an `dynamodb:Error`
    remote isolated function updateItem(ItemUpdateInput itemUpdateInput) returns ItemDescription|Error {
        json response = check self.execute(TARGET_UPDATE_ITEM, itemUpdateInput.toJson());
        do {
            return check response.fromJsonWithType();
        } on fail error e {
            return error ResponseHandlingError(string `Error occurred while processing the UpdateItem response: ${
                    e.message()}`, e);
        }
    }

    # Returns all items with a particular partition key value. You must provide the name of the partition key attribute
    # and a single value for that attribute. Optionally, you can provide a sort key attribute and use a comparison
    # operator to reﬁne the search results. The returned stream fetches the next page of items only once the current
    # page has been consumed.
    # ```ballerina
    # stream<dynamodb:QueryOutput, dynamodb:Error?> items = check dynamoDb->query({
    #     TableName: "HighScores",
    #     KeyConditionExpression: "GameId = :gameId",
    #     ExpressionAttributeValues: {":gameId": {S: "FlappyBird"}}
    # });
    # ```
    #
    # + queryInput - The request payload to query
    # + return - If success, `stream<dynamodb:QueryOutput, dynamodb:Error?>`, else an `dynamodb:Error`
    remote isolated function query(QueryInput queryInput) returns stream<QueryOutput, Error?>|Error {
        QueryStream queryStream = check new (queryInput, self.queryPage);
        return new stream<QueryOutput, Error?>(queryStream);
    }

    # Returns one or more items and item attributes by accessing every item in a table or a secondary index. The
    # returned stream fetches the next page of items only once the current page has been consumed.
    # ```ballerina
    # stream<dynamodb:ScanOutput, dynamodb:Error?> items = check dynamoDb->scan({TableName: "HighScores"});
    # ```
    #
    # + scanInput - The request payload to scan
    # + return - If success, `stream<dynamodb:ScanOutput, dynamodb:Error?>`, else an `dynamodb:Error`
    remote isolated function scan(ScanInput scanInput) returns stream<ScanOutput, Error?>|Error {
        ScanStream scanStream = check new (scanInput, self.scanPage);
        return new stream<ScanOutput, Error?>(scanStream);
    }

    # Returns the attributes of one or more items from one or more tables. You identify requested items by primary key.
    # The returned stream re-requests any unprocessed keys only once the current page has been consumed.
    # ```ballerina
    # stream<dynamodb:BatchItem, dynamodb:Error?> items = check dynamoDb->getBatchItems({
    #     RequestItems: {"HighScores": {Keys: [{"GameId": {S: "FlappyBird"}, "Score": {N: "500"}}]}}
    # });
    # ```
    #
    # + batchItemGetInput - The request payload to get items as batch
    # + return - If success, `stream<dynamodb:BatchItem, dynamodb:Error?>`, else an `dynamodb:Error`
    remote isolated function getBatchItems(BatchItemGetInput batchItemGetInput) returns stream<BatchItem, Error?>|Error {
        ItemsBatchGetStream itemsBatchGetStream = check new (batchItemGetInput, self.batchGetItemPage,
                self.batchRetry);
        return new stream<BatchItem, Error?>(itemsBatchGetStream);
    }

    # Puts or deletes multiple items in one or more tables.
    # ```ballerina
    # dynamodb:BatchItemInsertOutput result = check dynamoDb->writeBatchItems({
    #     RequestItems: {
    #         "HighScores": [{PutRequest: {Item: {"GameId": {S: "FlappyBird"}, "Score": {N: "500"}}}}]
    #     }
    # });
    # ```
    #
    # + batchItemInsertInput - The request payload to write items as batch
    # + return - If success, `dynamodb:BatchItemInsertOutput` record, else an `dynamodb:Error`
    remote isolated function writeBatchItems(BatchItemInsertInput batchItemInsertInput)
            returns BatchItemInsertOutput|Error {
        json response = check self.execute(TARGET_BATCH_WRITE_ITEM, batchItemInsertInput.toJson());
        do {
            return check response.fromJsonWithType();
        } on fail error e {
            return error ResponseHandlingError(string `Error occurred while processing the BatchWriteItem response: ${
                    e.message()}`, e);
        }
    }

    # Returns the current provisioned-capacity quotas for your AWS account in a Region, both for the Region as a whole
    # and for any one DynamoDB table that you create there.
    # ```ballerina
    # dynamodb:LimitDescription limits = check dynamoDb->describeLimits();
    # ```
    #
    # + return - If success, `dynamodb:LimitDescription` record, else an `dynamodb:Error`
    remote isolated function describeLimits() returns LimitDescription|Error {
        json response = check self.execute(TARGET_DESCRIBE_LIMITS, {});
        do {
            return check response.fromJsonWithType();
        } on fail error e {
            return error ResponseHandlingError(string `Error occurred while processing the DescribeLimits response: ${
                    e.message()}`, e);
        }
    }

    # Creates a backup from the given table.
    # ```ballerina
    # dynamodb:BackupDetails backup = check dynamoDb->createBackup({
    #     TableName: "HighScores",
    #     BackupName: "HighScoresBackup"
    # });
    # ```
    #
    # + backupCreateInput - The request payload to backup the table
    # + return - If success, `dynamodb:BackupDetails` record, else an `dynamodb:Error`
    remote isolated function createBackup(BackupCreateInput backupCreateInput) returns BackupDetails|Error {
        json response = check self.execute(TARGET_CREATE_BACKUP, backupCreateInput.toJson());
        do {
            json backupDetails = check response.BackupDetails;
            return check backupDetails.fromJsonWithType();
        } on fail error e {
            return error ResponseHandlingError(string `Error occurred while processing the CreateBackup response: ${
                    e.message()}`, e);
        }
    }

    # Deletes an existing backup of a table.
    # ```ballerina
    # dynamodb:BackupDescription backup = check dynamoDb->deleteBackup(backupArn);
    # ```
    #
    # + backupArn - The backupArn of the backup that needs to be deleted
    # + return - If success, `dynamodb:BackupDescription` record, else an `dynamodb:Error`
    remote isolated function deleteBackup(string backupArn) returns BackupDescription|Error {
        json response = check self.execute(TARGET_DELETE_BACKUP, {"BackupArn": backupArn});
        do {
            json backupDescription = check response.BackupDescription;
            return check backupDescription.fromJsonWithType();
        } on fail error e {
            return error ResponseHandlingError(string `Error occurred while processing the DeleteBackup response: ${
                    e.message()}`, e);
        }
    }

    # The description of the Time to Live (TTL) status on the specified table.
    # ```ballerina
    # dynamodb:TTLDescription ttl = check dynamoDb->getTTL("HighScores");
    # ```
    #
    # + tableName - The name of the table
    # + return - If success, `dynamodb:TTLDescription` record, else an `dynamodb:Error`
    remote isolated function getTTL(string tableName) returns TTLDescription|Error {
        json response = check self.execute(TARGET_DESCRIBE_TIME_TO_LIVE, {"TableName": tableName});
        do {
            json timeToLiveDescription = check response.TimeToLiveDescription;
            return check timeToLiveDescription.fromJsonWithType();
        } on fail error e {
            return error ResponseHandlingError(string `Error occurred while processing the DescribeTimeToLive response: ${
                    e.message()}`, e);
        }
    }

    # Releases the resources held by the credential provider: its background refresh threads, and the HTTP
    # connections it keeps open to reach STS/SSO.
    # ```ballerina
    # check dynamoDb.close();
    # ```
    #
    # + return - An `dynamodb:Error` if releasing the resources fails, or else `()`
    public isolated function close() returns Error? {
        auth:Error? result = self.credentialProvider.close();
        if result is auth:Error {
            return error Error(string `Error occurred while closing the AWS credential provider: ${
                    result.message()}`, result);
        }
    }

    // Signs and sends a single operation request, returning the raw JSON response payload.
    private isolated function execute(string target, json payload) returns json|Error {
        http:Request request = check generateRequest(self.credentialProvider, self.host, self.region, target, payload);
        return sendRequest(self.awsDynamoDb, request);
    }

    private isolated function listTablesPage(string? exclusiveStartTableName) returns TableList|Error {
        TableListRequest request = {ExclusiveStartTableName: exclusiveStartTableName};
        json response = check self.execute(TARGET_LIST_TABLES, request.toJson());
        do {
            return check response.fromJsonWithType();
        } on fail error e {
            return error ResponseHandlingError(string `Error occurred while processing the ListTables response: ${
                    e.message()}`, e);
        }
    }

    private isolated function scanPage(ScanInput request) returns QueryOrScanOutput|Error {
        json response = check self.execute(TARGET_SCAN, request.toJson());
        do {
            return check response.fromJsonWithType();
        } on fail error e {
            return error ResponseHandlingError(string `Error occurred while processing the Scan response: ${
                    e.message()}`, e);
        }
    }

    private isolated function queryPage(QueryInput request) returns QueryOrScanOutput|Error {
        json response = check self.execute(TARGET_QUERY, request.toJson());
        do {
            return check response.fromJsonWithType();
        } on fail error e {
            return error ResponseHandlingError(string `Error occurred while processing the Query response: ${
                    e.message()}`, e);
        }
    }

    private isolated function batchGetItemPage(BatchItemGetInput request) returns BatchGetItemsOutput|Error {
        json response = check self.execute(TARGET_BATCH_GET_ITEM, request.toJson());
        do {
            return check response.fromJsonWithType();
        } on fail error e {
            return error ResponseHandlingError(string `Error occurred while processing the BatchGetItem response: ${
                    e.message()}`, e);
        }
    }
}
