# Specification: Ballerina DynamoDB Library

_Owners_: @bhashinee  
_Reviewers_: @daneshk  
_Created_: 2023/11/09  
_Updated_: 2022/11/10  
_Edition_: Swan Lake  

## Introduction

This is the specification for the DynamoDB connector of [Ballerina language](https://ballerina.io/), which allows you to access the Amazon DynamoDB REST API.

The DynamoDB connector specification has evolved and may continue to evolve in the future. The released versions of the specification can be found under the relevant GitHub tag.

If you have any feedback or suggestions about the library, start a discussion via a [GitHub issue](https://github.com/ballerina-platform/ballerina-standard-library/issues) or in the [Discord server](https://discord.gg/ballerinalang). Based on the outcome of the discussion, the specification and implementation can be updated. Community feedback is always welcome. Any accepted proposal, which affects the specification is stored under `/docs/proposals`. Proposals under discussion can be found with the label `type/proposal` in GitHub.

The conforming implementation of the specification is released and included in the distribution. Any deviation from the specification is considered a bug.

## Contents
1. [Overview](#1-overview)
2. [Client](#2-client)
    1. [Client Configurations](#21-client-configurations)
    2. [Initialization](#22-initialization)
    3. [APIs](#23-apis)
        1. [createTable](#createTable)
        2. [deleteTable](#deleteTable)
        3. [describeTable](#describeTable)
        4. [listTables](#listTables)
        5. [updateTable](#updateTable)
        6. [createItem](#createItem)
        7. [getItem](#getItem)
        8. [deleteItem](#deleteItem)
        9. [updateItem](#updateItem)
        10. [query](#query)
        11. [scan](#scan)
        12. [getBatchItem](#getBatchItem)
        13. [writeBatchItem](#writeBatchItem)
        14. [describeLimits](#describeLimits)
        15. [createBackup](#createBackup)
        16. [deleteBackup](#deleteBackup)
        17. [getTTL](#getTTL)
       
## 1. [Overview](#1-overview)

The Ballerina `dynamodb` library facilitates APIs to allow you to access the Amazon DynamoDB REST API. Amazon DynamoDB is a fully managed NoSQL database service that provides fast and predictable performance with seamless scalability. Amazon DynamoDB enables customers to offload the administrative burdens of operating and scaling distributed databases to AWS, so they do not have to worry about hardware provisioning, setup and configuration, replication, software patching, or cluster scaling.

## 2. [Client](#2-client)

`dynamodb:Client` can be used to access the Amazon DynamoDB REST API. 

### 2.1. [Client Configurations](#21-client-configurations)

When initializing the client, following configurations can be provided,

```ballerina
public type ConnectionConfig record {|
    *config:ConnectionConfig;
    never auth?;
    # AWS credentials
    AwsCredentials|AwsTemporaryCredentials awsCredentials;
    # AWS Region
    string region;
|};
```

### 2.2. [Initialization](#22-initialization)

A client can be initialized by providing the AwsCredentials and optionally the other configurations in `ClientConfiguration`.

```ballerina
ConnectionConfig config = {
    awsCredentials: {accessKeyId: "ACCESS_KEY_ID", secretAccessKey: "SECRET_ACCESS_KEY"},
    region: "ap-south-1"
};

Client dynamoDBClient = check new (config);
```

### 2.3 [APIs](#23-apis)

#### [createTable](#createTable)

This API can be used to create a new table in DynamoDB with the specified parameters.

```ballerina
# Creates a table. The CreateTable operation adds a new table to your account. In an AWS account, table names must be
# unique within each Region. That is, you can have two tables with same name if you create the tables in diﬀerent
# Regions.
#
# + tableCreationInput - The request payload to create a table
# + return - If success, dynamodb:TableDescription record, else an error
remote isolated function createTable(TableCreateInput tableCreationInput) returns TableDescription|error {
```

#### [deleteTable](#deleteTable)

This API can be used to delete a table in DynamoDB with the given table name.

```ballerina
# Deletes a table.
#
# + tableName - The name of the table to delete
# + return - If success, dynamodb:TableDescription record, else an error
remote isolated function deleteTable(string tableName) returns TableDescription|error {
```

#### [describeTable](#describeTable)

This API can be used to get the table details in DynamoDB with the given table name.

```ballerina
# Describes a table.
#
# + tableName - The name of the table to delete
# + return - If success, dynamodb:TableDescription record, else an error
remote isolated function describeTable(string tableName) returns TableDescription|error {
```

#### [listTables](#listTables)

This API can be used to list all the tables relavant to your account.

```ballerina
# Lists all tables.
#
# + return - If success, stream<string, error?>, else an error
remote isolated function listTables() returns stream<string, error?>|error {
```

#### [updateTable](#updateTable)

This API can be used to update the entries in the table with the specified parameters.

```ballerina
# Updates a table.
#
# + tableUpdateInput - The request payload to update a table 
# + return - If success, dynamodb:TableDescription record, else an error
remote isolated function updateTable(TableUpdateInput tableUpdateInput) returns TableDescription|error {
```

#### [createItem](#createItem)

This API can be used to add a new item to the table.

```ballerina
# Creates a new item, or replaces an old item with a new item. If an item that has the same primary key as the new
# item already exists in the speciﬁed table, the new item completely replaces the existing item. You can perform a
# conditional put operation (add a new item if one with the speciﬁed primary key doesn't exist), or replace an
# existing item if it has certain attribute values.
#
# + itemCreateInput - The request payload to create an item
# + return - If success, dynamodb:ItemDescription record, else an error
remote isolated function createItem(ItemCreateInput itemCreateInput) returns ItemDescription|error {
```

#### [getItem](#getItem)

This API can be used to get a specific item from the table.

```ballerina
# Gets an item.
#
# + itemGetInput - The request payload to get an item
# + return - If success, dynamodb:GetItemOutput record, else an error
remote isolated function getItem(ItemGetInput itemGetInput) returns ItemGetOutput|error {
```

#### [deleteItem](#deleteItem)

This API can be used to delete a specific item from the table.

```ballerina
# Deletes an item.
#
# + itemDeleteInput - The request payload to delete an item
# + return - If success, dynamodb:ItemDescription record, else an error
remote isolated function deleteItem(ItemDeleteInput itemDeleteInput) returns ItemDescription|error {
```

#### [updateItem](#updateItem)

This API can be used to update a specific item from the table.

```ballerina
# Updates an item
#
# + itemUpdateInput - The request payload to update an item
# + return - If success, dynamodb:ItemDescription record, else an error
remote isolated function updateItem(ItemUpdateInput itemUpdateInput) returns ItemDescription|error {
```

#### [query](#query)

This API can be used retrieve items from a table that match specific criteria.

```ballerina
# Returns all items with a particular partition key value. You must provide the name of the partition key attribute
# and a single value for that attribute. Optionally, you can provide a sort key attribute and use a comparison
# operator to reﬁne the search results.
#
# + queryInput - The request payload to query
# + return - If success, stream<dynamodb:QueryOutput,error?>, else an error
remote isolated function query(QueryInput queryInput) returns stream<QueryOutput, error?>|error {
```

#### [scan](#scan)

This API can be used to read all the items in a table and return them as a result set.

```ballerina
# Returns one or more items and item attributes by accessing every item in a table or a secondary index.
#
# + scanInput - The request payload to scan
# + return - If success, stream<dynamodb:ScanOutput,error?>, else an error
remote isolated function scan(ScanInput scanInput) returns stream<ScanOutput, error?>|error {
```

#### [getBatchItem](#getBatchItem)

This API can be used to retrieve multiple items from one or more tables in a single request. This operation is designed for efficiency and allows you to request items from multiple tables or multiple items from a single table using a single API call.

```ballerina
# Returns the attributes of one or more items from one or more tables. You identify requested items by primary key.
#
# + batchItemGetInput - The request payload to get items as batch
# + return - If success, stream<dynamodb:BatchItem, error?>, else an error
remote isolated function getBatchItem(BatchItemGetInput batchItemGetInput) returns stream<BatchItem, error?>|error {
```

#### [writeBatchItem](#writeBatchItem)

This API can be used to perform multiple write operations (PutItem, UpdateItem, DeleteItem) across one or more tables in a single request. This operation is designed for efficiency and allows you to execute multiple write operations with a single API call.

```ballerina
# Puts or deletes multiple items in one or more tables.
#
# + batchItemInsertInput - The request payload to write items as batch
# + return - If success, dynamodb:BatchItemWriteOutput record, else an error
remote isolated function writeBatchItem(BatchItemInsertInput batchItemInsertInput) returns BatchItemWriteOutput|error {
```

#### [describeLimits](#describeLimits)

This API can be used to get information about the current account limits and usage for certain operations in Amazon DynamoDB.

```ballerina
# Returns the current provisioned-capacity quotas for your AWS account in a Region, both for the Region as a whole
# and for any one DynamoDB table that you create there.
#
# + return - If success, dynamodb:LimitDescription record, else an error
remote isolated function describeLimits() returns LimitDescription|error {
```

#### [createBackup](#createBackup)

This API can be used to manually create a backup for a table.

```ballerina
# Creates a back up from the given table
#
# + backupCreateInput - The request payload to backup the table
# + return - If success, dynamodb:BackupDetails record, else an error
remote isolated function createBackup(BackupCreateInput backupCreateInput) returns BackupDetails|error {
```

#### [deleteBackup](#deleteBackup)

This API can be used to delete a backup of a table.

```ballerina
# Deletes an existing backup of a table.
#
# + backupArn - The backupArn of the table that needs to be deleted
# + return - If success, dynamodb:BackupDescription record, else an error
remote isolated function deleteBackup(string backupArn) returns BackupDescription|error {
```

#### [getTTL](#getTTL)

This API can be used to get the Time to Live status of a table.

```ballerina
# The description of the Time to Live (TTL) status on the specified table.
#
# + tableName - Table name 
# + return - If success, dynamodb:TTLDescription record, else an error
remote isolated function getTTL(string tableName) returns TTLDescription|error {
```
