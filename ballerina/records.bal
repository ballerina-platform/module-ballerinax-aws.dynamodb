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

import ballerinax/'client.config;

# Represents the AWS DynamoDB Connector configurations.
@display {label: "Connection Config"}
public type ConnectionConfig record {|
    *config:ConnectionConfig;
    never auth?;
    # AWS credentials
    AwsCredentials|AwsTemporaryCredentials awsCredentials;
    # AWS Region
    string region;
|};

# Represents AWS credentials.
#
# + accessKeyId - AWS access key  
# + secretAccessKey - AWS secret key
public type AwsCredentials record {
    string accessKeyId;
    @display {
        label: "",
        kind: "password"
    }
    string secretAccessKey;
};

# Represents AWS temporary credentials.
public type AwsTemporaryCredentials record {
    # AWS access key 
    string accessKeyId;
    # AWS secret key 
    @display {
        label: "",
        kind: "password"
    }
    string secretAccessKey;
    # AWS secret token
    @display {
        label: "",
        kind: "password"
    }
    string securityToken;
};

# Describes the current provisioned-capacity quotas for your AWS account in a Region, both for the Region as a whole and
# for any one DynamoDB table that you create there.
public type LimitDescription record {
    # The maximum total read capacity units that your account allows you to provision across all of your tables in this Region
    int? accountMaxReadCapacityUnits?;
    # The maximum total write capacity units that your account allows you to provision across all of your tables in this Region
    int? accountMaxWriteCapacityUnits?;
    # The maximum read capacity units that your account allows you to provision for a new table that you are creating in this Region, including the read capacity units
    int? tableMaxReadCapacityUnits?;
    # The maximum write capacity units that your account allows you to provision for a new table that you are creating in this Region, including the write capacity units
    # provisioned for its global secondary  indexes (GSIs).
    int? tableMaxWriteCapacityUnits?;
};

# Represents the response after `WriteBatchItem` operation.
public type BatchItemInsertOutput record {
    # The capacity units consumed by the entire `BatchWriteItem` operation
    ConsumedCapacity[]? consumedCapacity?;
    # A list of tables that were processed by `BatchWriteItem` and, for each table, information about
    # any item collections that were aﬀected by individual `DeleteItem` or  `PutItem` operations.
    map<ItemCollectionMetrics[]>? itemCollectionMetrics?;
    # A map of tables and requests against those tables that were not processed. The `UnprocessedItems`
    # value is in the same form as `RequestItems`, so you can provide this value directly to a subsequent
    # `BatchGetItem` operation.
    map<WriteRequest[]>? unprocessedItems?;
};

# Represents the request payload `BatchWriteItem` operation.
public type BatchItemInsertInput record {|
    # A map of one or more table names and, for each table, a list of operations to be performed
    # (DeleteRequest or PutRequest)
    map<WriteRequest[]> requestItems;
    # Determines the level of detail about provisioned throughput consumption that is returned
    # in the response. Valid Values: INDEXES | TOTAL | NONE
    ReturnConsumedCapacity returnConsumedCapacity?;
    # Determines whether item collection metrics are returned. Valid Values: SIZE | NONE
    ReturnItemCollectionMetrics returnItemCollectionMetrics?;
|};

# Represents the response after `BatchGetItem` operation, so the value can be provided directly to a subsequent `BatchGetItem` operation.
type BatchGetItemsOutput record {
    # The read capacity units consumed by the entire BatchGetItem operation
    ConsumedCapacity[]? consumedCapacity?;
    # A map of table name to a list of items. Each object in Responses consists of a table name, along with a
    # map of attribute data consisting of the data type and attribute value
    map<map<AttributeValue>[]>? responses?;
    # A map of tables and their respective keys that were not processed with the current response. The
    # `UnprocessedKeys` value is in the same form as `RequestItems`, so the value can be provided
    # directly to a subsequent `BatchGetItem` operation
    map<KeysAndAttributes>? unprocessedKeys?;
};

# Represents ItemByBatchGet
public type BatchItem record {
    # The read capacity units consumed by the entire BatchGetItem operation
    ConsumedCapacity? consumedCapacity?;
    # The name of the table containing the requested item
    string? tableName?;
    # The requested item
    map<AttributeValue>? item?;
};

# Represents the request payload for a `BatchGetItem` operation.
public type BatchItemGetInput record {|
    # A map of one or more table names and, for each table, a map that describes one or more items to
    # retrieve from that table
    map<KeysAndAttributes> requestItems;
    # Determines the level of detail about provisioned throughput consumption that is returned in
    # the response. Valid Values: INDEXES | TOTAL | NONE
    ReturnConsumedCapacity returnConsumedCapacity?;
|};

# Represents the request payload for `Scan` Operation.
public type ScanInput record {|
    # The name of the table containing the requested items; or, if you provide IndexName, the name of the
    # table to which that index belongs
    string tableName;
    # This is a legacy parameter. Use ProjectionExpression instead
    string[] attributesToGet?;
    # This is a legacy parameter. Use FilterExpression instead. Valid Values: AND | OR
    ConditionalOperator conditionalOperator?;
    # A Boolean value that determines the read consistency model during the scan
    boolean consistentRead?;
    # The primary key of the ﬁrst item that this operation will evaluate. Use the value that was
    # returned for `LastEvaluatedKey` in the previous operation
    map<AttributeValue>? exclusiveStartKey?;
    # One or more substitution tokens for attribute names in an expression
    map<string> expressionAttributeNames?;
    # One or more values that can be substituted in an expression
    map<AttributeValue> expressionAttributeValues?;
    # A string that contains conditions that DynamoDB applies after the Scan operation, but before the
    # data is returned to you. Items that do not satisfy the FilterExpression criteria are not returned
    string filterExpression?;
    # The name of a secondary index to scan. This index can be any local secondary index or global secondary
    # index. Note that if you use the IndexName parameter, you must also provide TableName
    string indexName?;
    # The maximum number of items to evaluate (not necessarily the number of matching items)
    int 'limit?;
    # A string that identiﬁes one or more attributes to retrieve from the speciﬁed table or index
    string projectionExpression?;
    # Determines the level of detail about provisioned throughput consumption that is returned in
    # the response. Valid Values: INDEXES | TOTAL | NONE
    ReturnConsumedCapacity returnConsumedCapacity?;
    # This is a legacy parameter. Use FilterExpression instead
    map<Condition> scanFilter?;
    # For a parallel Scan request, Segment identiﬁes an individual segment to be scanned by an application
    # worker
    int segment?;
    # The attributes to be returned in the result. Valid Values: ALL_ATTRIBUTES | ALL_PROJECTED_ATTRIBUTES |
    # SPECIFIC_ATTRIBUTES |COUNT
    Select 'select?;
    # For a parallel Scan request, TotalSegments represents the total number of segments into which the
    # Scan operation will be divided
    int totalSegments?;
|};

# Represents the response of Query operation.
public type QueryOutput record {
    # The capacity units consumed by the Query operation
    ConsumedCapacity? consumedCapacity?;
    # An Item that match the query criteria. It consists of an attribute name and the value for that attribute
    map<AttributeValue>? item?;
};

# Reperesents the response of Scan operation.
public type ScanOutput record {
    # The capacity units consumed by the Scan operation
    ConsumedCapacity? consumedCapacity?;
    # An Item that match the scan criteria. It consists of an attribute name and the value for that attribute
    map<AttributeValue>? item?;
};

type QueryOrScanOutput record {
    ConsumedCapacity? consumedCapacity?;
    int? count?;
    map<AttributeValue>[]? items?;
    map<AttributeValue>? lastEvaluatedKey?;
    int? scannedCount?;
};

# Represents the request payload for `Query` Operation.
public type QueryInput record {|
    # The name of the table containing the requested items
    string tableName;
    # This is a legacy parameter. Use ProjectionExpression instead
    string[] attributesToGet?;
    # This is a legacy parameter. Use FilterExpression instead. Valid Values: AND | OR
    ConditionalOperator conditionalOperator?;
    # Determines the read consistency model: If set to true, then the operation uses strongly consistent
    # reads; otherwise, the operation uses eventually consistent reads
    boolean consistentRead?;
    # The primary key of the ﬁrst item that this operation will evaluate
    map<AttributeValue>? exclusiveStartKey?;
    # One or more substitution tokens for attribute names in an expression
    map<string> expressionAttributeNames?;
    # One or more values that can be substituted in an expression
    map<AttributeValue> expressionAttributeValues?;
    # A string that contains conditions that DynamoDB applies after the Query operation, but before the
    # data is returned to you. Items that do not satisfy the FilterExpression criteria are not returned
    string filterExpression?;
    # The name of an index to query. This index can be any local secondary index or global secondary index on
    # the table. Note that if you use the IndexName parameter, you must also provide TableName.
    string indexName?;
    # The condition that speciﬁes the key values for items to be retrieved by the Query action
    string keyConditionExpression?;
    # This is a legacy parameter. Use KeyConditionExpression instead
    map<Condition> keyConditions?;
    # The maximum number of items to evaluate (not necessarily the number of matching items)
    int 'limit?;
    # A string that identiﬁes one or more attributes to retrieve from the table
    string projectionExpression?;
    # This is a legacy parameter. Use FilterExpression instead
    map<Condition> queryFilter?;
    # Determines the level of detail about provisioned throughput consumption that is returned in
    # the response. Valid Values: INDEXES | TOTAL | NONE
    ReturnConsumedCapacity returnConsumedCapacity?;
    # Speciﬁes the order for index traversal: If true (default), the traversal is performed in
    # ascending order; if false, the traversal is performed in descending order
    boolean scanIndexForward?;
    # The attributes to be returned in the result. Valid Values: ALL_ATTRIBUTES | ALL_PROJECTED_ATTRIBUTES |
    # SPECIFIC_ATTRIBUTES | COUNT
    Select 'select?;
|};

# Represents the request payload to update an item.
public type ItemUpdateInput record {|
    # The primary key of the item to be updated. Each element consists of an attribute name and a value for that
    # attribute
    map<AttributeValue> 'key;
    # The name of the table containing the item to update
    string tableName;
    # This is a legacy parameter. Use UpdateExpression instead
    map<AttributeValueUpdate> attributeUpdates?;
    # This is a legacy parameter. Use ConditionExpression instead. Valid Values: AND | OR
    ConditionalOperator conditionalOperator?;
    # This is a legacy parameter. Use ConditionExpression instead
    string conditionExpression?;
    # This is a legacy parameter. Use ConditionExpression instead
    map<ExpectedAttributeValue> expected?;
    # One or more substitution tokens for attribute names in an expression
    map<string> expressionAttributeNames?;
    # One or more values that can be substituted in an expression
    map<AttributeValue> expressionAttributeValues?;
    # Determines the level of detail about provisioned throughput consumption that is returned in
    # the response. Valid Values: INDEXES | TOTAL | NONE
    ReturnConsumedCapacity returnConsumedCapacity?;
    # Determines whether item collection metrics are returned. Valid Values: SIZE | NONE
    ReturnItemCollectionMetrics returnItemCollectionMetrics?;
    # Use ReturnValues if you want to get the item attributes as they appear before or after they are
    # updated. Valid Values: NONE | ALL_OLD | UPDATED_OLD | ALL_NEW | UPDATED_NEW
    ReturnValues returnValues?;
    # An expression that deﬁnes one or more attributes to be updated, the action to be performed on
    # them, and new values for them 
    string updateExpression?;
|};

# Represents the request payload to delete an item.
public type ItemDeleteInput record {|
    # A map of attribute names to AttributeValue objects, representing the primary key of the item to delete
    map<AttributeValue> 'key;
    # The name of the table from which to delete the item
    string tableName;
    # This is a legacy parameter. Use ConditionExpression instead. Valid Values: AND | OR
    ConditionalOperator conditionalOperator?;
    # A condition that must be satisﬁed in order for a conditional DeleteItem to succeed
    string conditionExpression?;
    # This is a legacy parameter. Use ConditionExpression instead
    map<ExpectedAttributeValue> expected?;
    # One or more substitution tokens for attribute names in an expression
    map<string> expressionAttributeNames?;
    # One or more values that can be substituted in an expression
    map<AttributeValue> expressionAttributeValues?;
    # Determines the level of detail about provisioned throughput consumption that is returned in
    # the response. Valid Values: INDEXES | TOTAL | NONE
    ReturnConsumedCapacity returnConsumedCapacity?;
    # Determines whether item collection metrics are returned. Valid Values: SIZE | NONE
    ReturnItemCollectionMetrics returnItemCollectionMetrics?;
    # Use ReturnValues if you want to get the item attributes as they appeared before they were deleted.
    # For DeleteItem, the valid values are: NONE | ALL_OLD
    ReturnValues returnValues?;
|};

# Represents the response of `GetItem` operation.
public type ItemGetOutput record {
    # The capacity units consumed by the GetItem operation
    ConsumedCapacity? consumedCapacity?;
    # A map of attribute names to AttributeValue objects, as speciﬁed by ProjectionExpression
    map<AttributeValue>? item?;
};

# Represents the request payload to get an Item.
public type ItemGetInput record {|
    # A map of attribute names to AttributeValue objects, representing the primary key of the item to retrieve
    map<AttributeValue> 'key;
    # The name of the table containing the requested item
    string tableName;
    # This is a legacy parameter. Use ProjectionExpression instead
    string[] attributesToGet?;
    # Determines the read consistency model: If set to true, then the operation uses strongly consistent
    # reads; otherwise, the operation uses eventually consistent reads
    boolean consistentRead?;
    # One or more substitution tokens for attribute names in an expression
    map<string> expressionAttributeNames?;
    # A string that identiﬁes one or more attributes to retrieve from the table
    string projectionExpression?;
    # Determines the level of detail about provisioned throughput consumption that is returned in
    # the response. Valid Values: INDEXES | TOTAL | NONE
    ReturnConsumedCapacity returnConsumedCapacity?;
|};

# Represents the response of PutItem operation.
public type ItemDescription record {
    # The attribute values as they appeared before the PutItem operation, but only if ReturnValues is
    # speciﬁed as ALL_OLD in the request. Each element consists of an attribute name and an attribute value
    map<AttributeValue>? attributes?;
    # The capacity units consumed by the PutItem operation
    ConsumedCapacity? consumedCapacity?;
    # Information about item collections, if any, that were aﬀected by the PutItem operation
    ItemCollectionMetrics? itemCollectionMetrics?;
};

# Represents the request payload to put item.
public type ItemCreateInput record {|
    # A map of attribute name/value pairs, one for each attribute. Only the primary key attributes are required;
    # you can optionally provide other attribute name-value pairs for the item
    map<AttributeValue> item;
    # The name of the table to contain the item
    string tableName;
    # This is a legacy parameter. Use ConditionExpression instead. Valid Values: AND | OR
    ConditionalOperator? conditionalOperator?;
    # A condition that must be satisﬁed in order for a conditional PutItem operation to succeed
    string? conditionExpression?;
    # This is a legacy parameter. Use ConditionExpression instead
    map<ExpectedAttributeValue>? expected?;
    # One or more substitution tokens for attribute names in an expression
    map<string>? expressionAttributeNames?;
    # One or more values that can be substituted in an expression
    map<AttributeValue>? expressionAttributeValues?;
    # Determines the level of detail about provisioned throughput consumption that is returned in
    # the response. Valid Values: INDEXES | TOTAL | NONE
    ReturnConsumedCapacity? returnConsumedCapacity?;
    # Determines whether item collection metrics are returned. Valid Values: SIZE | NONE
    ReturnItemCollectionMetrics? returnItemCollectionMetrics?;
    # Use ReturnValues if you want to get the item attributes as they appeared before they were updated
    # with the PutItem request. For PutItem, the valid values are: NONE | ALL_OLD
    ReturnValues? returnValues?;
|};

# Represents the request payload to update table.
public type TableUpdateInput record {|
    # The name of the table to be updated
    string tableName;
    # An array of attributes that describe the key schema for the table and indexes. If you are
    # adding a new global secondary index to the table, AttributeDefinitions must include the key
    # element(s) of the new index
    AttributeDefinition[] attributeDefinitions?;
    # Controls how you are charged for read and write throughput and how you manage capacity
    BillingMode billingMode?;
    # An array of one or more global secondary indexes for the table
    GlobalSecondaryIndexUpdate[] globalSecondaryIndexUpdates?;
    # The new provisioned throughput settings for the speciﬁed table or index
    ProvisionedThroughput provisionedThroughput?;
    # A list of replica update actions (create, delete, or update) for the table
    ReplicationGroupUpdate[] replicaUpdates?;
    # The new server-side encryption settings for the speciﬁed table
    SSESpecification sseSpecification?;
    # Represents the DynamoDB Streams conﬁguration for the table
    StreamSpecification streamSpecification?;
|};

type TableListRequest record {
    string? exclusiveStartTableName?;
    int? 'limit?;
};

# List of Tables.
public type TableList record {
    # The name of the last table in the current page of results. Use this value as the ExclusiveStartTableName in a new 
    # request to obtain the next page of results, until all the table names are returned
    string lastEvaluatedTableName?;
    # The names of the tables associated with the current account at the current endpoint. The maximum size
    # of this array is 100
    string[] tableNames?;
};

# Represents the request payload to create table.
public type TableCreateInput record {|
    # An array of attributes that describe the key schema for the table and indexes
    AttributeDefinition[] attributeDefinitions;
    # Speciﬁes the attributes that make up the primary key for a table or an index. The attributes in
    # KeySchema must also be deﬁned in the AttributeDefinitions array
    KeySchemaElement[] keySchema;
    # The name of the table to create
    string tableName;
    # Controls how you are charged for read and write throughput and how you manage capacity. Valid Values:
    # PROVISIONED | PAY_PER_REQUEST
    BillingMode billingMode?;
    # One or more global secondary indexes (the maximum is 20) to be created on the table
    GlobalSecondaryIndex[] globalSecondaryIndexes?;
    # One or more local secondary indexes (the maximum is 5) to be created on the table
    LocalSecondaryIndex[] localSecondaryIndexes?;
    # Represents the provisioned throughput settings for a speciﬁed table or index
    ProvisionedThroughput provisionedThroughput?;
    # Represents the settings used to enable server-side encryption
    SSESpecification sseSpecification?;
    # The settings for DynamoDB Streams on the table
    StreamSpecification streamSpecification?;
    # A list of key-value pairs to label the table
    Tag[] tags?;
|};

# Represents an attribute for describing the key schema for the table and indexes.
public type AttributeDefinition record {
    # A name for the attribute
    string attributeName;
    # The data type for the attribute, where: S - the attribute is of type String, N - the attribute is 
    # of type Number, B - the attribute is of type Binary
    AttributeType attributeType;
};

# Represents a single element of a key schema. A key schema speciﬁes the attributes that make up the primary key of a
# table, or the key attributes of an index.
public type KeySchemaElement record {
    # The name of a key attribute
    string attributeName;
    # The role that this key attribute will assume: HASH - partition key, RANGE - sort key
    KeyType keyType;
};

# Represents attributes that are copied (projected) from the table into an index. These are in addition to the primary
# key attributes and index key attributes, which are automatically projected.
public type Projection record {
    # Represents the non-key attribute names which will be projected into the index
    string[]? nonKeyAttributes?;
    # The set of attributes that are projected into the index: KEYS_ONLY - Only the index and primary
    # keys are projected into the index, INCLUDE - In addition to the attributes described in KEYS_ONLY,
    # the secondary index will include other non-key attributes that you specify, ALL - All of the table
    # attributes are projected into the index
    ProjectionType? projectionType?;
};

# Represents the provisioned throughput settings for a speciﬁed table or index. The settings can be modiﬁed using the
# UpdateTable operation.
public type ProvisionedThroughput record {
    # The maximum number of strongly consistent reads consumed per second before DynamoDB returns a `ThrottlingException`
    int readCapacityUnits;
    # The maximum number of writes consumed per second before DynamoDB returns a `ThrottlingException`
    int writeCapacityUnits;
};

# Represents the properties of a local secondary index.
public type LocalSecondaryIndex record {
    # The name of the local secondary index. The name must be unique among all other indexes on this table
    string indexName;
    # The complete key schema for the local secondary index, consisting of one or more pairs of attribute 
    # names and key types: HASH - partition key, RANGE - sort key
    KeySchemaElement[] keySchema;
    # Represents attributes that are copied (projected) from the table into the local secondary index. These
    # are in addition to the primary key attributes and index key attributes, which are automatically projected
    Projection projection;
};

# Represents the properties of a global secondary index.
public type GlobalSecondaryIndex record {
    *LocalSecondaryIndex;
    # Represents the provisioned throughput settings for the speciﬁed global secondary index
    ProvisionedThroughput provisionedThroughput;
};

# Represents the settings used to enable server-side encryption.
public type SSESpecification record {
    # Indicates whether server-side encryption is done using an AWS managed CMK or an AWS owned CMK. If enabled
    # (true), server-side encryption type is set to KMS and an AWS managed CMK is used (AWS KMS charges apply).
    # If disabled (false) or not speciﬁed, server-side encryption is set to AWS owned CMK
    boolean? enabled?;
    # The AWS KMS customer master key (CMK) that should be used for the AWS KMS encryption. To specify a
    # CMK, use its key ID, Amazon Resource Name (ARN), alias name, or alias ARN. Note that you should
    # only provide this parameter if the key is diﬀerent from the default DynamoDB customer master key 
    # `alias/aws/dynamodb`
    string? kmsMasterKeyId?;
    # Server-side encryption type. The only supported value is: KMS - Server-side encryption that uses AWS Key 
    # Management Service. The key is stored in your account and is managed by AWS KMS (AWS KMS charges apply)
    SSEType? sseType?;
};

# Represents the DynamoDB Streams conﬁguration for a table in DynamoDB.
public type StreamSpecification record {
    # Indicates whether DynamoDB Streams is enabled (true) or disabled (false) on the table
    boolean streamEnabled;
    # When an item in the table is modiﬁed, StreamViewType determines what information is written to the
    # stream for this table. Valid values for StreamViewType are:
    # KEYS_ONLY - Only the key attributes of the modiﬁed item are written to the stream.
    # NEW_IMAGE - The entire item, as it appears after it was modiﬁed, is written to the stream.
    # OLD_IMAGE - The entire item, as it appeared before it was modiﬁed, is written to the stream.
    # NEW_AND_OLD_IMAGES - Both the new and the old item images of the item are written to the stream
    StreamViewType? streamViewType?;
};

# Describes a tag. A tag is a key-value pair. You can add up to 50 tags to a single DynamoDB table.
public type Tag record {
    # The key of the tag. Tag keys are case sensitive. Each DynamoDB table can only have up to one tag with the same
    # key. If you try to add an existing tag (same key), the existing tag value will be updated to the new value
    string key;
    # The value of the tag. Tag values are case-sensitive and can be null
    string? value;
};

# Contains details of a table archival operation.
public type ArchivalSummary record {
    # The Amazon Resource Name (ARN) of the backup the table was archived to, when applicable in the 
    # archival reason. If you wish to restore this backup to the same table name, you will need to
    # delete the original table
    string? archivalBackupArn?;
    # The date and time when table archival was initiated by DynamoDB, in UNIX epoch time format
    int? archivalDateTime?;
    # The reason DynamoDB archived the table. Currently, the only possible value is:
    # INACCESSIBLE_ENCRYPTION_CREDENTIALS - The table was archived due to the table's AWS KMS key being
    # inaccessible for more than seven days. An On-Demand backup was created at the archival time
    string? archivalReason?;
};

# Contains the details for the read/write capacity mode.
public type BillingModeSummary record {
    # Controls how you are charged for read and write throughput and how you manage capacity. This setting
    # can be changed later.
    # PROVISIONED - Sets the read/write capacity mode to PROVISIONED. We recommend using PROVISIONED for
    # predictable workloads.
    # PAY_PER_REQUEST - Sets the read/write capacity mode to PAY_PER_REQUEST. We recommend using
    # PAY_PER_REQUEST for unpredictable workloads.
    BillingMode? billingMode?;
    # Represents the time when PAY_PER_REQUEST was last set as the read/write capacity mode
    int? lastUpdateToPayPerRequestDateTime?;
};

# Represents the properties of a global secondary index.
public type GlobalSecondaryIndexDescription record {
    *LocalSecondaryIndexDescription;
    # Indicates whether the index is currently backﬁlling
    boolean? backfilling?;
    # The current state of the global secondary index: CREATING - The index is being created, UPDATING - The 
    # index is being updated, DELETING - The index is being deleted, ACTIVE - The index is ready for use
    IndexStatus? indexStatus?;
    # Represents the provisioned throughput settings for the speciﬁed global secondary index
    ProvisionedThroughput? provisionedThroughput?;
};

# Represents the properties of a local secondary index.
public type LocalSecondaryIndexDescription record {
    # The Amazon Resource Name (ARN) that uniquely identiﬁes the index
    string? indexArn?;
    # Represents the name of the local secondary index
    string? indexName?;
    # The total size of the speciﬁed index, in bytes. DynamoDB updates this value approximately every
    # six hours. Recent changes might not be reﬂected in this value
    int? indexSizeBytes?;
    # The number of items in the speciﬁed index. DynamoDB updates this value approximately every six hours.
    # Recent changes might not be reﬂected in this value
    int? itemCount?;
    # The complete key schema for the local secondary index, consisting of one or more pairs of attribute
    # names and key types: HASH - partition key, RANGE - sort key
    KeySchemaElement[]? keySchema?;
    # Represents attributes that are copied (projected) from the table into the global secondary index. These
    # are in addition to the primary key attributes and index key attributes, which are automatically projected
    Projection? projection?;
};

# Represents the provisioned throughput settings for the table, consisting of read and write capacity units, along with
# data about increases and decreases.
public type ProvisionedThroughputDescription record {
    # The date and time of the last provisioned throughput decrease for this table
    int? lastDecreaseDateTime?;
    # The date and time of the last provisioned throughput increase for this table
    int? lastIncreaseDateTime?;
    # The number of provisioned throughput decreases for this table during this UTC calendar day
    int? numberOfDecreasesToday?;
    # The maximum number of strongly consistent reads consumed per second before DynamoDB returns a `ThrottlingException`
    int? readCapacityUnits?;
    # The maximum number of writes consumed per second before DynamoDB returns a `ThrottlingException`
    int? writeCapacityUnits?;
};

# Replica-speciﬁc provisioned throughput settings. If not speciﬁed, uses the source table's provisioned throughput
# settings.
public type ProvisionedThroughputOverride record {
    # Replica-speciﬁc read capacity units. If not speciﬁed, uses the source table's read capacity settings
    int? readCapacityUnits?;
};

# Represents the properties of a replica global secondary index.
public type ReplicaGlobalSecondaryIndexDescription record {
    # The name of the global secondary index
    string? indexName?;
    # If not described, uses the source table GSI's read capacity settings
    ProvisionedThroughputOverride? provisionedThroughputOverride?;
};

# Contains the details of the replica.
public type ReplicaDescription record {
    # Replica-speciﬁc global secondary index settings
    ReplicaGlobalSecondaryIndexDescription[]? globalSecondaryIndexes?;
    # The AWS KMS customer master key (CMK) of the replica that will be used for AWS KMS encryption
    string? kmsMasterKeyId?;
    # Replica-speciﬁc provisioned throughput. If not described, uses the source table's provisioned throughput settings
    ProvisionedThroughputOverride? provisionedThroughputOverride?;
    # The name of the Region
    string? regionName?;
    # The time at which the replica was ﬁrst detected as inaccessible. To determine cause of inaccessibility check the ReplicaStatus property
    int? replicaInaccessibleDateTime?;
    # The current state of the replica. Valid Values: CREATING | CREATION_FAILED | UPDATING | DELETING |
    # ACTIVE | REGION_DISABLED | INACCESSIBLE_ENCRYPTION_CREDENTIALS
    ReplicaStatus? replicaStatus?;
    # Detailed information about the replica status
    string? replicaStatusDescription?;
    # Speciﬁes the progress of a Create, Update, or Delete action on the replica as a percentage
    string? replicaStatusPercentProgress?;
};

# Contains details for the restore.
public type RestoreSummary record {
    # Point in time or source backup time
    int restoreDateTime;
    # Indicates if a restore is in progress or not
    boolean restoreInProgress;
    # The Amazon Resource Name (ARN) of the backup from which the table was restored
    string? sourceBackupArn?;
    # The ARN of the source table of the backup that is being restored
    string? sourceTableArn?;
};

# The description of the server-side encryption status on the speciﬁed table.
public type SSEDescription record {
    # Indicates the time, in UNIX epoch date format, when DynamoDB detected that the table's AWS KMS key was inaccessible
    int? inaccessibleEncryptionDateTime?;
    # The AWS KMS customer master key (CMK) ARN used for the AWS KMS encryption
    string? kmsMasterKeyArn?;
    # Server-side encryption type. The only supported value is: KMS - Server-side encryption that uses AWS Key
    # Management Service. The key is stored in your account and is managed by AWS KMS (AWS KMS charges apply)
    SSEType? sseType?;
    # Represents the current state of server-side encryption. The only supported values are: 
    # ENABLED - Server-side encryption is enabled, UPDATING - Server-side encryption is being updated
    Status? status?;
};

# Represents the properties of a table.
public type TableDescription record {
    # Contains information about the table archive
    ArchivalSummary? archivalSummary?;
    # An array of AttributeDefinition objects. Each of these objects describes one attribute in 
    # the table and index key schema
    AttributeDefinition[]? attributeDefinitions?;
    # Contains the details for the read/write capacity mode
    BillingModeSummary? billingModeSummary?;
    # The date and time when the table was created, in UNIX epoch time format
    int? creationDateTime?;
    # The global secondary indexes, if any, on the table. Each index is scoped to a given partition key value
    GlobalSecondaryIndexDescription[]? globalSecondaryIndexes?;
    # Represents the version of global tables in use, if the table is replicated across AWS Regions
    string? globalTableVersion?;
    # The number of items in the speciﬁed table
    int? itemCount?;
    # The primary key structure for the table
    KeySchemaElement[]? keySchema?;
    # The Amazon Resource Name (ARN) that uniquely identiﬁes the latest stream for this table
    string? latestStreamArn?;
    # A timestamp, in ISO 8601 format, for this stream
    string? latestStreamLabel?;
    # Represents one or more local secondary indexes on the table
    LocalSecondaryIndexDescription[]? localSecondaryIndexes?;
    # The provisioned throughput settings for the table, consisting of read and write capacity
    # units, along with data about increases and decreases
    ProvisionedThroughputDescription? provisionedThroughput?;
    # Represents replicas of the table
    ReplicaDescription[]? replicas?;
    # Contains details for the restore
    RestoreSummary? restoreSummary?;
    # The description of the server-side encryption status on the speciﬁed table
    SSEDescription? sseDescription?;
    # The current DynamoDB Streams conﬁguration for the table
    StreamSpecification? streamSpecification?;
    # The Amazon Resource Name (ARN) that uniquely identiﬁes the table
    string? tableArn?;
    # Unique identiﬁer for the table for which the backup was created
    string? tableId?;
    # The name of the table
    string? tableName?;
    # The total size of the speciﬁed table, in bytes
    int? tableSizeBytes?;
    # The current state of the table. Valid Values: CREATING | UPDATING | DELETING | ACTIVE | 
    # INACCESSIBLE_ENCRYPTION_CREDENTIALS | ARCHIVING | ARCHIVED
    TableStatus? tableStatus?;
};

# Represents a new global secondary index to be added to an existing table.
public type CreateGlobalSecondaryIndexAction record {
    # The name of the global secondary index to be created
    string indexName;
    # The key schema for the global secondary index
    KeySchemaElement[] keySchema;
    # Represents attributes that are copied (projected) from the table into an index
    Projection projection;
    # Represents the provisioned throughput settings for the speciﬁed global secondary index
    ProvisionedThroughput? provisionedThroughput?;
};

# Represents a global secondary index to be deleted from an existing table.
public type DeleteGlobalSecondaryIndexAction record {
    # The name of the global secondary index to be deleted
    string indexName;
};

# Represents the new provisioned throughput settings to be applied to a global secondary index.
public type UpdateGlobalSecondaryIndexAction record {
    # The name of the global secondary index to be updated
    string indexName;
    # Represents the provisioned throughput settings for the speciﬁed global secondary index
    ProvisionedThroughput provisionedThroughput;
};

# Represents one of the following: A new global secondary index to be added to an existing table, New provisioned
# throughput parameters for an existing global secondary index, An existing global secondary index to be removed from
# an existing table.
public type GlobalSecondaryIndexUpdate record {
    # The parameters required for creating a global secondary index on an existing table
    CreateGlobalSecondaryIndexAction? create?;
    # The name of an existing global secondary index to be removed
    DeleteGlobalSecondaryIndexAction? delete?;
    # The name of an existing global secondary index, along with new provisioned throughput settings to be
    # applied to that index
    UpdateGlobalSecondaryIndexAction? update?;
};

# Represents the properties of a replica global secondary index.
public type ReplicaGlobalSecondaryIndex record {
    # The name of the global secondary index
    string indexName;
    # Replica table GSI-speciﬁc provisioned throughput. If not speciﬁed, uses the source
# table GSI's read capacity settings
    ProvisionedThroughputOverride? provisionedThroughputOverride?;
};

# Represents a replica to be created.
public type CreateReplicationGroupMemberAction record {
    # The Region where the new replica will be created
    string regionName;
    # Replica-speciﬁc global secondary index settings
    ReplicaGlobalSecondaryIndex[]? globalSecondaryIndexes?;
    # The AWS KMS customer master key (CMK) that should be used for AWS KMS encryption in the new replica
    string? kmsMasterKeyId?;
    # Replica-speciﬁc provisioned throughput. If not speciﬁed, uses the source table's
    # provisioned throughput settings
    ProvisionedThroughputOverride? provisionedThroughputOverride?;
};

# Represents a replica to be deleted.
public type DeleteReplicationGroupMemberAction record {
    # The Region where the replica exists
    string regionName;
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
public type ReplicationGroupUpdate record {
    # The parameters required for creating a replica for the table
    CreateReplicationGroupMemberAction? create?;
    # The parameters required for deleting a replica for the table
    DeleteReplicationGroupMemberAction? delete?;
    # The parameters required for updating a replica for the table
    UpdateReplicationGroupMemberAction? update?;
};

# Represents the data for an attribute. Each attribute value is described as a name-value pair. The name is the data
# type, and the value is the data itself.
public type AttributeValue record {
    # An attribute of type Binary
    string? b?;
    # An attribute of type Boolean
    boolean? bool?;
    # An attribute of type Binary Set
    string[]? bs?;
    # An attribute of type List
    AttributeValue[]? l?;
    # An attribute of type Map
    map<AttributeValue>? m?;
    # An attribute of type Number
    string? n?;
    # An attribute of type Number Set
    string[]? ns?;
    # An attribute of type Null
    boolean? 'null?;
    # An attribute of type String
    string? s?;
    # An attribute of type String Set
    string[]? ss?;
};

# Represents a condition to be compared with an attribute value
public type ExpectedAttributeValue record {
    # One or more values to evaluate against the supplied attribute
    AttributeValue[]? attributeValueList?;
    # A comparator for evaluating attributes in the AttributeValueList. Valid Values: EQ | NE | IN |
    # LE | LT | GE | GT | BETWEEN | NOT_NULL | NULL | CONTAINS | NOT_CONTAINS | BEGINS_WITH
    ComparisonOperator? comparisonOperator?;
    # Causes DynamoDB to evaluate the value before attempting a conditional operation
    boolean? exists?;
    # Represents the data for the expected attribute
    AttributeValue? value?;
};

# Represents the amount of provisioned throughput capacity consumed on a table or an index.
public type Capacity record {
    # The total number of capacity units consumed on a table or an index
    float? capacityUnits?;
    # The total number of read capacity units consumed on a table or an index
    float? readCapacityUnits?;
    # The total number of write capacity units consumed on a table or an index
    float? writeCapacityUnits?;
};

# The capacity units consumed by an operation. The data returned includes the total provisioned throughput consumed,
# along with statistics for the table and any indexes involved in the operation.
public type ConsumedCapacity record {
    # The total number of capacity units consumed by the operation
    float? capacityUnits?;
    # The amount of throughput consumed on each global index aﬀected by the operation
    map<Capacity>? globalSecondaryIndexes?;
    # The amount of throughput consumed on each local index aﬀected by the operation
    map<Capacity>? localSecondaryIndexes?;
    # The total number of read capacity units consumed by the operation
    float? readCapacityUnits?;
    # The amount of throughput consumed on the table aﬀected by the operation
    Capacity? 'table?;
    # The name of the table that was aﬀected by the operation
    string? tableName?;
    # The total number of write capacity units consumed by the operation
    float? writeCapacityUnits?;
};

# Information about item collections, if any, that were aﬀected by the operation.
public type ItemCollectionMetrics record {
    # The partition key value of the item collection. This value is the same as the partition key
    # value of the item
    map<AttributeValue>? itemCollectionKey?;
    # An estimate of item collection size, in gigabytes. This value is a two-element array
    # containing a lower bound and an upper bound for the estimate. The estimate includes the size
    # of all the items in the table, plus the size of all attributes projected into all of the local
    # secondary indexes on that table. Use this estimate to measure whether a local secondary index
    # is approaching its size limit
    float[]? sizeEstimateRangeGB?;
};

# For the UpdateItem operation, represents the attributes to be modiﬁed, the action to perform on each, and the new
# value for each.
public type AttributeValueUpdate record {
    # Speciﬁes how to perform the update. Valid values are PUT (default), DELETE, and ADD. The behavior depends
    # on whether the speciﬁed primary key already exists in the table
    Action? action?;
    # Represents the data for an attribute
    AttributeValue? value?;
};

# Represents the selection criteria for a Query or Scan operation. For a Query operation, Condition is used for
# specifying the KeyConditions to use when querying table or an index. For KeyConditions, only the following comparison
# operators are supported: EQ | LE | LT | GE | GT | BEGINS_WITH | BETWEEN. For a Scan operation, Condition is used in a
# ScanFilter, which evaluates the scan results and returns only the desired values
public type Condition record {
    # A comparator for evaluating attributes. Valid Values: EQ | NE | IN | LE | LT | GE | GT |
    # BETWEEN | NOT_NULL | NULL | CONTAINS | NOT_CONTAINS | BEGINS_WITH
    ComparisonOperator comparisonOperator;
    # One or more values to evaluate against the supplied attribute. The number of values in the list
    # depends on the ComparisonOperator being used
    AttributeValue[]? attributeValueList?;
};

# Represents a set of primary keys and, for each key, the attributes to retrieve from the table.
public type KeysAndAttributes record {
    # The primary key attribute values that deﬁne the items and the attributes associated with the items
    map<AttributeValue>[] keys;
    # This is a legacy parameter. Use ProjectionExpression instead
    string[]? attributesToGet?;
    # The consistency of a read operation. If set to true, then a strongly consistent read is used; 
    # otherwise, an eventually consistent read is used
    boolean? consistentRead?;
    # One or more substitution tokens for attribute names in an expression
    map<string>? expressionAttributeNames?;
    # A string that identiﬁes one or more attributes to retrieve from the table
    string? projectionExpression?;
};

# Represents a request to perform a DeleteItem operation on an item.
public type DeleteRequest record {
    # A map of attribute name to attribute values, representing the primary key of the item to delete. All of the
    # table's primary key attributes must be speciﬁed, and their data types must match those of the table's key schema
    map<AttributeValue> 'key;
};

# Represents a request to perform a PutItem operation on an item.
public type PutRequest record {
    # A map of attribute name to attribute values, representing the primary key of an item to be processed by 
    # `PutItem`. All of the table's primary key attributes must be speciﬁed, and their data types must match those
    # of the table's key schema. If any attributes are present in the item that are part of an index key schema
    # for the table, their types must match the index key schema
    map<AttributeValue> item;
};

# Represents an operation to perform - either DeleteItem or PutItem. You can only request one of these operations, not
# both, in a single WriteRequest. If you do need to perform both of these operations, you need to provide two separate
# WriteRequest objects.
public type WriteRequest record {
    # A request to perform a DeleteItem operation
    DeleteRequest? deleteRequest?;
    # A request to perform a PutItem operation
    PutRequest? putRequest?;
};

# Represents an request to perform a CreateBackup operation on a table.
public type BackupCreateInput record {|
    # Name for the backup
    string backupName;
    # Name of the table
    string tableName;
|};

# Contains the details of the backup created for the table.
public type BackupDetails record {
    # ARN associated with the backup
    string backupArn;
    # Time at which the backup was created. This is the request time of the backup
    decimal backupCreationDateTime;
    # Name of the requested backup
    string backupName;
    # Backup can be in one of the following states: CREATING, ACTIVE, DELETED
    string backupStatus;
    # BackupType. One of USER, SYSTEM, AWS_BACKUP
    string backupType;
    # Time at which the automatic on-demand backup created by DynamoDB will expire. This SYSTEM on-demand backup 
    # expires automatically 35 days after its creation
    decimal backupExpiryDateTime?;
    # Size of the backup in bytes. DynamoDB updates this value approximately every six hours. Recent changes might
    #  not be reflected in this value
    decimal backupSizeBytes?;
};

# Represents a response after performing a CreateBackup operation on a table.
public type BackupDescription record {
    # Contains the details of the backup created for the table
    BackupDetails backupDetails?;
    # Contains the details of the table when the backup was created
    SourceTableDetails sourceTableDetails?;
    # Contains the details of the features enabled on the table when the backup was created
    SourceTableFeatureDetails sourceTableFeatureDetails?;
};

# Contains the details of the table when the backup was created.
public type SourceTableDetails record {
    # Schema of the table
    KeySchemaElement[] keySchema?;
    # Read IOPs and Write IOPS on the table when the backup was created
    ProvisionedThroughput provisionedThroughput?;
    # Time when the source table was created
    decimal tableCreationDateTime?;
    # Unique identifier for the table for which the backup was created
    string tableId?;
    # The name of the table for which the backup was created
    string tableName?;
    # Controls how you are charged for read and write throughput and how you manage capacity
    BillingMode billingMode?;
    # Number of items in the table. Note that this is an approximate value
    float itemCount?;
    # ARN of the table for which backup was created
    string tableArn?;
    # Size of the table in bytes. Note that this is an approximate value
    float tableSizeBytes?;
};

# Represents the properties of a global secondary index for the table when the backup was created.
public type GlobalSecondaryIndexInfo record {
    # The name of the global secondary index
    string indexName?;
    # The complete key schema for a global secondary index, which consists of one or more pairs of attribute 
    # names and key types: HASH - partition key and RANGE - sort key
    KeySchemaElement[] keySchema?;
    # Represents attributes that are copied (projected) from the table into the global secondary index
    Projection projection?;
    # Represents the provisioned throughput settings for the specified global secondary index
    ProvisionedThroughput provisionedThroughput?;
};

# Represents the properties of a local secondary index for the table when the backup was created.
public type LocalSecondaryIndexInfo record {
    # The name of the global secondary index
    string indexName?;
    # The complete key schema for a global secondary index, which consists of one or more pairs of attribute names 
    # and key types: HASH - partition key and RANGE - sort key
    KeySchemaElement[] keySchema?;
    # Represents attributes that are copied (projected) from the table into the global secondary index
    Projection projection?;
};

# The description of the Time to Live (TTL) status on the specified table
public type TTLDescription record {
    # The name of the TTL attribute for items in the table
    string attributeName?;
    # The TTL status for the table
    TimeToLiveStatus timeToLiveStatus?;
};

# Contains the details of the features enabled on the table when the backup was created. For example, LSIs, GSIs, 
# streams, TTL.
public type SourceTableFeatureDetails record {
    # Represents the GSI properties for the table when the backup was created. It includes the IndexName, KeySchema, 
    # Projection, and ProvisionedThroughput for the GSIs on the table at the time of backup
    GlobalSecondaryIndexInfo globalSecondaryIndexInfo?;
    # Represents the LSI properties for the table when the backup was created. It includes the IndexName, KeySchema 
    # and Projection for the LSIs on the table at the time of backup
    LocalSecondaryIndexInfo localSecondaryIndexInfo?;
    # The description of the server-side encryption status on the table when the backup was created
    SSEDescription sseDescription?;
    # Stream settings on the table when the backup was created
    StreamSpecification streamSpecification?;
    # Time to Live settings on the table when the backup was created
    TTLDescription timeToLiveDescription?;
};
