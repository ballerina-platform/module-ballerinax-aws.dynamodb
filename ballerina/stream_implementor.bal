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

# Fetches a single page of table names.
type ListTablesPageFetcher isolated function (string? exclusiveStartTableName) returns TableList|Error;

# Fetches a single page of scan results.
type ScanPageFetcher isolated function (ScanInput request) returns QueryOrScanOutput|Error;

# Fetches a single page of query results.
type QueryPageFetcher isolated function (QueryInput request) returns QueryOrScanOutput|Error;

# Fetches a single page of batch-get results.
type BatchGetPageFetcher isolated function (BatchItemGetInput request) returns BatchGetItemsOutput|Error;

# Iterates over every table name of the result set, fetching the next page only once the current one is exhausted.
class TableStream {
    private final ListTablesPageFetcher fetchPage;
    private string[] currentPage = [];
    private int index = 0;
    private string? nextStartTableName = ();
    private boolean exhausted = false;

    isolated function init(ListTablesPageFetcher fetchPage) returns Error? {
        self.fetchPage = fetchPage;
        check self.fetchNextPage();
    }

    public isolated function next() returns record {|string value;|}|Error? {
        // Keep fetching until a page yields a value or the result set is exhausted. A page can legitimately come
        // back empty while still carrying a continuation token, so the emptiness of one page must not be mistaken
        // for the end of the result set — nor may an empty page be indexed into.
        while self.index >= self.currentPage.length() {
            if self.exhausted {
                return;
            }
            check self.fetchNextPage();
        }
        record {|string value;|} next = {value: self.currentPage[self.index]};
        self.index += 1;
        return next;
    }

    private isolated function fetchNextPage() returns Error? {
        TableList page = check self.fetchPage(self.nextStartTableName);
        self.currentPage = page?.TableNames ?: [];
        self.index = 0;
        self.nextStartTableName = page?.LastEvaluatedTableName;
        // Absent `LastEvaluatedTableName` means this was the final page.
        self.exhausted = self.nextStartTableName !is string;
    }
}

# Iterates over every item matched by a scan, fetching the next page only once the current one is exhausted.
class ScanStream {
    private final ScanPageFetcher fetchPage;
    private final ScanInput request;
    private ScanOutput[] currentPage = [];
    private int index = 0;
    private map<AttributeValue>? nextStartKey = ();
    private boolean exhausted = false;

    isolated function init(ScanInput request, ScanPageFetcher fetchPage) returns Error? {
        self.request = request.clone();
        self.fetchPage = fetchPage;
        check self.fetchNextPage();
    }

    public isolated function next() returns record {|ScanOutput value;|}|Error? {
        while self.index >= self.currentPage.length() {
            if self.exhausted {
                return;
            }
            check self.fetchNextPage();
        }
        record {|ScanOutput value;|} next = {value: self.currentPage[self.index]};
        self.index += 1;
        return next;
    }

    private isolated function fetchNextPage() returns Error? {
        ScanInput request = self.request.clone();
        map<AttributeValue>? startKey = self.nextStartKey;
        if startKey is map<AttributeValue> {
            request.ExclusiveStartKey = startKey;
        }

        QueryOrScanOutput page = check self.fetchPage(request);
        ScanOutput[] items = [];
        foreach map<AttributeValue> item in page?.Items ?: [] {
            items.push({ConsumedCapacity: page?.ConsumedCapacity, Item: item});
        }
        self.currentPage = items;
        self.index = 0;
        self.nextStartKey = page?.LastEvaluatedKey;
        // Absent `LastEvaluatedKey` means this was the final page.
        self.exhausted = self.nextStartKey !is map<AttributeValue>;
    }
}

# Iterates over every item matched by a query, fetching the next page only once the current one is exhausted.
class QueryStream {
    private final QueryPageFetcher fetchPage;
    private final QueryInput request;
    private QueryOutput[] currentPage = [];
    private int index = 0;
    private map<AttributeValue>? nextStartKey = ();
    private boolean exhausted = false;

    isolated function init(QueryInput request, QueryPageFetcher fetchPage) returns Error? {
        self.request = request.clone();
        self.fetchPage = fetchPage;
        check self.fetchNextPage();
    }

    public isolated function next() returns record {|QueryOutput value;|}|Error? {
        while self.index >= self.currentPage.length() {
            if self.exhausted {
                return;
            }
            check self.fetchNextPage();
        }
        record {|QueryOutput value;|} next = {value: self.currentPage[self.index]};
        self.index += 1;
        return next;
    }

    private isolated function fetchNextPage() returns Error? {
        QueryInput request = self.request.clone();
        map<AttributeValue>? startKey = self.nextStartKey;
        if startKey is map<AttributeValue> {
            request.ExclusiveStartKey = startKey;
        }

        QueryOrScanOutput page = check self.fetchPage(request);
        QueryOutput[] items = [];
        foreach map<AttributeValue> item in page?.Items ?: [] {
            items.push({ConsumedCapacity: page?.ConsumedCapacity, Item: item});
        }
        self.currentPage = items;
        self.index = 0;
        self.nextStartKey = page?.LastEvaluatedKey;
        // Absent `LastEvaluatedKey` means this was the final page.
        self.exhausted = self.nextStartKey !is map<AttributeValue>;
    }
}

# Iterates over every item returned by a batch get, re-requesting the unprocessed keys only once the items already
# retrieved have been consumed.
class ItemsBatchGetStream {
    private final BatchGetPageFetcher fetchPage;
    private final BatchItemGetInput request;
    private BatchItem[] currentPage = [];
    private int index = 0;
    private map<KeysAndAttributes> pendingKeys;
    private boolean exhausted = false;

    isolated function init(BatchItemGetInput request, BatchGetPageFetcher fetchPage) returns Error? {
        self.request = request.clone();
        self.fetchPage = fetchPage;
        self.pendingKeys = request.RequestItems.clone();
        check self.fetchNextPage();
    }

    public isolated function next() returns record {|BatchItem value;|}|Error? {
        while self.index >= self.currentPage.length() {
            if self.exhausted {
                return;
            }
            check self.fetchNextPage();
        }
        record {|BatchItem value;|} next = {value: self.currentPage[self.index]};
        self.index += 1;
        return next;
    }

    private isolated function fetchNextPage() returns Error? {
        BatchItemGetInput request = self.request.clone();
        request.RequestItems = self.pendingKeys.clone();

        BatchGetItemsOutput page = check self.fetchPage(request);
        // `ConsumedCapacity` is reported per table, so index it by table name to attach it to each item.
        map<ConsumedCapacity> capacityByTable = {};
        foreach ConsumedCapacity capacity in page?.ConsumedCapacity ?: [] {
            string? tableName = capacity?.TableName;
            if tableName is string {
                capacityByTable[tableName] = capacity;
            }
        }

        BatchItem[] items = [];
        foreach [string, map<AttributeValue>[]] [tableName, tableItems] in (page?.Responses ?: {}).entries() {
            foreach map<AttributeValue> item in tableItems {
                items.push({
                    ConsumedCapacity: capacityByTable[tableName],
                    TableName: tableName,
                    Item: item
                });
            }
        }
        self.currentPage = items;
        self.index = 0;

        map<KeysAndAttributes> unprocessedKeys = page?.UnprocessedKeys ?: {};
        self.pendingKeys = unprocessedKeys;
        // An empty (or absent) `UnprocessedKeys` map means every requested key has been served.
        self.exhausted = unprocessedKeys.length() == 0;
    }
}
