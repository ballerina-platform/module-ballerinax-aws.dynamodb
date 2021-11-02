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

# Represents AWS client configuration.
#
# + awsCredentials - AWS credentials  
# + region - AWS region  
public type ConnectionConfig record {
    AwsCredentials|AwsTemporaryCredentials awsCredentials;
    string region;
};

# Represents AWS credentials.
#
# + accessKeyId - AWS access key  
# + secretAccessKey - AWS secret key
public type AwsCredentials record {
    string accessKeyId;
    string secretAccessKey;
};

# Represents AWS temporary credentials.
#
# + accessKeyId - AWS access key  
# + secretAccessKey - AWS secret key  
# + securityToken - AWS secret token
public type AwsTemporaryCredentials record {
    string accessKeyId;
    string secretAccessKey;
    string securityToken;   
};

# Describes the current provisioned-capacity quotas for your AWS account in a Region, both for the Region as a whole and
# for any one DynamoDB table that you create there.
#
# + AccountMaxReadCapacityUnits - The maximum total read capacity units that your account allows you to provision across
#                                 all of your tables in this Region
# + AccountMaxWriteCapacityUnits - The maximum total write capacity units that your account allows you to provision
#                                  across all of your tables in this Region
# + TableMaxReadCapacityUnits - The maximum read capacity units that your account allows you to provision for a new
#                               table that you are creating in this Region, including the read capacity units
#                               provisioned for its global secondary indexes (GSIs).
# + TableMaxWriteCapacityUnits - The maximum write capacity units that your account allows you to provision for a new
#                                table that you are creating in this Region, including the write capacity units
#                                provisioned for its global secondary  indexes (GSIs).
public type LimitDescribtion record {
    int? AccountMaxReadCapacityUnits?;
    int? AccountMaxWriteCapacityUnits?;
    int? TableMaxReadCapacityUnits?;
    int? TableMaxWriteCapacityUnits?;
};

# Represents the response after `BatchWriteItem` operation.
#
# + ConsumedCapacity - The capacity units consumed by the entire `BatchWriteItem` operation
# + ItemCollectionMetrics -A list of tables that were processed by `BatchWriteItem` and, for each table, information about
#                          any item collections that were aﬀected by individual `DeleteItem` or  `PutItem` operations.
# + UnprocessedItems - A map of tables and requests against those tables that were not processed. The `UnprocessedItems`
#                      value is in the same form as `RequestItems`, so you can provide this value directly to a subsequent
#                      `BatchGetItem` operation.
public type ItemsBatchWriteResponse record {
    ConsumedCapacity[]? ConsumedCapacity?;
    map<ItemCollectionMetrics[]>? ItemCollectionMetrics?;
    map<WriteRequest[]>? UnprocessedItems?;
};

# Represents the request payload `BatchWriteItem` operation.
#
# + RequestItems - A map of one or more table names and, for each table, a list of operations to be performed
#                  (DeleteRequest or PutRequest).
# + ReturnConsumedCapacity - Determines the level of detail about provisioned throughput consumption that is returned
#                            in the response. Valid Values: INDEXES | TOTAL | NONE
# + ReturnItemCollectionMetrics - Determines whether item collection metrics are returned. Valid Values: SIZE | NONE
public type ItemsBatchWriteRequest record {
    map<WriteRequest[]> RequestItems;
    ReturnConsumedCapacity ReturnConsumedCapacity?;
    ReturnItemCollectionMetrics ReturnItemCollectionMetrics?;
};

# Represents the response after `BatchGetItem` operation.
#
# + ConsumedCapacity - The read capacity units consumed by the entire BatchGetItem operation
# + Responses - A map of table name to a list of items. Each object in Responses consists of a table name, along with a
#               map of attribute data consisting of the data type and attribute value.
# + UnprocessedKeys - A map of tables and their respective keys that were not processed with the current response. The
#                     `UnprocessedKeys` value is in the same form as `RequestItems`, so the value can be provided
#                     directly to a subsequent `BatchGetItem` operation.
public type ItemsBatchGetResponse record {
    ConsumedCapacity[]? ConsumedCapacity?;
    map<map<AttributeValue>[]>? Responses?;
    map<KeysAndAttributes>? UnprocessedKeys?;
};

# Represents ItemByBatchGet
#
# + ConsumedCapacity - The read capacity units consumed by the entire BatchGetItem operation
# + TableName - The name of the table containing the requested item
# + Item - The requested item
public type ItemByBatchGet record {
    ConsumedCapacity? ConsumedCapacity?;
    string? TableName?;
    map<AttributeValue>? Item?;
};

# Represents the request payload for a `BatchGetItem` operation.
#
# + RequestItems - A map of one or more table names and, for each table, a map that describes one or more items to
#                  retrieve from that table
# + ReturnConsumedCapacity - Determines the level of detail about provisioned throughput consumption that is returned in
#                            the response. Valid Values: INDEXES | TOTAL | NONE
public type ItemsBatchGetRequest record {
    map<KeysAndAttributes> RequestItems;
    ReturnConsumedCapacity ReturnConsumedCapacity?;
};

# Represents the request payload for `Scan` Operation.
#
# + TableName - The name of the table containing the requested items; or, if you provide IndexName, the name of the
#               table to which that index belongs
# + AttributesToGet - This is a legacy parameter. Use ProjectionExpression instead. 
# + ConditionalOperator - This is a legacy parameter. Use FilterExpression instead. Valid Values: AND | OR
# + ConsistentRead - A Boolean value that determines the read consistency model during the scan
# + ExclusiveStartKey - The primary key of the ﬁrst item that this operation will evaluate. Use the value that was
#                       returned for `LastEvaluatedKey` in the previous operation.
# + ExpressionAttributeNames - One or more substitution tokens for attribute names in an expression
# + ExpressionAttributeValues - One or more values that can be substituted in an expression
# + FilterExpression - A string that contains conditions that DynamoDB applies after the Scan operation, but before the
#                      data is returned to you. Items that do not satisfy the FilterExpression criteria are not returned.
# + IndexName - The name of a secondary index to scan. This index can be any local secondary index or global secondary
#               index. Note that if you use the IndexName parameter, you must also provide TableName.
# + Limit - The maximum number of items to evaluate (not necessarily the number of matching items)
# + ProjectionExpression - A string that identiﬁes one or more attributes to retrieve from the speciﬁed table or index
# + ReturnConsumedCapacity - Determines the level of detail about provisioned throughput consumption that is returned in
#                            the response. Valid Values: INDEXES | TOTAL | NONE
# + ScanFilter - This is a legacy parameter. Use FilterExpression instead.
# + Segment - For a parallel Scan request, Segment identiﬁes an individual segment to be scanned by an application
#             worker.
# + Select - The attributes to be returned in the result. Valid Values: ALL_ATTRIBUTES | ALL_PROJECTED_ATTRIBUTES |
#            SPECIFIC_ATTRIBUTES |COUNT .
# + TotalSegments - For a parallel Scan request, TotalSegments represents the total number of segments into which the
#                   Scan operation will be divided
public type ScanRequest record {
    string TableName;
    string[] AttributesToGet?;
    ConditionalOperator ConditionalOperator?;
    boolean ConsistentRead?;
    map<AttributeValue>? ExclusiveStartKey?;
    map<string> ExpressionAttributeNames?;
    map<AttributeValue> ExpressionAttributeValues?;
    string FilterExpression?;
    string IndexName?;
    int Limit?;
    string ProjectionExpression?;
    ReturnConsumedCapacity ReturnConsumedCapacity?;
    map<Condition> ScanFilter?;
    int Segment?;
    Select Select?;
    int TotalSegments?;
};

# Represents the response of Query operation.
#
# + ConsumedCapacity - The capacity units consumed by the Query operation. 
# + Item - An Item that match the query criteria. It consists of an attribute name and the value for that attribute.
public type QueryResponse record {
    ConsumedCapacity? ConsumedCapacity?;
    map<AttributeValue>? Item?;
};

# Reperesents the response of Scan operation.
#
# + ConsumedCapacity - The capacity units consumed by the Scan operation.
# + Item - An Item that match the scan criteria. It consists of an attribute name and the value for that attribute.
public type ScanResponse record {
    ConsumedCapacity? ConsumedCapacity?;
    map<AttributeValue>? Item?;
};

# Represents the response of Query or Scan operation.
#
# + ConsumedCapacity - The capacity units consumed by the Scan operation.
# + Count - The number of items in the response.
# + Items - An array of item attributes that match the scan criteria. Each element in this array consists of an
#           attribute name and the value for that attribute.
# + LastEvaluatedKey - The primary key of the item where the operation stopped, inclusive of the previous result set.
#                      Use this value to start a new operation, excluding this value in the new request.
# + ScannedCount - The number of items evaluated, before any ScanFilter or QueryFilter is applied. A high ScannedCount 
#                  value with few, or no, Count results indicates an ineﬃcient Scan or Query operation.
public type QueryOrScanResponse record {
    ConsumedCapacity? ConsumedCapacity?;
    int? Count?;
    map<AttributeValue>[]? Items?;
    map<AttributeValue>? LastEvaluatedKey?;
    int? ScannedCount?;
};

# Represents the request payload for `Query` Operation.
#
# + TableName - The name of the table containing the requested items
# + AttributesToGet - This is a legacy parameter. Use ProjectionExpression instead.
# + ConditionalOperator - This is a legacy parameter. Use FilterExpression instead. Valid Values: AND | OR
# + ConsistentRead - Determines the read consistency model: If set to true, then the operation uses strongly consistent
#                    reads; otherwise, the operation uses eventually consistent reads.
# + ExclusiveStartKey - The primary key of the ﬁrst item that this operation will evaluate
# + ExpressionAttributeNames - One or more substitution tokens for attribute names in an expression
# + ExpressionAttributeValues - One or more values that can be substituted in an expression
# + FilterExpression - A string that contains conditions that DynamoDB applies after the Query operation, but before the
#                     data is returned to you. Items that do not satisfy the FilterExpression criteria are not returned.
# + IndexName - The name of an index to query. This index can be any local secondary index or global secondary index on
#               the table. Note that if you use the IndexName parameter, you must also provide TableName.
# + KeyConditionExpression - The condition that speciﬁes the key values for items to be retrieved by the Query action
# + KeyConditions - This is a legacy parameter. Use KeyConditionExpression instead.
# + Limit - The maximum number of items to evaluate (not necessarily the number of matching items)
# + ProjectionExpression - A string that identiﬁes one or more attributes to retrieve from the table
# + QueryFilter - This is a legacy parameter. Use FilterExpression instead.
# + ReturnConsumedCapacity - Determines the level of detail about provisioned throughput consumption that is returned in
#                            the response. Valid Values: INDEXES | TOTAL | NONE
# + ScanIndexForward - Speciﬁes the order for index traversal: If true (default), the traversal is performed in
#                      ascending order; if false, the traversal is performed in descending order.
# + Select - The attributes to be returned in the result. Valid Values: ALL_ATTRIBUTES | ALL_PROJECTED_ATTRIBUTES |
#            SPECIFIC_ATTRIBUTES | COUNT .
public type QueryRequest record {
    string TableName;
    string[] AttributesToGet?;
    ConditionalOperator ConditionalOperator?;
    boolean ConsistentRead?;
    map<AttributeValue>? ExclusiveStartKey?;
    map<string> ExpressionAttributeNames?;
    map<AttributeValue> ExpressionAttributeValues?;
    string FilterExpression?;
    string IndexName?;
    string KeyConditionExpression?;
    map<Condition> KeyConditions?;
    int Limit?;
    string ProjectionExpression?;
    map<Condition> QueryFilter?;
    ReturnConsumedCapacity ReturnConsumedCapacity?;
    boolean ScanIndexForward?;
    Select Select?;
};

# Represents the request payload to update an item.
#
# + Key - The primary key of the item to be updated. Each element consists of an attribute name and a value for that
#         attribute.
# + TableName - The name of the table containing the item to update
# + AttributeUpdates - This is a legacy parameter. Use UpdateExpression instead.
# + ConditionalOperator - This is a legacy parameter. Use ConditionExpression instead. Valid Values: AND | OR
# + ConditionExpression - A condition that must be satisﬁed in order for a conditional update to succeed.
# + Expected - This is a legacy parameter. Use ConditionExpression instead.
# + ExpressionAttributeNames - One or more substitution tokens for attribute names in an expression
# + ExpressionAttributeValues - One or more values that can be substituted in an expression
# + ReturnConsumedCapacity - Determines the level of detail about provisioned throughput consumption that is returned in
#                            the response. Valid Values: INDEXES | TOTAL | NONE .
# + ReturnItemCollectionMetrics - Determines whether item collection metrics are returned. Valid Values: SIZE | NONE .
# + ReturnValues - Use ReturnValues if you want to get the item attributes as they appear before or after they are
#                  updated. Valid Values: NONE | ALL_OLD | UPDATED_OLD | ALL_NEW | UPDATED_NEW .
# + UpdateExpression - An expression that deﬁnes one or more attributes to be updated, the action to be performed on
#                      them, and new values for them
public type ItemUpdateRequest record {
    map<AttributeValue> Key;
    string TableName;
    map<AttributeValueUpdate> AttributeUpdates?;
    ConditionalOperator ConditionalOperator?;
    string ConditionExpression?;
    map<ExpectedAttributeValue> Expected?;
    map<string> ExpressionAttributeNames?;
    map<AttributeValue> ExpressionAttributeValues?;
    ReturnConsumedCapacity ReturnConsumedCapacity?;
    ReturnItemCollectionMetrics ReturnItemCollectionMetrics?;
    ReturnValues ReturnValues?;
    string UpdateExpression?;
};

# Represents the request payload to delete an item.
#
# + Key - A map of attribute names to AttributeValue objects, representing the primary key of the item to delete
# + TableName - The name of the table from which to delete the item
# + ConditionalOperator - This is a legacy parameter. Use ConditionExpression instead. Valid Values: AND | OR .
# + ConditionExpression - A condition that must be satisﬁed in order for a conditional DeleteItem to succeed
# + Expected - This is a legacy parameter. Use ConditionExpression instead.
# + ExpressionAttributeNames - One or more substitution tokens for attribute names in an expression
# + ExpressionAttributeValues - One or more values that can be substituted in an expression
# + ReturnConsumedCapacity - Determines the level of detail about provisioned throughput consumption that is returned in
#                            the response. Valid Values: INDEXES | TOTAL | NONE .
# + ReturnItemCollectionMetrics - Determines whether item collection metrics are returned. Valid Values: SIZE | NONE .
# + ReturnValues - Use ReturnValues if you want to get the item attributes as they appeared before they were deleted.
#                  For DeleteItem, the valid values are: NONE | ALL_OLD .
public type ItemDeleteRequest record {
    map<AttributeValue> Key;
    string TableName;
    ConditionalOperator ConditionalOperator?;
    string ConditionExpression?;
    map<ExpectedAttributeValue> Expected?;
    map<string> ExpressionAttributeNames?;
    map<AttributeValue> ExpressionAttributeValues?;
    ReturnConsumedCapacity ReturnConsumedCapacity?;
    ReturnItemCollectionMetrics ReturnItemCollectionMetrics?;
    ReturnValues ReturnValues?;
};

# Represents the response of `GetItem` operation.
#
# + ConsumedCapacity - The capacity units consumed by the GetItem operation
# + Item - A map of attribute names to AttributeValue objects, as speciﬁed by ProjectionExpression
public type ItemGetResponse record {
    ConsumedCapacity? ConsumedCapacity?;
    map<AttributeValue>? Item?;
};

# Represents the request payload to get an Item.
#
# + Key - A map of attribute names to AttributeValue objects, representing the primary key of the item to retrieve
# + TableName - The name of the table containing the requested item
# + AttributesToGet - This is a legacy parameter. Use ProjectionExpression instead.
# + ConsistentRead - Determines the read consistency model: If set to true, then the operation uses strongly consistent
#                    reads; otherwise, the operation uses eventually consistent reads.
# + ExpressionAttributeNames - One or more substitution tokens for attribute names in an expression
# + ProjectionExpression - A string that identiﬁes one or more attributes to retrieve from the table
# + ReturnConsumedCapacity - Determines the level of detail about provisioned throughput consumption that is returned in
#                            the response. Valid Values: INDEXES | TOTAL | NONE .
public type ItemGetRequest record {
    map<AttributeValue> Key;
    string TableName;
    string[] AttributesToGet?;
    boolean ConsistentRead?;
    map<string> ExpressionAttributeNames?;
    string ProjectionExpression?;
    ReturnConsumedCapacity ReturnConsumedCapacity?;
};

# Represents the response of PutItem operation.
#
# + Attributes - The attribute values as they appeared before the PutItem operation, but only if ReturnValues is
#                speciﬁed as ALL_OLD in the request. Each element consists of an attribute name and an attribute value.
# + ConsumedCapacity - The capacity units consumed by the PutItem operation
# + ItemCollectionMetrics - Information about item collections, if any, that were aﬀected by the PutItem operation
public type ItemDescription record {
    map<AttributeValue>? Attributes?;
    ConsumedCapacity? ConsumedCapacity?;
    ItemCollectionMetrics? ItemCollectionMetrics?;
};

# Represents the request payload to put item.
#
# + Item - A map of attribute name/value pairs, one for each attribute. Only the primary key attributes are required;
#          you can optionally provide other attribute name-value pairs for the item.
# + TableName - The name of the table to contain the item
# + ConditionalOperator - This is a legacy parameter. Use ConditionExpression instead. Valid Values: AND | OR .
# + ConditionExpression - A condition that must be satisﬁed in order for a conditional PutItem operation to succeed
# + Expected - This is a legacy parameter. Use ConditionExpression instead.
# + ExpressionAttributeNames - One or more substitution tokens for attribute names in an expression
# + ExpressionAttributeValues - One or more values that can be substituted in an expression
# + ReturnConsumedCapacity - Determines the level of detail about provisioned throughput consumption that is returned in
#                            the response. Valid Values: INDEXES | TOTAL | NONE .
# + ReturnItemCollectionMetrics - Determines whether item collection metrics are returned. Valid Values: SIZE | NONE .
# + ReturnValues - Use ReturnValues if you want to get the item attributes as they appeared before they were updated
#                  with the PutItem request. For PutItem, the valid values are: NONE | ALL_OLD .
public type ItemCreateRequest record {
    map<AttributeValue> Item;
    string TableName;
    ConditionalOperator ConditionalOperator?;
    string ConditionExpression?;
    map<ExpectedAttributeValue> Expected?;
    map<string> ExpressionAttributeNames?;
    map<AttributeValue> ExpressionAttributeValues?;
    ReturnConsumedCapacity ReturnConsumedCapacity?;
    ReturnItemCollectionMetrics ReturnItemCollectionMetrics?;
    ReturnValues ReturnValues?;
};

# Represents the request payload to update table.
#
# + TableName - The name of the table to be updated
# + AttributeDefinitions - An array of attributes that describe the key schema for the table and indexes. If you are
#                          adding a new global secondary index to the table, AttributeDefinitions must include the key
#                          element(s) of the new index.
# + BillingMode - Controls how you are charged for read and write throughput and how you manage capacity
# + GlobalSecondaryIndexUpdates - An array of one or more global secondary indexes for the table
# + ProvisionedThroughput - The new provisioned throughput settings for the speciﬁed table or index
# + ReplicaUpdates - A list of replica update actions (create, delete, or update) for the table
# + SSESpecification - The new server-side encryption settings for the speciﬁed table
# + StreamSpecification - Represents the DynamoDB Streams conﬁguration for the table
public type TableUpdateRequest record {
    string TableName;
    AttributeDefinition[] AttributeDefinitions?;
    BillingMode BillingMode?;
    GlobalSecondaryIndexUpdate[] GlobalSecondaryIndexUpdates?;
    ProvisionedThroughput ProvisionedThroughput?;
    ReplicationGroupUpdate[] ReplicaUpdates?;
    SSESpecification SSESpecification?;
    StreamSpecification StreamSpecification?;
};

# Represents the request payload to list tables.
#
# + ExclusiveStartTableName - The ﬁrst table name that this operation will evaluate
# + Limit - A maximum number of table names to return. If this parameter is not speciﬁed, the limit is 100.
public type TableListRequest record {
    string? ExclusiveStartTableName?;
    int? Limit?;
};

# List of Tables.
#
# + LastEvaluatedTableName - The name of the last table in the current page of results. Use this value as the
#                            ExclusiveStartTableName in a new request to obtain the next page of results, until all the
#                            table names are returned.
# + TableNames - The names of the tables associated with the current account at the current endpoint. The maximum size
#                of this array is 100.
public type TableList record {
    string LastEvaluatedTableName?;
    string[] TableNames?;
};

# Represents the response of CreateTable operation.
#
# + TableDescription - The table description.
public type TableCreateResponse record {
    TableDescription TableDescription;
};

# Represents the response of DeleteTable operation.
#
# + TableDescription - The table description.
public type TableDeleteResponse record {
    TableDescription TableDescription;
};

# Represents the response of UpdateTable operation.
#
# + TableDescription - The table description.
public type TableUpdateResponse record {
    TableDescription TableDescription;
};

# Represents the response of DescribeTable operation.
#
# + Table - The table description.
public type TableDescribeResponse record {
    TableDescription Table;
};

# Represents the request payload to create table.
#
# + AttributeDefinitions - An array of attributes that describe the key schema for the table and indexes
# + KeySchema - Speciﬁes the attributes that make up the primary key for a table or an index. The attributes in
#               KeySchema must also be deﬁned in the AttributeDefinitions array.
# + TableName - The name of the table to create
# + BillingMode - Controls how you are charged for read and write throughput and how you manage capacity. Valid Values:
#                 PROVISIONED | PAY_PER_REQUEST
# + GlobalSecondaryIndexes - One or more global secondary indexes (the maximum is 20) to be created on the table
# + LocalSecondaryIndexes - One or more local secondary indexes (the maximum is 5) to be created on the table
# + ProvisionedThroughput - Represents the provisioned throughput settings for a speciﬁed table or index
# + SSESpecification - Represents the settings used to enable server-side encryption  
# + StreamSpecification - The settings for DynamoDB Streams on the table
# + Tags - A list of key-value pairs to label the table
public type TableCreateRequest record {
    AttributeDefinition[] AttributeDefinitions;
    KeySchemaElement[] KeySchema;
    string TableName;
    BillingMode BillingMode?;
    GlobalSecondaryIndex[] GlobalSecondaryIndexes?;
    LocalSecondaryIndex[] LocalSecondaryIndexes?;
    ProvisionedThroughput ProvisionedThroughput?;
    SSESpecification SSESpecification?;
    StreamSpecification StreamSpecification?;
    Tag[] Tags?;
};

# Represents an attribute for describing the key schema for the table and indexes.
#
# + AttributeName - A name for the attribute
# + AttributeType - The data type for the attribute, where: S - the attribute is of type String, N - the attribute is 
#                   of type Number, B - the attribute is of type Binary
public type AttributeDefinition record {
    string AttributeName;
    AttributeType AttributeType;
};

# Represents a single element of a key schema. A key schema speciﬁes the attributes that make up the primary key of a
# table, or the key attributes of an index.
#
# + AttributeName - The name of a key attribute
# + KeyType - The role that this key attribute will assume: HASH - partition key, RANGE - sort key
public type KeySchemaElement record {
    string AttributeName;
    KeyType KeyType;
};

# Represents attributes that are copied (projected) from the table into an index. These are in addition to the primary
# key attributes and index key attributes, which are automatically projected.
#
# + NonKeyAttributes - Represents the non-key attribute names which will be projected into the index
# + ProjectionType - The set of attributes that are projected into the index: KEYS_ONLY - Only the index and primary
#                    keys are projected into the index, INCLUDE - In addition to the attributes described in KEYS_ONLY,
#                    the secondary index will include other non-key attributes that you specify, ALL - All of the table
#                    attributes are projected into the index.
public type Projection record {
    string[]? NonKeyAttributes?;
    ProjectionType? ProjectionType?;
};

# Represents the provisioned throughput settings for a speciﬁed table or index. The settings can be modiﬁed using the
# UpdateTable operation.
#
# + ReadCapacityUnits - The maximum number of strongly consistent reads consumed per second before DynamoDB returns a
#                       `ThrottlingException`
# + WriteCapacityUnits - The maximum number of writes consumed per second before DynamoDB returns a `ThrottlingException`
public type ProvisionedThroughput record {
    int ReadCapacityUnits;
    int WriteCapacityUnits;
};

# Represents the properties of a local secondary index.
#
# + IndexName - The name of the local secondary index. The name must be unique among all other indexes on this table.
# + KeySchema - The complete key schema for the local secondary index, consisting of one or more pairs of attribute 
#               names and key types: HASH - partition key, RANGE - sort key
# + Projection - Represents attributes that are copied (projected) from the table into the local secondary index. These
#                are in addition to the primary key attributes and index key attributes, which are automatically 
#                projected.
public type LocalSecondaryIndex record {
    string IndexName;
    KeySchemaElement[] KeySchema;
    Projection Projection;
};

# Represents the properties of a global secondary index.
#
# + ProvisionedThroughput - Represents the provisioned throughput settings for the speciﬁed global secondary index
public type GlobalSecondaryIndex record {
    *LocalSecondaryIndex;
    ProvisionedThroughput ProvisionedThroughput;
};

# Represents the settings used to enable server-side encryption.
#
# + Enabled - Indicates whether server-side encryption is done using an AWS managed CMK or an AWS owned CMK. If enabled
#             (true), server-side encryption type is set to KMS and an AWS managed CMK is used (AWS KMS charges apply).
#             If disabled (false) or not speciﬁed, server-side encryption is set to AWS owned CMK.
# + KMSMasterKeyId - The AWS KMS customer master key (CMK) that should be used for the AWS KMS encryption. To specify a
#                    CMK, use its key ID, Amazon Resource Name (ARN), alias name, or alias ARN. Note that you should
#                    only provide this parameter if the key is diﬀerent from the default DynamoDB customer master key 
#                    `alias/aws/dynamodb`.
# + SSEType - Server-side encryption type. The only supported value is: KMS - Server-side encryption that uses AWS Key 
#             Management Service. The key is stored in your account and is managed by AWS KMS (AWS KMS charges apply).
public type SSESpecification record {
    boolean? Enabled?;
    string? KMSMasterKeyId?;
    SSEType? SSEType?;
};

# Represents the DynamoDB Streams conﬁguration for a table in DynamoDB.
#
# + StreamEnabled - Indicates whether DynamoDB Streams is enabled (true) or disabled (false) on the table
# + StreamViewType - When an item in the table is modiﬁed, StreamViewType determines what information is written to the
#                    stream for this table. Valid values for StreamViewType are:
#                    KEYS_ONLY - Only the key attributes of the modiﬁed item are written to the stream.
#                    NEW_IMAGE - The entire item, as it appears after it was modiﬁed, is written to the stream.
#                    OLD_IMAGE - The entire item, as it appeared before it was modiﬁed, is written to the stream.
#                    NEW_AND_OLD_IMAGES - Both the new and the old item images of the item are written to the stream.
public type StreamSpecification record {
    boolean StreamEnabled;
    StreamViewType? StreamViewType?;
};

# Describes a tag. A tag is a key-value pair. You can add up to 50 tags to a single DynamoDB table.
#
# + Key - The key of the tag. Tag keys are case sensitive. Each DynamoDB table can only have up to one tag with the same
#         key. If you try to add an existing tag (same key), the existing tag value will be updated to the new value.
# + Value - The value of the tag. Tag values are case-sensitive and can be null.
public type Tag record {
    string Key;
    string? Value;
};

# Contains details of a table archival operation.
#
# + ArchivalBackupArn - The Amazon Resource Name (ARN) of the backup the table was archived to, when applicable in the 
#                       archival reason. If you wish to restore this backup to the same table name, you will need to
#                       delete the original table.
# + ArchivalDateTime - The date and time when table archival was initiated by DynamoDB, in UNIX epoch time format
# + ArchivalReason - The reason DynamoDB archived the table. Currently, the only possible value is:
#                    INACCESSIBLE_ENCRYPTION_CREDENTIALS - The table was archived due to the table's AWS KMS key being
#                    inaccessible for more than seven days. An On-Demand backup was created at the archival time.
public type ArchivalSummary record {
    string? ArchivalBackupArn?;
    int? ArchivalDateTime?;
    string? ArchivalReason?;
};

# Contains the details for the read/write capacity mode.
#
# + BillingMode - Controls how you are charged for read and write throughput and how you manage capacity. This setting
#                 can be changed later.
#                 PROVISIONED - Sets the read/write capacity mode to PROVISIONED. We recommend using PROVISIONED for
#                               predictable workloads.
#                 PAY_PER_REQUEST - Sets the read/write capacity mode to PAY_PER_REQUEST. We recommend using
#                                   PAY_PER_REQUEST for unpredictable workloads.
# + LastUpdateToPayPerRequestDateTime - Represents the time when PAY_PER_REQUEST was last set as the read/write
#                                       capacity mode.
public type BillingModeSummary record {
    BillingMode? BillingMode?;
    int? LastUpdateToPayPerRequestDateTime?;
};

# Represents the properties of a global secondary index.
#
# + Backfilling - Indicates whether the index is currently backﬁlling
# + IndexStatus - The current state of the global secondary index: CREATING - The index is being created, UPDATING - The 
#                 index is being updated, DELETING - The index is being deleted, ACTIVE - The index is ready for use.
# + ProvisionedThroughput - Represents the provisioned throughput settings for the speciﬁed global secondary index
public type GlobalSecondaryIndexDescription record {
    *LocalSecondaryIndexDescription;
    boolean? Backfilling?;
    IndexStatus? IndexStatus?;
    ProvisionedThroughput? ProvisionedThroughput?;
};

# Represents the properties of a local secondary index.
#
# + IndexArn - The Amazon Resource Name (ARN) that uniquely identiﬁes the index
# + IndexName - Represents the name of the local secondary index
# + IndexSizeBytes - The total size of the speciﬁed index, in bytes. DynamoDB updates this value approximately every
#                    six hours. Recent changes might not be reﬂected in this value.
# + ItemCount - The number of items in the speciﬁed index. DynamoDB updates this value approximately every six hours.
#               Recent changes might not be reﬂected in this value.
# + KeySchema - The complete key schema for the local secondary index, consisting of one or more pairs of attribute
#               names and key types: HASH - partition key, RANGE - sort key
# + Projection - Represents attributes that are copied (projected) from the table into the global secondary index. These
#                are in addition to the primary key attributes and index key attributes, which are automatically 
#                projected.
public type LocalSecondaryIndexDescription record {
    string? IndexArn?;
    string? IndexName?;
    int? IndexSizeBytes?;
    int? ItemCount?;
    KeySchemaElement[]? KeySchema?;
    Projection? Projection?;
};

# Represents the provisioned throughput settings for the table, consisting of read and write capacity units, along with
# data about increases and decreases.
#
# + LastDecreaseDateTime - The date and time of the last provisioned throughput decrease for this table
# + LastIncreaseDateTime - The date and time of the last provisioned throughput increase for this table
# + NumberOfDecreasesToday - The number of provisioned throughput decreases for this table during this UTC calendar day
# + ReadCapacityUnits - The maximum number of strongly consistent reads consumed per second before DynamoDB returns a
#                       `ThrottlingException`
# + WriteCapacityUnits - The maximum number of writes consumed per second before DynamoDB returns a `ThrottlingException`
public type ProvisionedThroughputDescription record {
    int? LastDecreaseDateTime?;
    int? LastIncreaseDateTime?;
    int? NumberOfDecreasesToday?;
    int? ReadCapacityUnits?;
    int? WriteCapacityUnits?;
};

# Replica-speciﬁc provisioned throughput settings. If not speciﬁed, uses the source table's provisioned throughput
# settings.
#
# + ReadCapacityUnits - Replica-speciﬁc read capacity units. If not speciﬁed, uses the source table's read capacity
#                       settings.
public type ProvisionedThroughputOverride record {
    int? ReadCapacityUnits?;
};

# Represents the properties of a replica global secondary index.
#
# + IndexName - The name of the global secondary index
# + ProvisionedThroughputOverride - If not described, uses the source table GSI's read capacity settings
public type ReplicaGlobalSecondaryIndexDescription record {
    string? IndexName?;
    ProvisionedThroughputOverride? ProvisionedThroughputOverride?;
};

# Contains the details of the replica.
#
# + GlobalSecondaryIndexes - Replica-speciﬁc global secondary index settings
# + KMSMasterKeyId - The AWS KMS customer master key (CMK) of the replica that will be used for AWS KMS encryption
# + ProvisionedThroughputOverride - Replica-speciﬁc provisioned throughput. If not described, uses the source table's
#                                   provisioned throughput settings.
# + RegionName - The name of the Region
# + ReplicaInaccessibleDateTime - The time at which the replica was ﬁrst detected as inaccessible. To determine cause
#                                 of inaccessibility check the ReplicaStatus property.
# + ReplicaStatus - The current state of the replica. Valid Values: CREATING | CREATION_FAILED | UPDATING | DELETING |
#                   ACTIVE | REGION_DISABLED | INACCESSIBLE_ENCRYPTION_CREDENTIALS.
# + ReplicaStatusDescription - Detailed information about the replica status
# + ReplicaStatusPercentProgress - Speciﬁes the progress of a Create, Update, or Delete action on the replica as a percentage
public type ReplicaDescription record {
    ReplicaGlobalSecondaryIndexDescription[]? GlobalSecondaryIndexes?;
    string? KMSMasterKeyId?;
    ProvisionedThroughputOverride? ProvisionedThroughputOverride?;
    string? RegionName?;
    int? ReplicaInaccessibleDateTime?;
    ReplicaStatus? ReplicaStatus?;
    string? ReplicaStatusDescription?;
    string? ReplicaStatusPercentProgress?;
};

# Contains details for the restore.
#
# + RestoreDateTime - Point in time or source backup time
# + RestoreInProgress - Indicates if a restore is in progress or not
# + SourceBackupArn - The Amazon Resource Name (ARN) of the backup from which the table was restored
# + SourceTableArn - The ARN of the source table of the backup that is being restored
public type RestoreSummary record {
    int RestoreDateTime;
    boolean RestoreInProgress;
    string? SourceBackupArn?;
    string? SourceTableArn?;
};

# The description of the server-side encryption status on the speciﬁed table.
#
# + InaccessibleEncryptionDateTime - Indicates the time, in UNIX epoch date format, when DynamoDB detected that the
#                                    table's AWS KMS key was inaccessible
# + KMSMasterKeyArn - The AWS KMS customer master key (CMK) ARN used for the AWS KMS encryption
# + SSEType - Server-side encryption type. The only supported value is: KMS - Server-side encryption that uses AWS Key
#             Management Service. The key is stored in your account and is managed by AWS KMS (AWS KMS charges apply).
# + Status - Represents the current state of server-side encryption. The only supported values are: 
#            ENABLED - Server-side encryption is enabled, UPDATING - Server-side encryption is being updated.
public type SSEDescription record {
    int? InaccessibleEncryptionDateTime?;
    string? KMSMasterKeyArn?;
    SSEType? SSEType?;
    Status? Status?;
};

# Represents the properties of a table.
#
# + ArchivalSummary - Contains information about the table archive
# + AttributeDefinitions - An array of AttributeDefinition objects. Each of these objects describes one attribute in 
#                          the table and index key schema.
# + BillingModeSummary - Contains the details for the read/write capacity mode
# + CreationDateTime - The date and time when the table was created, in UNIX epoch time format
# + GlobalSecondaryIndexes - The global secondary indexes, if any, on the table. Each index is scoped to a given
#                            partition key value.
# + GlobalTableVersion - Represents the version of global tables in use, if the table is replicated across AWS Regions
# + ItemCount - The number of items in the speciﬁed table
# + KeySchema - The primary key structure for the table
# + LatestStreamArn - The Amazon Resource Name (ARN) that uniquely identiﬁes the latest stream for this table
# + LatestStreamLabel - A timestamp, in ISO 8601 format, for this stream
# + LocalSecondaryIndexes - Represents one or more local secondary indexes on the table
# + ProvisionedThroughput - The provisioned throughput settings for the table, consisting of read and write capacity
#                           units, along with data about increases and decreases
# + Replicas - Represents replicas of the table
# + RestoreSummary - Contains details for the restore
# + SSEDescription - The description of the server-side encryption status on the speciﬁed table
# + StreamSpecification - The current DynamoDB Streams conﬁguration for the table
# + TableArn - The Amazon Resource Name (ARN) that uniquely identiﬁes the table
# + TableId - Unique identiﬁer for the table for which the backup was created
# + TableName - The name of the table
# + TableSizeBytes - The total size of the speciﬁed table, in bytes
# + TableStatus - The current state of the table. Valid Values: CREATING | UPDATING | DELETING | ACTIVE | 
#                 INACCESSIBLE_ENCRYPTION_CREDENTIALS | ARCHIVING | ARCHIVED
public type TableDescription record {
    ArchivalSummary? ArchivalSummary?;
    AttributeDefinition[]? AttributeDefinitions?;
    BillingModeSummary? BillingModeSummary?;
    int? CreationDateTime?;
    GlobalSecondaryIndexDescription[]? GlobalSecondaryIndexes?;
    string? GlobalTableVersion?;
    int? ItemCount?;
    KeySchemaElement[]? KeySchema?;
    string? LatestStreamArn?;
    string? LatestStreamLabel?;
    LocalSecondaryIndexDescription[]? LocalSecondaryIndexes?;
    ProvisionedThroughputDescription? ProvisionedThroughput?;
    ReplicaDescription[]? Replicas?;
    RestoreSummary? RestoreSummary?;
    SSEDescription? SSEDescription?;
    StreamSpecification? StreamSpecification?;
    string? TableArn?;
    string? TableId?;
    string? TableName?;
    int? TableSizeBytes?;
    TableStatus? TableStatus?;
};

# Represents a new global secondary index to be added to an existing table.
#
# + IndexName - The name of the global secondary index to be created
# + KeySchema - The key schema for the global secondary index
# + Projection - Represents attributes that are copied (projected) from the table into an index
# + ProvisionedThroughput - Represents the provisioned throughput settings for the speciﬁed global secondary index
public type CreateGlobalSecondaryIndexAction record {
    string IndexName;
    KeySchemaElement[] KeySchema;
    Projection Projection;
    ProvisionedThroughput? ProvisionedThroughput?;
};

# Represents a global secondary index to be deleted from an existing table.
#
# + IndexName - The name of the global secondary index to be deleted
public type DeleteGlobalSecondaryIndexAction record {
    string IndexName;
};

# Represents the new provisioned throughput settings to be applied to a global secondary index.
#
# + IndexName - The name of the global secondary index to be updated
# + ProvisionedThroughput - Represents the provisioned throughput settings for the speciﬁed global secondary index
public type UpdateGlobalSecondaryIndexAction record {
    string IndexName;
    ProvisionedThroughput ProvisionedThroughput;
};

# Represents one of the following: A new global secondary index to be added to an existing table, New provisioned
# throughput parameters for an existing global secondary index, An existing global secondary index to be removed from
# an existing table.
#
# + Create - The parameters required for creating a global secondary index on an existing table
# + Delete - The name of an existing global secondary index to be removed
# + Update - The name of an existing global secondary index, along with new provisioned throughput settings to be
#            applied to that index
public type GlobalSecondaryIndexUpdate record {
    CreateGlobalSecondaryIndexAction? Create?;
    DeleteGlobalSecondaryIndexAction? Delete?;
    UpdateGlobalSecondaryIndexAction? Update?;
};

# Represents the properties of a replica global secondary index.
#
# + IndexName - The name of the global secondary index
# + ProvisionedThroughputOverride - Replica table GSI-speciﬁc provisioned throughput. If not speciﬁed, uses the source
#                                   table GSI's read capacity settings.
public type ReplicaGlobalSecondaryIndex record {
    string IndexName;
    ProvisionedThroughputOverride? ProvisionedThroughputOverride?;
};

# Represents a replica to be created.
#
# + RegionName - The Region where the new replica will be created
# + GlobalSecondaryIndexes - Replica-speciﬁc global secondary index settings
# + KMSMasterKeyId - The AWS KMS customer master key (CMK) that should be used for AWS KMS encryption in the new replica
# + ProvisionedThroughputOverride - Replica-speciﬁc provisioned throughput. If not speciﬁed, uses the source table's
#                                   provisioned throughput settings.
public type CreateReplicationGroupMemberAction record {
    string RegionName;
    ReplicaGlobalSecondaryIndex[]? GlobalSecondaryIndexes?;
    string? KMSMasterKeyId?;
    ProvisionedThroughputOverride? ProvisionedThroughputOverride?;
};

# Represents a replica to be deleted.
#
# + RegionName - The Region where the replica exists
public type DeleteReplicationGroupMemberAction record {
    string RegionName;
};

# Represents a replica to be modiﬁed.
public type UpdateReplicationGroupMemberAction record {
    *CreateReplicationGroupMemberAction;
};

# Represents one of the following: A new replica to be added to an existing regional table or global table. This request
# invokes the CreateTableReplica action in the destination Region, New parameters for an existing replica. This request
# invokes the UpdateTable action in the destination Region. An existing replica to be deleted. The request invokes the
# DeleteTableReplica action in the destination Region, deleting the replica and all if its items in the destination
# Region.
#
# + Create - The parameters required for creating a replica for the table
# + Delete - The parameters required for deleting a replica for the table
# + Update - The parameters required for updating a replica for the table
public type ReplicationGroupUpdate record {
    CreateReplicationGroupMemberAction? Create?;
    DeleteReplicationGroupMemberAction? Delete?;
    UpdateReplicationGroupMemberAction? Update?;
};

# Represents the data for an attribute. Each attribute value is described as a name-value pair. The name is the data
# type, and the value is the data itself.
#
# + B - An attribute of type Binary
# + BOOL - An attribute of type Boolean
# + BS - An attribute of type Binary Set
# + L - An attribute of type List
# + M - An attribute of type Map
# + N - An attribute of type Number
# + NS - An attribute of type Number Set
# + NULL - An attribute of type Null
# + S - An attribute of type String
# + SS - An attribute of type String Set
public type AttributeValue record {
    // Data types of Binary and Binary Set may be need to revise.
    string? B? ;
    boolean? BOOL?;
    string[]? BS?;
    AttributeValue[]? L?;
    map<AttributeValue>? M?;
    string? N?;
    string[]? NS?;
    boolean? NULL?;
    string? S?;
    string[]? SS?;
};

# Represents a condition to be compared with an attribute value
#
# + AttributeValueList - One or more values to evaluate against the supplied attribute
# + ComparisonOperator - A comparator for evaluating attributes in the AttributeValueList. Valid Values: EQ | NE | IN |
#                        LE | LT | GE | GT | BETWEEN | NOT_NULL | NULL | CONTAINS | NOT_CONTAINS | BEGINS_WITH
# + Exists - Causes DynamoDB to evaluate the value before attempting a conditional operation
# + Value - Represents the data for the expected attribute
public type ExpectedAttributeValue record {
    AttributeValue[]? AttributeValueList?;
    ComparisonOperator? ComparisonOperator?;
    boolean? Exists?;
    AttributeValue? Value?;
};

# Represents the amount of provisioned throughput capacity consumed on a table or an index.
#
# + CapacityUnits - The total number of capacity units consumed on a table or an index
# + ReadCapacityUnits - The total number of read capacity units consumed on a table or an index
# + WriteCapacityUnits - The total number of write capacity units consumed on a table or an index
public type Capacity record {
    float? CapacityUnits?;
    float? ReadCapacityUnits?;
    float? WriteCapacityUnits?;
};

# The capacity units consumed by an operation. The data returned includes the total provisioned throughput consumed,
# along with statistics for the table and any indexes involved in the operation.
#
# + CapacityUnits - The total number of capacity units consumed by the operation
# + GlobalSecondaryIndexes - The amount of throughput consumed on each global index aﬀected by the operation
# + LocalSecondaryIndexes - The amount of throughput consumed on each local index aﬀected by the operation
# + ReadCapacityUnits - The total number of read capacity units consumed by the operation
# + Table - The amount of throughput consumed on the table aﬀected by the operation
# + TableName - The name of the table that was aﬀected by the operation
# + WriteCapacityUnits - The total number of write capacity units consumed by the operation
public type ConsumedCapacity record {
    float? CapacityUnits?;
    map<Capacity>? GlobalSecondaryIndexes?;
    map<Capacity>? LocalSecondaryIndexes?;
    float? ReadCapacityUnits?;
    Capacity? Table?;
    string? TableName?;
    float? WriteCapacityUnits?;
};

# Information about item collections, if any, that were aﬀected by the operation.
#
# + ItemCollectionKey - The partition key value of the item collection. This value is the same as the partition key
#                       value of the item.
# + SizeEstimateRangeGB - An estimate of item collection size, in gigabytes. This value is a two-element array
#                         containing a lower bound and an upper bound for the estimate. The estimate includes the size
#                         of all the items in the table, plus the size of all attributes projected into all of the local
#                         secondary indexes on that table. Use this estimate to measure whether a local secondary index
#                         is approaching its size limit.
public type ItemCollectionMetrics record {
    map<AttributeValue>? ItemCollectionKey?;
    float[]? SizeEstimateRangeGB?;
};

# For the UpdateItem operation, represents the attributes to be modiﬁed, the action to perform on each, and the new
# value for each.
#
# + Action - Speciﬁes how to perform the update. Valid values are PUT (default), DELETE, and ADD. The behavior depends
#            on whether the speciﬁed primary key already exists in the table.
# + Value - Represents the data for an attribute
public type AttributeValueUpdate record {
    Action? Action?;
    AttributeValue? Value?;
};

# Represents the selection criteria for a Query or Scan operation. For a Query operation, Condition is used for
# specifying the KeyConditions to use when querying table or an index. For KeyConditions, only the following comparison
# operators are supported: EQ | LE | LT | GE | GT | BEGINS_WITH | BETWEEN. For a Scan operation, Condition is used in a
# ScanFilter, which evaluates the scan results and returns only the desired values
#
# + ComparisonOperator - A comparator for evaluating attributes. Valid Values: EQ | NE | IN | LE | LT | GE | GT |
#                        BETWEEN | NOT_NULL | NULL | CONTAINS | NOT_CONTAINS | BEGINS_WITH
# + AttributeValueList - One or more values to evaluate against the supplied attribute. The number of values in the list
#                        depends on the ComparisonOperator being used.
public type Condition record {
    ComparisonOperator ComparisonOperator;
    AttributeValue[]? AttributeValueList?;
};

# Represents a set of primary keys and, for each key, the attributes to retrieve from the table.
#
# + Keys - The primary key attribute values that deﬁne the items and the attributes associated with the items
# + AttributesToGet - This is a legacy parameter. Use ProjectionExpression instead.
# + ConsistentRead - The consistency of a read operation. If set to true, then a strongly consistent read is used; 
#                    otherwise, an eventually consistent read is used.
# + ExpressionAttributeNames - One or more substitution tokens for attribute names in an expression
# + ProjectionExpression - A string that identiﬁes one or more attributes to retrieve from the table
public type KeysAndAttributes record {
    map<AttributeValue>[] Keys;
    string[]? AttributesToGet?;
    boolean? ConsistentRead?;
    map<string>? ExpressionAttributeNames?;
    string? ProjectionExpression?;
};

# Represents a request to perform a DeleteItem operation on an item.
#
# + Key - A map of attribute name to attribute values, representing the primary key of the item to delete. All of the
#         table's primary key attributes must be speciﬁed, and their data types must match those of the table's key
#         schema.
public type DeleteRequest record {
    map<AttributeValue> Key;
};

# Represents a request to perform a PutItem operation on an item.
#
# + Item - A map of attribute name to attribute values, representing the primary key of an item to be processed by 
#          `PutItem`. All of the table's primary key attributes must be speciﬁed, and their data types must match those
#           of the table's key schema. If any attributes are present in the item that are part of an index key schema
#           for the table, their types must match the index key schema.
public type PutRequest record {
    map<AttributeValue> Item;
};

# Represents an operation to perform - either DeleteItem or PutItem. You can only request one of these operations, not
# both, in a single WriteRequest. If you do need to perform both of these operations, you need to provide two separate
# WriteRequest objects.
#
# + DeleteRequest - A request to perform a DeleteItem operation
# + PutRequest - A request to perform a PutItem operation
public type WriteRequest record {
    DeleteRequest? DeleteRequest?;
    PutRequest? PutRequest?;
};
