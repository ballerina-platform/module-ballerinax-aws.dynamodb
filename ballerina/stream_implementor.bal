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

    public isolated function next() returns record {|string value;|}|error? {
        if self.index < self.currentEntries.length() {
            record {|string value;|} tableName = {value: self.currentEntries[self.index]};
            self.index += 1;
            return tableName;
        }
        if self.exclusiveStartTableName is string {
            self.index = 0;
            self.currentEntries = check self.fetchTableNames();
            record {|string value;|} tableName = {value: self.currentEntries[self.index]};
            self.index += 1;
            return tableName;
        }
    }

    isolated function fetchTableNames() returns string[]|error {
        string target = VERSION + DOT + "ListTables";
        TableListRequest request = {
            exclusiveStartTableName: self.exclusiveStartTableName
        };
        json payload = check request.cloneWithType(json);
        convertJsonKeysToUpperCase(payload);
        map<string> signedRequestHeaders = check getSignedRequestHeaders(self.awsHost, self.accessKeyId,
                                                                        self.secretAccessKey, self.region,
                                                                        POST, self.uri, target, payload);
        json response = check self.httpClient->post(self.uri, payload, signedRequestHeaders);
        convertJsonKeysToCamelCase(response);
        TableList tableListResp = check response.cloneWithType(TableList);
        self.exclusiveStartTableName = tableListResp?.lastEvaluatedTableName;
        string[]? tableList = tableListResp?.tableNames;
        if tableList is string[] {
            return tableList;
        }
        return [];
    }
}

class ScanStream {
    private ScanOutput[] currentEntries = [];
    private int index = 0;
    private final http:Client httpClient;
    private final string accessKeyId;
    private final string secretAccessKey;
    private final string region;
    private final string awsHost;
    private final string uri = SLASH;
    private ScanInput scanRequest;

    isolated function init(http:Client httpClient, string host, string accessKey, string secretKey, string region,
            ScanInput scanRequest) returns error? {
        self.httpClient = httpClient;
        self.accessKeyId = accessKey;
        self.secretAccessKey = secretKey;
        self.region = region;
        self.awsHost = AWS_SERVICE + DOT + self.region + DOT + AWS_HOST;
        self.scanRequest = scanRequest;
        self.currentEntries = check self.fetchScan();
    }

    public isolated function next() returns record {|ScanOutput value;|}|error? {
        if self.index < self.currentEntries.length() {
            record {|ScanOutput value;|} response = {value: self.currentEntries[self.index]};
            self.index += 1;
            return response;
        }
        if self.scanRequest?.exclusiveStartKey is map<AttributeValue> {
            self.index = 0;
            self.currentEntries = check self.fetchScan();
            if self.index < self.currentEntries.length() {
                record {|ScanOutput value;|} response = {value: self.currentEntries[self.index]};
                self.index += 1;
                return response;
            }
        }
    }

    isolated function fetchScan() returns ScanOutput[]|error {
        string target = VERSION + DOT + "Scan";
        json payload = check self.scanRequest.cloneWithType(json);
        convertJsonKeysToUpperCase(payload);
        map<string> signedRequestHeaders = check getSignedRequestHeaders(self.awsHost, self.accessKeyId,
                                                                        self.secretAccessKey, self.region,
                                                                        POST, self.uri, target, payload);
        json jsonResponse = check self.httpClient->post(self.uri, payload, signedRequestHeaders);
        convertJsonKeysToCamelCase(jsonResponse);
        QueryOrScanOutput response = check jsonResponse.cloneWithType(QueryOrScanOutput);
        self.scanRequest.exclusiveStartKey = response?.lastEvaluatedKey;
        map<AttributeValue>[]?? items = response?.items;
        if items is map<AttributeValue>[] {
            ScanOutput[] scanResponseArr = [];
            foreach map<AttributeValue> item in items {
                ScanOutput scanResponse = {
                    consumedCapacity: response?.consumedCapacity,
                    item: item
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
    private QueryOutput[] currentEntries = [];
    private int index = 0;
    private final http:Client httpClient;
    private final string accessKeyId;
    private final string secretAccessKey;
    private final string region;
    private final string awsHost;
    private final string uri = SLASH;
    private QueryInput queryRequest;

    isolated function init(http:Client httpClient, string host, string accessKey, string secretKey, string region,
            QueryInput queryRequest) returns error? {
        self.httpClient = httpClient;
        self.accessKeyId = accessKey;
        self.secretAccessKey = secretKey;
        self.region = region;
        self.awsHost = AWS_SERVICE + DOT + self.region + DOT + AWS_HOST;
        self.queryRequest = queryRequest;
        self.currentEntries = check self.fetchQuery();
    }

    public isolated function next() returns record {|QueryOutput value;|}|error? {
        if self.index < self.currentEntries.length() {
            record {|QueryOutput value;|} response = {value: self.currentEntries[self.index]};
            self.index += 1;
            return response;
        }
        if self.queryRequest?.exclusiveStartKey is map<AttributeValue> {
            self.index = 0;
            self.currentEntries = check self.fetchQuery();
            if self.index < self.currentEntries.length() {
                record {|QueryOutput value;|} response = {value: self.currentEntries[self.index]};
                self.index += 1;
                return response;
            }
        }
    }

    isolated function fetchQuery() returns QueryOutput[]|error {
        string target = VERSION + DOT + "Query";
        json payload = check self.queryRequest.cloneWithType(json);
        convertJsonKeysToUpperCase(payload);
        map<string> signedRequestHeaders = check getSignedRequestHeaders(self.awsHost, self.accessKeyId,
                                                                        self.secretAccessKey, self.region,
                                                                        POST, self.uri, target, payload);
        json jsonResponse = check self.httpClient->post(self.uri, payload, signedRequestHeaders);
        convertJsonKeysToCamelCase(jsonResponse);
        QueryOrScanOutput response = check jsonResponse.cloneWithType(QueryOrScanOutput);
        self.queryRequest.exclusiveStartKey = response?.lastEvaluatedKey;
        map<AttributeValue>[]? items = response?.items;
        if items is map<AttributeValue>[] {
            QueryOutput[] queryResponseArr = [];
            foreach map<AttributeValue> item in items {
                QueryOutput queryResponse = {
                    consumedCapacity: response?.consumedCapacity,
                    item: item
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
    private BatchItem[] currentEntries = [];
    private int index = 0;
    private final http:Client httpClient;
    private final string accessKeyId;
    private final string secretAccessKey;
    private final string region;
    private final string awsHost;
    private final string uri = SLASH;
    private BatchItemGetInput itemsBatchGetRequest;

    isolated function init(http:Client httpClient, string host, string accessKey, string secretKey, string region,
            BatchItemGetInput itemsBatchGetRequest) returns error? {
        self.httpClient = httpClient;
        self.accessKeyId = accessKey;
        self.secretAccessKey = secretKey;
        self.region = region;
        self.awsHost = AWS_SERVICE + DOT + self.region + DOT + AWS_HOST;
        self.itemsBatchGetRequest = itemsBatchGetRequest;
        self.currentEntries = check self.fetchBatchItems();
    }

    public isolated function next() returns record {|BatchItem value;|}|error? {
        if self.index < self.currentEntries.length() {
            record {|BatchItem value;|} response = {value: self.currentEntries[self.index]};
            self.index += 1;
            return response;
        }
        if self.itemsBatchGetRequest.requestItems.keys().length() != 0 {
            self.index = 0;
            self.currentEntries = check self.fetchBatchItems();
            if self.index < self.currentEntries.length() {
                record {|BatchItem value;|} response = {value: self.currentEntries[self.index]};
                self.index += 1;
                return response;
            }
        }
    }

    isolated function fetchBatchItems() returns BatchItem[]|error {
        string target = VERSION + DOT + "BatchGetItem";
        json payload = check self.itemsBatchGetRequest.cloneWithType(json);
        convertJsonKeysToUpperCase(payload);
        map<string> signedRequestHeaders = check getSignedRequestHeaders(self.awsHost, self.accessKeyId,
                                                                        self.secretAccessKey, self.region,
                                                                        POST, self.uri, target, payload);
        json jsonResponse = check self.httpClient->post(self.uri, payload, signedRequestHeaders);
        convertJsonKeysToCamelCase(jsonResponse);
        BatchGetItemsOutput response = check jsonResponse.cloneWithType(BatchGetItemsOutput);

        self.itemsBatchGetRequest.requestItems = self.getRequestItemsToNextBatch(response);
        map<map<AttributeValue>[]>?? batchResponses = response?.responses;
        ConsumedCapacity[]?? consumedCapacities = response?.consumedCapacity;
        map<ConsumedCapacity> consumedCapacityMap = {};
        if consumedCapacities is ConsumedCapacity[] {
            foreach ConsumedCapacity consumedCapacity in consumedCapacities {
                consumedCapacityMap[consumedCapacity?.tableName.toString()] = consumedCapacity;
            }
        }
        if batchResponses is map<map<AttributeValue>[]> {
            BatchItem[] itemResponseArr = [];
            string[] keys = batchResponses.keys();
            foreach string keyName in keys {
                map<AttributeValue>[] items = batchResponses.get(keyName);
                ConsumedCapacity? consumedCapacity = consumedCapacityMap.hasKey(keyName) ?
                    consumedCapacityMap.get(keyName) : ();
                foreach map<AttributeValue> item in items {
                    BatchItem itemResponse = {
                        consumedCapacity: consumedCapacity,
                        tableName: keyName,
                        item: item
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
    private isolated function getRequestItemsToNextBatch(BatchGetItemsOutput itemsBatchGetResponse)
                                                        returns map<KeysAndAttributes> {
        map<KeysAndAttributes>?? unprocessedKeys = itemsBatchGetResponse?.unprocessedKeys;
        return (unprocessedKeys is map<KeysAndAttributes> && unprocessedKeys !== {}) ?
            <map<KeysAndAttributes>>unprocessedKeys : {};
    }
}
