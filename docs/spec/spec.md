# Specification: Ballerina DynamoDB Library

_Authors_: @bhashinee  
_Reviewers_: @daneshk  
_Created_: 2023/11/09  
_Updated_: 2026/08/28  
_Edition_: Swan Lake  

## Introduction

This is the specification for the DynamoDB connector of [Ballerina language](https://ballerina.io/), which allows you to access the Amazon DynamoDB REST API.

The DynamoDB connector specification has evolved and may continue to evolve in the future. The released versions of the specification can be found under the relevant GitHub tag.

If you have any feedback or suggestions about the library, start a discussion via a [GitHub issue](https://github.com/ballerina-platform/ballerina-library/issues) or in the [Discord server](https://discord.gg/ballerinalang). Based on the outcome of the discussion, the specification and implementation can be updated. Community feedback is always welcome. Any accepted proposal, which affects the specification is stored under `/docs/proposals`. Proposals under discussion can be found with the label `type/proposal` in GitHub.

The conforming implementation of the specification is released and included in the distribution. Any deviation from the specification is considered a bug.

## Contents

1. [Overview](#1-overview)
2. [Client](#2-client)
    * 2.1 [Client configurations](#21-client-configurations)
    * 2.2 [Initialization](#22-initialization)
    * 2.3 [Table APIs](#23-table-apis)
        * 2.3.1 [createTable](#231-createtable)
        * 2.3.2 [describeTable](#232-describetable)
        * 2.3.3 [updateTable](#233-updatetable)
        * 2.3.4 [deleteTable](#234-deletetable)
        * 2.3.5 [listTables](#235-listtables)
    * 2.4 [Item APIs](#24-item-apis)
        * 2.4.1 [createItem](#241-createitem)
        * 2.4.2 [getItem](#242-getitem)
        * 2.4.3 [updateItem](#243-updateitem)
        * 2.4.4 [deleteItem](#244-deleteitem)
    * 2.5 [Query and scan APIs](#25-query-and-scan-apis)
        * 2.5.1 [query](#251-query)
        * 2.5.2 [scan](#252-scan)
    * 2.6 [Batch APIs](#26-batch-apis)
        * 2.6.1 [getBatchItems](#261-getbatchitems)
        * 2.6.2 [writeBatchItems](#262-writebatchitems)
    * 2.7 [Account, backup and TTL APIs](#27-account-backup-and-ttl-apis)
        * 2.7.1 [describeLimits](#271-describelimits)
        * 2.7.2 [createBackup](#272-createbackup)
        * 2.7.3 [deleteBackup](#273-deletebackup)
        * 2.7.4 [getTTL](#274-getttl)
    * 2.8 [Closing the client](#28-closing-the-client)
3. [Item data](#3-item-data)
4. [Pagination](#4-pagination)
5. [Errors](#5-errors)

## 1. Overview

The Ballerina `aws.dynamodb` library facilitates APIs to access the Amazon DynamoDB REST API.

Amazon DynamoDB is a fully managed NoSQL database service that provides fast and predictable performance with seamless scalability. It removes the administrative burden of operating and scaling a distributed database: hardware provisioning, setup and configuration, replication, software patching, and cluster scaling.

The library maps one remote method to each of the DynamoDB operations it covers, across table management, item-level reads and writes, queries and scans, batch operations, on-demand backups, time-to-live status, and account quotas.

Transport, request signing, credential resolution, and endpoint resolution are delegated to the shared [`ballerinax/aws`](https://central.ballerina.io/ballerinax/aws/latest) package: requests are signed with AWS Signature Version 4 by `aws.auth`, credentials are resolved (and expiring temporary credentials refreshed) by `auth:CredentialProvider`, and the endpoint URL is resolved from the AWS SDK's endpoint metadata by `aws:resolveEndpoint`.

## 2. Client

`dynamodb:Client` is used to access the Amazon DynamoDB REST API.

### 2.1 Client configurations

```ballerina
public type ConnectionConfig record {|
    # Authentication configuration: any standard credential source supported by AWS
    auth:AuthConfig auth;
    # AWS region: an `aws:Region` enum member or a plain region string
    aws:Region|string region;
    # Optional endpoint options: FIPS/dualstack variants, or a custom endpoint override
    aws:EndpointConfig endpoint?;
    # Controls how `getBatchItems` retries the keys DynamoDB reports as unprocessed
    BatchRetryConfig batchRetry = {};
    ...
|};
```

`auth` accepts any member of `auth:AuthConfig`, which covers every standard AWS credential source:

| Configuration | Credential source |
|---|---|
| `auth:StaticAuthConfig` | Explicit access key/secret, optionally with a session token |
| `auth:ProfileAuthConfig` | A named profile in a local AWS credentials file |
| `auth:AssumeRoleConfig` | Temporary credentials from an STS `AssumeRole` call |
| `auth:WebIdentityConfig` | Temporary credentials from an STS `AssumeRoleWithWebIdentity` call (OIDC) |
| `auth:SsoAuthConfig` | An AWS IAM Identity Center (SSO) session |
| `auth:ProcessAuthConfig` | An external process implementing the AWS `credential_process` contract |
| `auth:DEFAULT_CREDENTIALS` | The AWS default credential provider chain |

Temporary credentials obtained from STS, SSO, a container credential endpoint, or an instance profile are cached and refreshed automatically before they expire; a long-running application therefore does not need to re-create its client.

`region` accepts an `aws:Region` enum member, or a plain string for regions newer than the enum.

`endpoint` selects a non-default endpoint: `fips` and `dualstack` choose the corresponding endpoint variant, and `customEndpoint` overrides the resolved URL entirely (for a VPC interface endpoint, or a local LocalStack or DynamoDB Local instance).

### 2.2 Initialization

A client is initialized with a credential source and a region.

```ballerina
import ballerinax/aws;
import ballerinax/aws.dynamodb;

dynamodb:Client dynamoDb = check new ({
    auth: {accessKeyId: "ACCESS_KEY_ID", secretAccessKey: "SECRET_ACCESS_KEY"},
    region: aws:US_EAST_1
});
```

### 2.3 Table APIs

#### 2.3.1 createTable

Adds a new table to the account. Table names are unique within a Region, so two tables may share a name if they are created in different Regions.

```ballerina
remote isolated function createTable(TableCreateInput tableCreationInput) returns TableDescription|Error;
```

#### 2.3.2 describeTable

Returns information about the table, including its current status, its key schema, and its item count.

```ballerina
remote isolated function describeTable(string tableName) returns TableDescription|Error;
```

#### 2.3.3 updateTable

Modifies the provisioned throughput settings, global secondary indexes, replicas, or DynamoDB Streams settings of a table.

```ballerina
remote isolated function updateTable(TableUpdateInput tableUpdateInput) returns TableDescription|Error;
```

#### 2.3.4 deleteTable

Deletes a table and all of its items.

```ballerina
remote isolated function deleteTable(string tableName) returns TableDescription|Error;
```

#### 2.3.5 listTables

Returns the names of every table associated with the account and endpoint, as an auto-paginating stream.

```ballerina
remote isolated function listTables() returns stream<string, Error?>|Error;
```

### 2.4 Item APIs

#### 2.4.1 createItem

Creates a new item, or replaces an existing item that has the same primary key. Supports conditional writes.

```ballerina
remote isolated function createItem(ItemCreateInput itemCreateInput) returns ItemDescription|Error;
```

#### 2.4.2 getItem

Returns a set of attributes for the item with the given primary key.

```ballerina
remote isolated function getItem(ItemGetInput itemGetInput) returns ItemGetOutput|Error;
```

#### 2.4.3 updateItem

Edits an existing item's attributes, or adds a new item if it does not already exist.

```ballerina
remote isolated function updateItem(ItemUpdateInput itemUpdateInput) returns ItemDescription|Error;
```

#### 2.4.4 deleteItem

Deletes a single item by primary key. Supports conditional deletes.

```ballerina
remote isolated function deleteItem(ItemDeleteInput itemDeleteInput) returns ItemDescription|Error;
```

### 2.5 Query and scan APIs

#### 2.5.1 query

Returns all items with a given partition key value, optionally refined by a sort key condition. The result is an auto-paginating stream, one `QueryOutput` per item.

```ballerina
remote isolated function query(QueryInput queryInput) returns stream<QueryOutput, Error?>|Error;
```

#### 2.5.2 scan

Returns items by reading every item in a table or a secondary index. The result is an auto-paginating stream, one `ScanOutput` per item.

```ballerina
remote isolated function scan(ScanInput scanInput) returns stream<ScanOutput, Error?>|Error;
```

### 2.6 Batch APIs

#### 2.6.1 getBatchItems

Returns the attributes of one or more items from one or more tables, identified by primary key. The result is a stream; keys that DynamoDB reports as unprocessed are re-requested transparently as the stream is consumed.

```ballerina
remote isolated function getBatchItems(BatchItemGetInput batchItemGetInput) returns stream<BatchItem, Error?>|Error;
```

#### 2.6.2 writeBatchItems

Puts or deletes multiple items in one or more tables. Items that could not be processed are returned in `UnprocessedItems` for the caller to retry.

```ballerina
remote isolated function writeBatchItems(BatchItemInsertInput batchItemInsertInput) returns BatchItemInsertOutput|Error;
```

### 2.7 Account, backup and TTL APIs

#### 2.7.1 describeLimits

Returns the current provisioned-capacity quotas for the account in a Region, both for the Region as a whole and for any one table created in it.

```ballerina
remote isolated function describeLimits() returns LimitDescription|Error;
```

#### 2.7.2 createBackup

Creates an on-demand backup of a table.

```ballerina
remote isolated function createBackup(BackupCreateInput backupCreateInput) returns BackupDetails|Error;
```

#### 2.7.3 deleteBackup

Deletes an existing backup of a table.

```ballerina
remote isolated function deleteBackup(string backupArn) returns BackupDescription|Error;
```

#### 2.7.4 getTTL

Returns the Time to Live (TTL) status of a table.

```ballerina
remote isolated function getTTL(string tableName) returns TTLDescription|Error;
```

### 2.8 Closing the client

`close` releases the resources held by the credential provider: its background refresh threads, and the HTTP connections it keeps open to reach STS/SSO. It is a normal method rather than a remote method, because it interacts with no remote system.

```ballerina
public isolated function close() returns Error?;
```

## 3. Item data

An item is a map from attribute name to `AttributeValue`, and an `AttributeValue` is a tagged union in which exactly one field carries the value: `S` for a string, `N` for a number (transported as a string, so that arbitrary precision survives), `B` for binary, `BOOL`, `NULL`, `SS`/`NS`/`BS` for the set types, `L` for a list, and `M` for a nested map.

```ballerina
map<dynamodb:AttributeValue> item = {
    "GameId": {S: "FlappyBird"},
    "Score": {N: "500"},
    "Tags": {SS: ["arcade", "mobile"]}
};
```

Attribute names are user data. They are carried verbatim in both directions and are never case-converted, so an attribute named `ForumName` is written and read back as `ForumName`.

The fields of the request and response records use the AWS wire names (`TableName`, `AttributeDefinitions`, `KeySchema`, and so on), matching the [DynamoDB API reference](https://docs.aws.amazon.com/amazondynamodb/latest/APIReference/Welcome.html) directly.

## 4. Pagination

`listTables`, `query`, `scan`, and `getBatchItems` return Ballerina streams that page through the result set on the caller's behalf. The first page is fetched when the operation is called, and each subsequent page only once the previous one has been consumed.

A page may legitimately come back empty while still carrying a continuation token — DynamoDB returns this when a `Limit` or a `FilterExpression` eliminated every item it examined. An empty page is therefore not the end of the result set: the stream keeps fetching until a page yields a value or the result set is genuinely exhausted, which is signalled by an absent `LastEvaluatedKey` (or `LastEvaluatedTableName`).

`getBatchItems` follows the same shape with a different continuation token: whatever DynamoDB reports in `UnprocessedKeys` is re-requested on the next fetch, and the stream completes once that map comes back empty.

Unprocessed keys mean the table was at its throughput limit, so those re-requests are paced rather than issued immediately — AWS warns that an immediate retry is likely to be throttled again. `ConnectionConfig.batchRetry` controls the pacing:

```ballerina
public type BatchRetryConfig record {|
    # The wait before the first retry, in seconds
    decimal initialInterval = 0.025;
    # The ceiling the wait grows to, in seconds
    decimal maxInterval = 20;
    # How many consecutive responses may return no items at all before the batch is abandoned
    int maxUnproductiveAttempts = 8;
|};
```

The wait starts at `initialInterval` and doubles up to `maxInterval` between responses that serve nothing. A response that serves even one key is progress, and resets both the wait and the count — so only a persistently throttled table can exhaust the budget. Once `maxUnproductiveAttempts` consecutive responses have served nothing, the batch is abandoned with an `Error` naming how many keys were left, rather than being retried forever.

The initial request counts as the first such attempt, so `maxUnproductiveAttempts` bounds the total number of requests a throttled batch makes, not the retries on top of the first one.

A non-positive value in any of the three fields is treated as unset and falls back to that field's default.

## 5. Errors

The module defines a single generic error type, plus two distinct subtypes that mark the failures on either side of the service call. All three carry the shared [`aws:ErrorDetails`](https://central.ballerina.io/ballerinax/aws/latest) record, so the detail fields are named and typed identically across every revamped AWS connector.

```ballerina
public type Error distinct error<aws:ErrorDetails>;
public type RequestGenerationError distinct Error;
public type ResponseHandlingError distinct Error;
```

`RequestGenerationError` is raised before anything is sent, when the AWS credentials cannot be resolved or the request cannot be signed. `ResponseHandlingError` is raised when a response arrives but cannot be read or bound to the expected record. Neither carries a service failure, so their detail fields are left unset — the same convention `aws.auth` follows, where `CredentialResolutionError` is detailed and `SigningError` is not.

A failure reported by DynamoDB itself is raised as a plain `Error`, whose message names the status code and whose detail is fully populated:

```ballerina
dynamodb:TableDescription|dynamodb:Error result = dynamoDb->describeTable("NoSuchTable");
if result is dynamodb:Error {
    aws:ErrorDetails detail = result.detail();
    io:println(detail.httpStatusCode);   // 400
    io:println(detail.errorCode);        // "ResourceNotFoundException"
    io:println(detail.errorMessage);     // "Requested resource not found"
    io:println(detail.requestId);
}
```

`errorCode` and `errorMessage` are read from the service's JSON 1.0 error document, which has the shape `{"__type": "<prefix>#<Exception>", "message": "<text>"}`; the qualifying prefix is stripped from `__type`, so `errorCode` is the bare exception name.

A failure body is not always that document — a proxy or gateway in front of the endpoint may answer with something else entirely, such as an HTML error page. There is then no exception name to report, so `errorCode` is empty and the body itself becomes `errorMessage` verbatim, rather than being dropped. When the body cannot be read at all, the read failure is the error's `cause`.
