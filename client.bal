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
        self.awsDynamoDb = check new(endpoint, httpClientConfig);
    }

    # Create a table. The CreateTable operation adds a new table to your account. In an AWS account, table names must be
    # unique within each Region. That is, you can have two tables with same name if you create the tables in diﬀerent
    # Regions.
    #
    # + tableCreationRequest - The request payload to create a table
    # + return - If success, dynamodb:TableCreateResponse record, else an error
    remote isolated function createTable(TableCreateRequest tableCreationRequest) returns TableCreateResponse|error {
        string target = VERSION + DOT + "CreateTable";
        json payload = check tableCreationRequest.cloneWithType(json);
        map<string> signedRequestHeaders = check getSignedRequestHeaders(self.awsHost, self.accessKeyId,
                                                                         self.secretAccessKey, self.region,
                                                                         POST, self.uri, target, payload);

        TableCreateResponse response = check self.awsDynamoDb->post(self.uri, payload, signedRequestHeaders);                                                     
        return response;
    }

    # Delete a table.
    #
    # + tableName - The name of the table to delete
    # + return - If success, dynamodb:TableDeleteResponse record, else an error
    remote isolated function deleteTable(string tableName) returns TableDeleteResponse|error {
        string target = VERSION + DOT + "DeleteTable";
        json payload = {
           "TableName": tableName 
        };

        map<string> signedRequestHeaders = check getSignedRequestHeaders(self.awsHost, self.accessKeyId,
                                                                         self.secretAccessKey, self.region,
                                                                         POST, self.uri, target, payload);
        TableDeleteResponse response = check self.awsDynamoDb->post(self.uri, payload, signedRequestHeaders);
        return response;
    }

    # Describe a table.
    #
    # + tableName - The name of the table to delete
    # + return - If success, dynamodb:TableDescribeResponse record, else an error
    remote isolated function describeTable(string tableName) returns TableDescribeResponse|error {
        string target = VERSION + DOT + "DescribeTable";
        json payload = {
            "TableName": tableName
        };

        map<string> signedRequestHeaders = check getSignedRequestHeaders(self.awsHost, self.accessKeyId,
                                                                         self.secretAccessKey, self.region,
                                                                         POST, self.uri, target, payload);
        TableDescribeResponse response = check self.awsDynamoDb->post(self.uri, payload, signedRequestHeaders);
        return response;
    }
    
    # List all tables.
    #
    # + return - If success, stream<string, error?>, else an error
    remote isolated function listTables () returns stream<string, error?>|error {
        TableStream tableStream = check new TableStream(self.awsDynamoDb, self.awsHost, self.accessKeyId,
                                                        self.secretAccessKey, self.region);
        return new stream<string,error?>(tableStream);
    }

    # Update a table.
    #
    # + tableUpdateRequest - The request payload to update a table 
    # + return - If success, dynamodb:TableUpdateResponse record, else an error
    remote isolated function updateTable(TableUpdateRequest tableUpdateRequest) returns TableUpdateResponse|error {
        string target = VERSION + DOT + "UpdateTable";
        json payload = check tableUpdateRequest.cloneWithType(json);
        map<string> signedRequestHeaders = check getSignedRequestHeaders(self.awsHost, self.accessKeyId,
                                                                         self.secretAccessKey, self.region,
                                                                         POST, self.uri, target, payload);
        TableUpdateResponse response = check self.awsDynamoDb->post(self.uri, payload, signedRequestHeaders);
        return response;
    }

    # Creates a new item, or replaces an old item with a new item. If an item that has the same primary key as the new
    # item already exists in the speciﬁed table, the new item completely replaces the existing item. You can perform a
    # conditional put operation (add a new item if one with the speciﬁed primary key doesn't exist), or replace an
    # existing item if it has certain attribute values.
    #
    # + request - The request payload to create an item
    # + return - If success, dynamodb:ItemDescription record, else an error
    remote isolated function putItem(ItemCreateRequest request) returns ItemDescription|error {
        string target = VERSION + DOT + "PutItem";
        json payload = check request.cloneWithType(json);
        map<string> signedRequestHeaders = check getSignedRequestHeaders(self.awsHost, self.accessKeyId,
                                                                         self.secretAccessKey, self.region,
                                                                         POST, self.uri, target, payload);
        ItemDescription response = check self.awsDynamoDb->post(self.uri, payload, signedRequestHeaders);
        return response;                                                                 
    }

    # Get an item.
    #
    # + request -The request payload to get an item
    # + return - If success, dynamodb:ItemGetResponse record, else an error
    remote isolated function getItem(ItemGetRequest request) returns ItemGetResponse|error {
        string target = VERSION + DOT + "GetItem";
        json payload = check request.cloneWithType(json);
        map<string> signedRequestHeaders = check getSignedRequestHeaders(self.awsHost, self.accessKeyId,
                                                                         self.secretAccessKey, self.region,
                                                                         POST, self.uri, target, payload);
        ItemGetResponse response = check self.awsDynamoDb->post(self.uri, payload, signedRequestHeaders);
        return response;                                                                 
    }

    # Delete an item.
    #
    # + request - The request payload to delete an item
    # + return - If success, dynamodb:ItemDescription record, else an error
    remote isolated function deleteItem(ItemDeleteRequest request) returns ItemDescription|error {
        string target = VERSION + DOT + "DeleteItem";
        json payload = check request.cloneWithType(json);
        map<string> signedRequestHeaders = check getSignedRequestHeaders(self.awsHost, self.accessKeyId,
                                                                         self.secretAccessKey, self.region,
                                                                         POST, self.uri, target, payload);
        ItemDescription response = check self.awsDynamoDb->post(self.uri, payload, signedRequestHeaders);
        return response;                                                                 
    }

    # Update an item
    #
    # + request - The request payload to update an item
    # + return - If success, dynamodb:ItemDescription record, else an error
    remote isolated function updateItem(ItemUpdateRequest request) returns ItemDescription|error {
        string target = VERSION + DOT + "UpdateItem";
        json payload = check request.cloneWithType(json);
        map<string> signedRequestHeaders = check getSignedRequestHeaders(self.awsHost, self.accessKeyId,
                                                                         self.secretAccessKey, self.region,
                                                                         POST, self.uri, target, payload);
        ItemDescription response = check self.awsDynamoDb->post(self.uri, payload, signedRequestHeaders);
        return response;
    }

    # Returns all items with a particular partition key value. You must provide the name of the partition key attribute
    # and a single value for that attribute. Optionally, you can provide a sort key attribute and use a comparison
    # operator to reﬁne the search results.
    #
    # + request - The request payload to query
    # + return - If success, stream<dynamodb:QueryResponse,error?>, else an error
    remote isolated function query(QueryRequest request) returns stream<QueryResponse,error?>|error {

        QueryStream queryStream = check new QueryStream(self.awsDynamoDb, self.awsHost, self.accessKeyId,
                                                        self.secretAccessKey, self.region, request);
        return new stream<QueryResponse,error?>(queryStream);   
    }

    # Returns one or more items and item attributes by accessing every item in a table or a secondary index.
    #
    # + request - The request payload to scan
    # + return - If success, stream<dynamodb:ScanResponse,error?>, else an error
    remote isolated function scan(ScanRequest request) returns stream<ScanResponse,error?>|error {

        ScanStream scanStream = check new ScanStream(self.awsDynamoDb, self.awsHost, self.accessKeyId,
                                                        self.secretAccessKey, self.region, request);
        return new stream<ScanResponse,error?>(scanStream);               
    }

    # Returns the attributes of one or more items from one or more tables. You identify requested items by primary key.
    #
    # + request - The request payload to get items as batch
    # + return - If success, stream<dynamodb:ItemByBatchGet, error?>, else an error
    remote isolated function getBatchItems(ItemsBatchGetRequest request) returns stream<ItemByBatchGet, error?> |error {

        ItemsBatchGetStream itemsBatchGetStream = check new ItemsBatchGetStream(self.awsDynamoDb, self.awsHost,
                                                                                self.accessKeyId,self.secretAccessKey,
                                                                                self.region, request);
        return new stream<ItemByBatchGet,error?>(itemsBatchGetStream);
    }

    # Puts or deletes multiple items in one or more tables.
    #
    # + request - The request payload to write items as batch
    # + return - If success, dynamodb:ItemsBatchWriteResponse record, else an error
    remote isolated function writeBatchItems(ItemsBatchWriteRequest request) returns ItemsBatchWriteResponse|error {
        string target = VERSION + DOT + "BatchWriteItem";
        json payload = check request.cloneWithType(json);
        map<string> signedRequestHeaders = check getSignedRequestHeaders(self.awsHost, self.accessKeyId,
                                                                         self.secretAccessKey, self.region,
                                                                         POST, self.uri, target, payload);
        ItemsBatchWriteResponse response = check self.awsDynamoDb->post(self.uri, payload, signedRequestHeaders);
        return response;
    }

    # Returns the current provisioned-capacity quotas for your AWS account in a Region, both for the Region as a whole
    # and for any one DynamoDB table that you create there.
    # + return - If success, dynamodb:LimitDescribtion record, else an error
    remote isolated function describeLimits() returns LimitDescribtion|error {
        string target = VERSION + DOT +"DescribeLimits";
        json payload = {};
        map<string> signedRequestHeaders = check getSignedRequestHeaders(self.awsHost, self.accessKeyId,
                                                                         self.secretAccessKey, self.region,
                                                                         POST, self.uri, target, payload);
        LimitDescribtion response = check self.awsDynamoDb->post(self.uri, payload, signedRequestHeaders);
        return response;
    }

}
