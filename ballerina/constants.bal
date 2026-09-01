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

// The endpoint prefix of the DynamoDB service, used both to resolve the endpoint URL
// (e.g. `dynamodb.us-east-1.amazonaws.com`) and as the SigV4 signing name.
const string SERVICE_NAME = "dynamodb";

// The DynamoDB API version, used as the `x-amz-target` prefix.
const string API_VERSION = "DynamoDB_20120810";

const string TARGET_BATCH_GET_ITEM = API_VERSION + ".BatchGetItem";
const string TARGET_BATCH_WRITE_ITEM = API_VERSION + ".BatchWriteItem";
const string TARGET_CREATE_BACKUP = API_VERSION + ".CreateBackup";
const string TARGET_CREATE_TABLE = API_VERSION + ".CreateTable";
const string TARGET_DELETE_BACKUP = API_VERSION + ".DeleteBackup";
const string TARGET_DELETE_ITEM = API_VERSION + ".DeleteItem";
const string TARGET_DELETE_TABLE = API_VERSION + ".DeleteTable";
const string TARGET_DESCRIBE_LIMITS = API_VERSION + ".DescribeLimits";
const string TARGET_DESCRIBE_TABLE = API_VERSION + ".DescribeTable";
const string TARGET_DESCRIBE_TIME_TO_LIVE = API_VERSION + ".DescribeTimeToLive";
const string TARGET_GET_ITEM = API_VERSION + ".GetItem";
const string TARGET_LIST_TABLES = API_VERSION + ".ListTables";
const string TARGET_PUT_ITEM = API_VERSION + ".PutItem";
const string TARGET_QUERY = API_VERSION + ".Query";
const string TARGET_SCAN = API_VERSION + ".Scan";
const string TARGET_UPDATE_ITEM = API_VERSION + ".UpdateItem";
const string TARGET_UPDATE_TABLE = API_VERSION + ".UpdateTable";

const string ROOT_PATH = "/";

// DynamoDB speaks the AWS JSON 1.0 protocol.
const string JSON_CONTENT_TYPE = "application/x-amz-json-1.0";

// Defaults for `BatchRetryConfig`, also used as the fallback when a non-positive value is supplied.
const decimal DEFAULT_BATCH_RETRY_INTERVAL = 0.025;
const decimal DEFAULT_MAX_BATCH_RETRY_INTERVAL = 20;
const int DEFAULT_MAX_UNPRODUCTIVE_BATCH_ATTEMPTS = 8;

const string CONTENT_TYPE_HEADER = "content-type";
const string TARGET_HEADER = "x-amz-target";
const string REQUEST_ID_HEADER = "x-amzn-RequestId";

# Represents the attribute types supported by Amazon DynamoDB.
public enum AttributeType {
    # Represents a string
    S,
    # Represents a number
    N,
    # Represents a binary data 
    B
}

# Represents the key type of an attribute in a DynamoDB table.
# This enum is used in the `KeySchema` of a `TableSchema` to specify the type of the key attribute.
public enum KeyType {
    # Represents the partition key
    HASH, 
    # Represents the sort key
    RANGE
}

# Represents the types of projections that can be used in a DynamoDB query.
public enum ProjectionType {
    KEYS_ONLY,
    # All of the item attributes are projected.
    ALL,
    # Only the specified attributes of the queried item(s) are projected.
    INCLUDE,
    # All of the item attributes are projected except for the specified attributes.
    EXCLUDE
}

# Represents the types of server-side encryption supported by DynamoDB.
public enum SSEType {
    AES256, KMS
}

# Represents the stream view type of a DynamoDB table.
public enum StreamViewType {
    # Returns all of the attributes of the item, as they appear after the UpdateItem operation
    NEW_IMAGE, 
    # Returns all of the attributes of the item, as they appeared before the UpdateItem operation
    OLD_IMAGE, 
    # Returns both the new and the old images of the item
    NEW_AND_OLD_IMAGES,
    # Returns only the key attributes of the item, not the other attributes 
    KEYS_ONLY
}

# Represents the billing mode of a DynamoDB table.
public enum BillingMode {
    # Represents the provisioned throughput mode for a DynamoDB table
    PROVISIONED,
    # Represents the pay-per-request billing mode for DynamoDB
    PAY_PER_REQUEST
}

# Represents the status of an index.
public enum IndexStatus {
    # Represents the state of a DynamoDB table being created
    CREATING, 
    # Represents the state of an update operation in AWS DynamoDB
    UPDATING, 
    # Represents the state of a DynamoDB operation where an item is being deleted
    DELETING, 
    # Represents the status of an item in DynamoDB as active
    ACTIVE
}

# Represents the status of a replica in Amazon DynamoDB.
public enum ReplicaStatus {
    CREATING, CREATION_FAILED,UPDATING, DELETING, ACTIVE, REGION_DISABLED, INACCESSIBLE_ENCRYPTION_CREDENTIALS
}

# Represents the status of a DynamoDB operation.
public enum Status {
    ENABLING, ENABLED, DISABLING, DISABLED, UPDATING
}

# Represents the status of an AWS DynamoDB table.
public enum TableStatus {
    CREATING, UPDATING, DELETING, ACTIVE, INACCESSIBLE_ENCRYPTION_CREDENTIALS, ARCHIVING, ARCHIVED
}

# Represents the comparison operators used in DynamoDB queries.
public enum ComparisonOperator {
    # Equal to
    EQ, 
    # Not equal to
    NE, 
    # In
    IN, 
    # Less than or equal to
    LE, 
    # Less than
    LT,
    # Greater than or equal to 
    GE, 
    # Greater than
    GT, 
    # Between
    BETWEEN,
    # Not null 
    NOT_NULL, 
    # Null
    NULL, 
    # Contains
    CONTAINS,
    # Does not contain 
    NOT_CONTAINS, 
    # Begins with
    BEGINS_WITH
}

# Represents the conditional operator used in DynamoDB operations.
public enum ConditionalOperator {
    AND, OR
}

# Represents the return consumed capacity mode for DynamoDB operations.
public enum ReturnConsumedCapacity {
    # Consistent read with indexes
    INDEXES, 
    # Consistent read with all the provisioned attributes
    TOTAL, 
    # Eventually consistent read
    NONE
}

# Represents the enum for the return item collection metrics in AWS DynamoDB.
public enum ReturnItemCollectionMetrics {
    SIZE,
    NONE
}

# Represents the possible return values of a DynamoDB operation.
public enum ReturnValues {
    NONE, ALL_OLD, UPDATED_OLD, ALL_NEW, UPDATED_NEW
}

# Represents the actions that can be performed on a DynamoDB table.
public enum Action {
    ADD, PUT, DELETE
}

# Represents the SELECT operation in DynamoDB.
public enum Select {
    ALL_ATTRIBUTES, ALL_PROJECTED_ATTRIBUTES, SPECIFIC_ATTRIBUTES, COUNT
}

# Represents the status of a stream.
public enum StreamStatus {
    ENABLING, ENABLED, DISABLING, DISABLED
}

# Represents the event name.
public enum eventName {
    INSERT, MODIFY, REMOVE
}

# Represents the type of shard iterator to be used when reading data from a DynamoDB stream.
public enum ShardIteratorType {
    # Start reading at the last (untrimmed) stream record, which is the oldest record in the 
    # shard. In DynamoDB Streams, there is a 24 hour limit on data retention. Stream records 
    # whose age exceeds this limit are subject to removal (trimming) from the stream
    TRIM_HORIZON, 
    # Start reading just after the most recent stream record in the shard, so that you always 
    # read the most recent data in the shard
    LATEST, 
    # Start reading exactly from the position denoted by a specific sequence number
    AT_SEQUENCE_NUMBER, 
    # Start reading right after the position denoted by a specific sequence number
    AFTER_SEQUENCE_NUMBER
}

# Represents the status of the time to live (TTL) attribute of an item in Amazon DynamoDB.
public enum TimeToLiveStatus {
    ENABLING, DISABLING, ENABLED, DISABLED
}
