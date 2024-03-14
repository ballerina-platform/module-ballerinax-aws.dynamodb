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
import ballerinax/'client.config;

# The Ballerina AWS DynamoDB connector provides the capability to access AWS Simple Email Service related operations.
# This connector lets you to to send email messages to your customers.
#
@display {label: "Amazon DynamoDB", iconPath: "icon.png"}
public isolated client class Client {
    private final http:Client awsDynamoDb;
    private final string accessKeyId;
    private final string secretAccessKey;
    private final string? securityToken;
    private final string region;
    private final string awsHost;
    private final string uri = SLASH;

    # Initializes the connector. During initialization you have to pass access key id, secret access key, and region.
    # Create an AWS account and obtain tokens following
    # [this guide](https://docs.aws.amazon.com/IAM/latest/UserGuide/id_credentials_access-keys.html).
    #
    # + awsDynamoDBConfig - Configuration required to initialize the client
    # + httpConfig - HTTP configuration
    # + return - An error on failure of initialization or else `()`
    public isolated function init(ConnectionConfig config) returns error? {
        self.accessKeyId = config.awsCredentials.accessKeyId;
        self.secretAccessKey = config.awsCredentials.secretAccessKey;
        self.securityToken = config.awsCredentials?.securityToken;
        self.region = config.region;
        self.awsHost = AWS_SERVICE + DOT + self.region + DOT + AWS_HOST;
        string endpoint = HTTPS + self.awsHost;

        http:ClientConfiguration httpClientConfig = check config:constructHTTPClientConfig(config);
        self.awsDynamoDb = check new (endpoint, httpClientConfig);
    }

    # Creates a table. The CreateTable operation adds a new table to your account. In an AWS account, table names must be
    # unique within each Region. That is, you can have two tables with same name if you create the tables in diﬀerent
    # Regions.
    #
    # + tableCreationInput - The request payload to create a table
    # + return - If success, dynamodb:TableDescription record, else an error
    remote isolated function createTable(TableCreateInput tableCreationInput) returns TableDescription|error {
        string target = VERSION + DOT + "CreateTable";
        json payload = check tableCreationInput.cloneWithType(json);
        map<string> signedRequestHeaders = check getSignedRequestHeaders(self.awsHost, self.accessKeyId,
                                                                        self.secretAccessKey, self.region,
                                                                        POST, self.uri, target, payload);
        map<json> response = check self.awsDynamoDb->post(self.uri, payload, signedRequestHeaders);
        json tableDescription = check response.TableDescription;
        return tableDescription.cloneWithType(TableDescription);
    }

    # Deletes a table.
    #
    # + tableName - The name of the table to delete
    # + return - If success, dynamodb:TableDescription record, else an error
    remote isolated function deleteTable(string tableName) returns TableDescription|error {
        string target = VERSION + DOT + "DeleteTable";
        json payload = {
            "TableName": tableName
        };

        map<string> signedRequestHeaders = check getSignedRequestHeaders(self.awsHost, self.accessKeyId,
                                                                        self.secretAccessKey, self.region,
                                                                        POST, self.uri, target, payload);
        json response = check self.awsDynamoDb->post(self.uri, payload, signedRequestHeaders);
        json tableDescription = check response.TableDescription;
        return tableDescription.cloneWithType(TableDescription);
    }

    # Describes a table.
    #
    # + tableName - The name of the table to delete
    # + return - If success, dynamodb:TableDescription record, else an error
    remote isolated function describeTable(string tableName) returns TableDescription|error {
        string target = VERSION + DOT + "DescribeTable";
        json payload = {
            "TableName": tableName
        };

        map<string> signedRequestHeaders = check getSignedRequestHeaders(self.awsHost, self.accessKeyId,
                                                                        self.secretAccessKey, self.region,
                                                                        POST, self.uri, target, payload);
        json response = check self.awsDynamoDb->post(self.uri, payload, signedRequestHeaders);
        json 'table = check response.Table;
        return 'table.cloneWithType(TableDescription);
    }

    # Lists all tables.
    #
    # + return - If success, stream<string, error?>, else an error
    remote isolated function listTables() returns stream<string, error?>|error {
        TableStream tableStream = check new TableStream(self.awsDynamoDb, self.awsHost, self.accessKeyId,
            self.secretAccessKey, self.region
        );
        return new stream<string, error?>(tableStream);
    }

    # Updates a table.
    #
    # + tableUpdateInput - The request payload to update a table 
    # + return - If success, dynamodb:TableDescription record, else an error
    remote isolated function updateTable(TableUpdateInput tableUpdateInput) returns TableDescription|error {
        string target = VERSION + DOT + "UpdateTable";
        json payload = check tableUpdateInput.cloneWithType(json);
        map<string> signedRequestHeaders = check getSignedRequestHeaders(self.awsHost, self.accessKeyId,
                                                                        self.secretAccessKey, self.region,
                                                                        POST, self.uri, target, payload);
        json response = check self.awsDynamoDb->post(self.uri, payload, signedRequestHeaders);
        json tableDescription = check response.TableDescription;
        return tableDescription.cloneWithType(TableDescription);
    }

    # Creates a new item, or replaces an old item with a new item. If an item that has the same primary key as the new
    # item already exists in the speciﬁed table, the new item completely replaces the existing item. You can perform a
    # conditional put operation (add a new item if one with the speciﬁed primary key doesn't exist), or replace an
    # existing item if it has certain attribute values.
    #
    # + itemCreateInput - The request payload to create an item
    # + return - If success, dynamodb:ItemDescription record, else an error
    remote isolated function createItem(ItemCreateInput itemCreateInput) returns ItemDescription|error {
        string target = VERSION + DOT + "PutItem";
        json payload = check itemCreateInput.cloneWithType(json);
        map<string> signedRequestHeaders = check getSignedRequestHeaders(self.awsHost, self.accessKeyId,
                                                                        self.secretAccessKey, self.region,
                                                                        POST, self.uri, target, payload);
        json response = check self.awsDynamoDb->post(self.uri, payload, signedRequestHeaders);
        return response.cloneWithType(ItemDescription);
    }

    # Gets an item.
    #
    # + itemGetInput - The request payload to get an item
    # + return - If success, dynamodb:GetItemOutput record, else an error
    remote isolated function getItem(ItemGetInput itemGetInput) returns ItemGetOutput|error {
        string target = VERSION + DOT + "GetItem";
        json payload = check itemGetInput.cloneWithType(json);
        map<string> signedRequestHeaders = check getSignedRequestHeaders(self.awsHost, self.accessKeyId,
                                                                        self.secretAccessKey, self.region,
                                                                        POST, self.uri, target, payload);
        json response = check self.awsDynamoDb->post(self.uri, payload, signedRequestHeaders);
        return response.cloneWithType(ItemGetOutput);
    }

    # Deletes an item.
    #
    # + itemDeleteInput - The request payload to delete an item
    # + return - If success, dynamodb:ItemDescription record, else an error
    remote isolated function deleteItem(ItemDeleteInput itemDeleteInput) returns ItemDescription|error {
        string target = VERSION + DOT + "DeleteItem";
        json payload = check itemDeleteInput.cloneWithType(json);
        map<string> signedRequestHeaders = check getSignedRequestHeaders(self.awsHost, self.accessKeyId,
                                                                        self.secretAccessKey, self.region,
                                                                        POST, self.uri, target, payload);
        ItemDescription response = check self.awsDynamoDb->post(self.uri, payload, signedRequestHeaders);
        return response;
    }

    # Updates an item
    #
    # + itemUpdateInput - The request payload to update an item
    # + return - If success, dynamodb:ItemDescription record, else an error
    remote isolated function updateItem(ItemUpdateInput itemUpdateInput) returns ItemDescription|error {
        string target = VERSION + DOT + "UpdateItem";
        json payload = check itemUpdateInput.cloneWithType(json);
        map<string> signedRequestHeaders = check getSignedRequestHeaders(self.awsHost, self.accessKeyId,
                                                                        self.secretAccessKey, self.region,
                                                                        POST, self.uri, target, payload);
        json response = check self.awsDynamoDb->post(self.uri, payload, signedRequestHeaders);
        return response.cloneWithType(ItemDescription);
    }

    # Returns all items with a particular partition key value. You must provide the name of the partition key attribute
    # and a single value for that attribute. Optionally, you can provide a sort key attribute and use a comparison
    # operator to reﬁne the search results.
    #
    # + queryInput - The request payload to query
    # + return - If success, stream<dynamodb:QueryOutput,error?>, else an error
    remote isolated function query(QueryInput queryInput) returns stream<QueryOutput, error?>|error {

        QueryStream queryStream = check new QueryStream(self.awsDynamoDb, self.awsHost, self.accessKeyId,
            self.secretAccessKey, self.region, queryInput
        );
        return new stream<QueryOutput, error?>(queryStream);
    }

    # Returns one or more items and item attributes by accessing every item in a table or a secondary index.
    #
    # + scanInput - The request payload to scan
    # + return - If success, stream<dynamodb:ScanOutput,error?>, else an error
    remote isolated function scan(ScanInput scanInput) returns stream<ScanOutput, error?>|error {

        ScanStream scanStream = check new ScanStream(self.awsDynamoDb, self.awsHost, self.accessKeyId,
            self.secretAccessKey, self.region, scanInput
        );
        return new stream<ScanOutput, error?>(scanStream);
    }

    # Returns the attributes of one or more items from one or more tables. You identify requested items by primary key.
    #
    # + batchItemGetInput - The request payload to get items as batch
    # + return - If success, stream<dynamodb:BatchItem, error?>, else an error
    remote isolated function getBatchItems(BatchItemGetInput batchItemGetInput) returns stream<BatchItem, error?>|error {
        ItemsBatchGetStream itemsBatchGetStream = check new ItemsBatchGetStream(self.awsDynamoDb, self.awsHost,
            self.accessKeyId, self.secretAccessKey,
            self.region, batchItemGetInput
        );
        return new stream<BatchItem, error?>(itemsBatchGetStream);
    }

    # Puts or deletes multiple items in one or more tables.
    #
    # + batchItemInsertInput - The request payload to write items as batch
    # + return - If success, dynamodb:BatchItemInsertOutput record, else an error
    remote isolated function writeBatchItems(BatchItemInsertInput batchItemInsertInput) returns BatchItemInsertOutput|error {
        string target = VERSION + DOT + "BatchWriteItem";
        json payload = check batchItemInsertInput.cloneWithType(json);
        map<string> signedRequestHeaders = check getSignedRequestHeaders(self.awsHost, self.accessKeyId,
                                                                        self.secretAccessKey, self.region,
                                                                        POST, self.uri, target, payload);
        json response = check self.awsDynamoDb->post(self.uri, payload, signedRequestHeaders);
        return response.cloneWithType(BatchItemInsertOutput);
    }

    # Returns the current provisioned-capacity quotas for your AWS account in a Region, both for the Region as a whole
    # and for any one DynamoDB table that you create there.
    #
    # + return - If success, dynamodb:LimitDescription record, else an error
    remote isolated function describeLimits() returns LimitDescription|error {
        string target = VERSION + DOT + "DescribeLimits";
        json payload = {};
        map<string> signedRequestHeaders = check getSignedRequestHeaders(self.awsHost, self.accessKeyId,
                                                                        self.secretAccessKey, self.region,
                                                                        POST, self.uri, target, payload);
        json response = check self.awsDynamoDb->post(self.uri, payload, signedRequestHeaders);
        return response.cloneWithType(LimitDescription);
    }

    # Creates a back up from the given table
    #
    # + backupCreateInput - The request payload to backup the table
    # + return - If success, dynamodb:BackupDetails record, else an error
    remote isolated function createBackup(BackupCreateInput backupCreateInput) returns BackupDetails|error {
        string target = VERSION + DOT + "CreateBackup";
        json payload = check backupCreateInput.cloneWithType(json);
        map<string> signedRequestHeaders = check getSignedRequestHeaders(self.awsHost, self.accessKeyId,
                                                                        self.secretAccessKey, self.region,
                                                                        POST, self.uri, target, payload);
        json response = check self.awsDynamoDb->post(self.uri, payload, signedRequestHeaders);
        json backUpDetails = check response.BackupDetails;
        return backUpDetails.cloneWithType(BackupDetails);
    }

    # Deletes an existing backup of a table.
    #
    # + backupArn - The backupArn of the table that needs to be deleted
    # + return - If success, dynamodb:BackupDescription record, else an error
    remote isolated function deleteBackup(string backupArn) returns BackupDescription|error {
        string target = VERSION + DOT + "DeleteBackup";
        json payload = {
            "BackupArn": backupArn
        };
        map<string> signedRequestHeaders = check getSignedRequestHeaders(self.awsHost, self.accessKeyId,
                                                                        self.secretAccessKey, self.region,
                                                                        POST, self.uri, target, payload);
        json response = check self.awsDynamoDb->post(self.uri, payload, signedRequestHeaders);
        json backUpDetails = check response.BackupDescription;
        return backUpDetails.cloneWithType(BackupDescription);
    }

    # The description of the Time to Live (TTL) status on the specified table.
    #
    # + tableName - Table name 
    # + return - If success, dynamodb:TTLDescription record, else an error
    remote isolated function getTTL(string tableName) returns TTLDescription|error {
        string target = VERSION + DOT + "DescribeTimeToLive";
        json payload = {
            "TableName": tableName
        };
        map<string> signedRequestHeaders = check getSignedRequestHeaders(self.awsHost, self.accessKeyId,
                                                                    self.secretAccessKey, self.region,
                                                                    POST, self.uri, target, payload);
        json timeToLiveResponse = check self.awsDynamoDb->post(self.uri, payload, signedRequestHeaders);
        json timeToLiveDescription = check timeToLiveResponse.TimeToLiveDescription;
        return timeToLiveDescription.cloneWithType(TTLDescription);
    }
}
