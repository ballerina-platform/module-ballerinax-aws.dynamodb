// Copyright (c) 2021 WSO2 Inc. (http://www.wso2.org) All Rights Reserved.
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

class TableStream {
    private string[] currentEntries = [];
    private int index = 0;
    private final http:Client httpClient;
    private final string accessKeyId;
    private final string secretAccessKey;
    // private final string? securityToken;
    private final string region;
    private final string awsHost;
    private final string uri = SLASH;
    private string? exclusiveStartTableName;


    isolated function init(http:Client httpClient, string host, string accessKey, string secretKey, string region)
                           returns error? {
        self.httpClient = httpClient;
        self.accessKeyId = accessKey;
        self.secretAccessKey = secretKey;
        self.region = region;
        self.awsHost = AWS_SERVICE + DOT + self.region + DOT + AWS_HOST;
        self.exclusiveStartTableName = null;
        self.currentEntries = check self.fetchTableNames();
    }

    public isolated function next() returns record {| string value; |}|error? {
        if (self.index < self.currentEntries.length()) {
            record {| string value; |} tableName = {value: self.currentEntries[self.index]};
            self.index += 1;
            return tableName;
        }
        if (self.exclusiveStartTableName is string) {
            self.index = 0;
            self.currentEntries = check self.fetchTableNames();
            record {| string value; |} tableName = {value: self.currentEntries[self.index]};
            self.index += 1;
            return tableName;
        }
    }

    isolated function fetchTableNames() returns string[]|error {
        string target = VERSION + DOT + "ListTables";
        TableListRequest request = {
            ExclusiveStartTableName: self.exclusiveStartTableName
        };
        json payload = check request.cloneWithType(json);
        map<string> signedRequestHeaders = check getSignedRequestHeaders(self.awsHost, self.accessKeyId,
                                                                         self.secretAccessKey, self.region,
                                                                         POST, self.uri, target, payload);
        TableList response = check self.httpClient->post(self.uri,payload, signedRequestHeaders);
        self.exclusiveStartTableName = response?.LastEvaluatedTableName;
        string[]? tableList = response?.TableNames;
        if tableList is string[] {
            return tableList;
        }
        return [];
    }
}

class ScanStream {
    private ScanResponse[] currentEntries = [];
    private int index = 0;
    private final http:Client httpClient;
    private final string accessKeyId;
    private final string secretAccessKey;
    // private final string? securityToken;
    private final string region;
    private final string awsHost;
    private final string uri = SLASH;
    private ScanRequest scanRequest;


    isolated function init(http:Client httpClient, string host, string accessKey, string secretKey, string region,
                           ScanRequest scanRequest) returns error? {
        self.httpClient = httpClient;
        self.accessKeyId = accessKey;
        self.secretAccessKey = secretKey;
        self.region = region;
        self.awsHost = AWS_SERVICE + DOT + self.region + DOT + AWS_HOST;
        self.scanRequest = scanRequest;
        self.currentEntries = check self.fetchScan();
    }

    public isolated function next() returns record {| ScanResponse value; |}|error? {
        if (self.index < self.currentEntries.length()) {
            record {| ScanResponse value; |} response = {value: self.currentEntries[self.index]};
            self.index += 1;
            return response;
        }
        if (self.scanRequest?.ExclusiveStartKey is map<AttributeValue>) {
            self.index = 0;
            self.currentEntries = check self.fetchScan();
            if (self.index < self.currentEntries.length()) {
                record {| ScanResponse value; |} response = {value: self.currentEntries[self.index]};
                self.index += 1;
                return response;
            }
        }
    }

    isolated function fetchScan() returns ScanResponse[]|error {
        string target = VERSION + DOT + "Scan";
        json payload = check self.scanRequest.cloneWithType(json);
        map<string> signedRequestHeaders = check getSignedRequestHeaders(self.awsHost, self.accessKeyId,
                                                                         self.secretAccessKey, self.region,
                                                                         POST, self.uri, target, payload);
        QueryOrScanResponse response = check self.httpClient->post(self.uri,payload, signedRequestHeaders);
        self.scanRequest.ExclusiveStartKey = response?.LastEvaluatedKey;
        map<AttributeValue>[]?? items = response?.Items;
        if items is map<AttributeValue>[] {
            ScanResponse[] scanResponseArr = [];
            foreach map<AttributeValue> item in items {
                ScanResponse scanResponse = {
                    ConsumedCapacity: response?.ConsumedCapacity,
                    Item: item
                };
                scanResponseArr.push(scanResponse);
            }
            return scanResponseArr;
        } else {
            return [];
        }
    }
}

class QueryStream {
    private QueryResponse[] currentEntries = [];
    private int index = 0;
    private final http:Client httpClient;
    private final string accessKeyId;
    private final string secretAccessKey;
    // private final string? securityToken;
    private final string region;
    private final string awsHost;
    private final string uri = SLASH;
    private QueryRequest queryRequest;


    isolated function init(http:Client httpClient, string host, string accessKey, string secretKey, string region,
                           QueryRequest queryRequest) returns error? {
        self.httpClient = httpClient;
        self.accessKeyId = accessKey;
        self.secretAccessKey = secretKey;
        self.region = region;
        self.awsHost = AWS_SERVICE + DOT + self.region + DOT + AWS_HOST;
        self.queryRequest = queryRequest;
        self.currentEntries = check self.fetchQuery();
    }

    public isolated function next() returns record {| QueryResponse value; |}|error? {
        if (self.index < self.currentEntries.length()) {
            record {| QueryResponse value; |} response = {value: self.currentEntries[self.index]};
            self.index += 1;
            return response;
        }
        if (self.queryRequest?.ExclusiveStartKey is map<AttributeValue>) {
            self.index = 0;
            self.currentEntries = check self.fetchQuery();
            if (self.index < self.currentEntries.length()) {
                record {| QueryResponse value; |} response = {value: self.currentEntries[self.index]};
                self.index += 1;
                return response;
            }
        }
    }

    isolated function fetchQuery() returns QueryResponse[]|error {
        string target = VERSION + DOT + "Query";
        json payload = check self.queryRequest.cloneWithType(json);
        map<string> signedRequestHeaders = check getSignedRequestHeaders(self.awsHost, self.accessKeyId,
                                                                         self.secretAccessKey, self.region,
                                                                         POST, self.uri, target, payload);
        QueryOrScanResponse response = check self.httpClient->post(self.uri,payload, signedRequestHeaders);
        self.queryRequest.ExclusiveStartKey = response?.LastEvaluatedKey;
        map<AttributeValue>[]?? items = response?.Items;
        if items is map<AttributeValue>[] {
            QueryResponse[] queryResponseArr = [];
            foreach map<AttributeValue> item in items {
                QueryResponse queryResponse = {
                    ConsumedCapacity: response?.ConsumedCapacity,
                    Item: item
                };
                queryResponseArr.push(queryResponse);
            }
            return queryResponseArr;
        } else {
            return [];
        }
    }
}

class ItemsBatchGetStream {
    private ItemByBatchGet[] currentEntries = [];
    private int index = 0;
    private final http:Client httpClient;
    private final string accessKeyId;
    private final string secretAccessKey;
    // private final string? securityToken;
    private final string region;
    private final string awsHost;
    private final string uri = SLASH;
    private ItemsBatchGetRequest itemsBatchGetRequest;


    isolated function init(http:Client httpClient, string host, string accessKey, string secretKey, string region,
                           ItemsBatchGetRequest itemsBatchGetRequest) returns error? {
        self.httpClient = httpClient;
        self.accessKeyId = accessKey;
        self.secretAccessKey = secretKey;
        self.region = region;
        self.awsHost = AWS_SERVICE + DOT + self.region + DOT + AWS_HOST;
        self.itemsBatchGetRequest = itemsBatchGetRequest;
        self.currentEntries = check self.fetchBatchItems();
    }

    public isolated function next() returns record {| ItemByBatchGet value; |}|error? {
        if (self.index < self.currentEntries.length()) {
            record {| ItemByBatchGet value; |} response = {value: self.currentEntries[self.index]};
            self.index += 1;
            return response;
        }
        if (self.itemsBatchGetRequest.RequestItems.keys().length()!=0) {
            self.index = 0;
            self.currentEntries = check self.fetchBatchItems();
            if (self.index < self.currentEntries.length()) {
                record {| ItemByBatchGet value; |} response = {value: self.currentEntries[self.index]};
                self.index += 1;
                return response;
            }
        }
    }

    isolated function fetchBatchItems() returns ItemByBatchGet[]|error {
        string target = VERSION + DOT + "BatchGetItem";
        json payload = check self.itemsBatchGetRequest.cloneWithType(json);
        map<string> signedRequestHeaders = check getSignedRequestHeaders(self.awsHost, self.accessKeyId,
                                                                         self.secretAccessKey, self.region,
                                                                         POST, self.uri, target, payload);
        ItemsBatchGetResponse response = check self.httpClient->post(self.uri,payload, signedRequestHeaders);

        self.itemsBatchGetRequest.RequestItems =  self.getRequestItemsToNextBatch(response);                                                  
        map<map<AttributeValue>[]>?? batchResponses = response?.Responses;
        ConsumedCapacity[]?? consumedCapacities = response?.ConsumedCapacity;
        map<ConsumedCapacity> consumedCapacityMap = {};
        if consumedCapacities is ConsumedCapacity[] {
            foreach ConsumedCapacity consumedCapacity in consumedCapacities {
                consumedCapacityMap[consumedCapacity?.TableName.toString()] = consumedCapacity;
            }
        }  
        if batchResponses is map<map<AttributeValue>[]> {
            ItemByBatchGet[] itemResponseArr = [];
            string[] keys = batchResponses.keys();
            foreach string keyName in keys {              
                map<AttributeValue>[] items = batchResponses.get(keyName);
                ConsumedCapacity? consumedCapacity = consumedCapacityMap.hasKey(keyName) ? 
                                                    consumedCapacityMap.get(keyName) : ();
                foreach map<AttributeValue> item in items {
                    ItemByBatchGet itemResponse = {
                        ConsumedCapacity: consumedCapacity,
                        TableName: keyName,
                        Item: item
                    };
                    itemResponseArr.push(itemResponse);
                }
            }
            return itemResponseArr;
        } else {
            return [];
        }
    }
    // Get RequestItem to construct request payload for the next batch
    private isolated function getRequestItemsToNextBatch(ItemsBatchGetResponse itemsBatchGetResponse ) 
                                                         returns map<KeysAndAttributes> {
        map<KeysAndAttributes>?? unprocessedKeys = itemsBatchGetResponse?.UnprocessedKeys;
        return (unprocessedKeys is map<KeysAndAttributes> && unprocessedKeys !== {}) ? 
                <map<KeysAndAttributes>> unprocessedKeys : {};
    }
}
