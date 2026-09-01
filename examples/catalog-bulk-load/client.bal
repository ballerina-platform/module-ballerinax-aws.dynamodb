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

import ballerina/io;
import ballerinax/aws;
import ballerinax/aws.auth;
import ballerinax/aws.dynamodb;

configurable string region = ?;
configurable string tableName = ?;

// `BatchWriteItem` accepts at most 25 requests per call.
const int BATCH_SIZE = 25;

type Product record {|
    string sku;
    string name;
    string category;
    string price;
|};

public function main() returns error? {
    // `DEFAULT_CREDENTIALS` resolves credentials from the environment, so this runs unchanged on a
    // workstation, on EC2, on ECS, and on EKS.
    dynamodb:Client dynamoDb = check new ({
        auth: auth:DEFAULT_CREDENTIALS,
        region: region is "" ? aws:US_EAST_1 : region
    });

    Product[] catalog = loadCatalog();
    io:println(string `Loading ${catalog.length()} products into '${tableName}'`);

    // DynamoDB caps a batch write at 25 items and can decline part of a batch under load, so the writes are
    // chunked and whatever comes back as unprocessed is retried.
    int written = 0;
    foreach int offset in int:range(0, catalog.length(), BATCH_SIZE) {
        int end = int:min(offset + BATCH_SIZE, catalog.length());
        dynamodb:WriteRequest[] requests = from Product product in catalog.slice(offset, end)
            select {PutRequest: {Item: toItem(product)}};

        map<dynamodb:WriteRequest[]> pending = {[tableName]: requests};
        // `UnprocessedItems` has the same shape as `RequestItems`, so it can be fed straight back in.
        while pending.length() > 0 {
            dynamodb:BatchItemInsertOutput result = check dynamoDb->writeBatchItems({RequestItems: pending});
            pending = result?.UnprocessedItems ?: {};
            if pending.length() > 0 {
                io:println(string `  retrying ${pending.get(tableName).length()} unprocessed write(s)`);
            }
        }
        written += end - offset;
    }
    io:println(string `Wrote ${written} products`);

    // Read a handful back by primary key. `getBatchItems` re-requests any keys DynamoDB leaves unprocessed as
    // the stream is consumed, so the caller does not have to drive that loop.
    string[] wanted = ["SKU-0001", "SKU-0004", "SKU-0007"];
    dynamodb:KeysAndAttributes keys = {
        Keys: from string sku in wanted
            select {"Sku": {S: sku}}
    };
    io:println("Reading three products back by key:");
    stream<dynamodb:BatchItem, dynamodb:Error?> batch = check dynamoDb->getBatchItems({
        RequestItems: {[tableName]: keys}
    });
    check from dynamodb:BatchItem result in batch
        do {
            map<dynamodb:AttributeValue> item = check result?.Item.ensureType();
            io:println(string `  ${item["Sku"]?.S ?: "?"}  ${item["Name"]?.S ?: "?"}`);
        };

    // Scan the whole table, filtering server side. The stream pages through the table on its own; a page can
    // come back empty when the filter eliminates everything it examined, without meaning the scan is over.
    io:println("Scanning for the accessories:");
    int accessories = 0;
    stream<dynamodb:ScanOutput, dynamodb:Error?> scanned = check dynamoDb->scan({
        TableName: tableName,
        FilterExpression: "Category = :category",
        ExpressionAttributeValues: {":category": {S: "accessories"}}
    });
    check from dynamodb:ScanOutput result in scanned
        do {
            map<dynamodb:AttributeValue> item = check result?.Item.ensureType();
            io:println(string `  ${item["Sku"]?.S ?: "?"}  ${item["Name"]?.S ?: "?"}`);
            accessories += 1;
        };
    io:println(string `Found ${accessories} accessor${accessories == 1 ? "y" : "ies"}`);

    check dynamoDb.close();
}

isolated function toItem(Product product) returns map<dynamodb:AttributeValue> => {
    "Sku": {S: product.sku},
    "Name": {S: product.name},
    "Category": {S: product.category},
    // Numbers travel as strings so that arbitrary precision survives the round trip.
    "Price": {N: product.price}
};

isolated function loadCatalog() returns Product[] => [
    {sku: "SKU-0001", name: "Mechanical keyboard", category: "peripherals", price: "129.00"},
    {sku: "SKU-0002", name: "Laptop stand", category: "accessories", price: "45.50"},
    {sku: "SKU-0003", name: "27-inch monitor", category: "displays", price: "349.99"},
    {sku: "SKU-0004", name: "USB-C hub", category: "accessories", price: "62.00"},
    {sku: "SKU-0005", name: "Wireless mouse", category: "peripherals", price: "39.95"},
    {sku: "SKU-0006", name: "Desk mat", category: "accessories", price: "24.00"},
    {sku: "SKU-0007", name: "Webcam", category: "peripherals", price: "89.00"},
    {sku: "SKU-0008", name: "Cable organiser", category: "accessories", price: "12.75"}
];
