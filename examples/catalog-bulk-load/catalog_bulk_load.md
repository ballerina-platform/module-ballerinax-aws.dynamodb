# Catalog Bulk Loader

This use case shows how to move a batch of records into DynamoDB and read them back again — the shape of an
overnight catalog import. It loads a product catalog with `writeBatchItems`, fetches a few products back by
primary key with `getBatchItems`, and then scans the table with a server-side filter.

Three things this example demonstrates are worth calling out:

- **Batch writes are chunked and retried.** `BatchWriteItem` accepts at most 25 requests per call, and can
  decline part of a batch when the table is under load. The example chunks the catalog and feeds whatever comes
  back in `UnprocessedItems` straight back in — it has the same shape as `RequestItems`.
- **Batch reads retry themselves.** `getBatchItems` returns a stream that re-requests any keys DynamoDB reports
  as unprocessed as the stream is consumed, so the caller does not drive that loop.
- **It runs on the default credential provider chain.** There are no access keys in the configuration, so the
  same program runs unchanged on a workstation with `~/.aws/credentials`, and on EC2, ECS or EKS with an
  instance or task role.

## Prerequisites

### 1. Setup AWS account

Refer to the [Setup guide](https://github.com/ballerina-platform/module-ballerinax-aws.dynamodb/blob/main/README.md#setup-guide)
to configure a credential source that the default provider chain can find — a `~/.aws/credentials` profile, the
`AWS_ACCESS_KEY_ID`/`AWS_SECRET_ACCESS_KEY` environment variables, or an instance/task role.

### 2. Create the table

This example expects a table whose partition key is `Sku` (String), and no sort key. Create it in the
[DynamoDB console](https://console.aws.amazon.com/dynamodbv2), or with the `createTable` operation as shown in
the [game scores](../game-scores) example.

The credentials need the `BatchWriteItem`, `BatchGetItem` and `Scan` actions on that table.

### 3. Configuration

Create a `Config.toml` file in the example's root directory and provide your configuration as follows:

```toml
region = "<region>"
tableName = "<table-name>"
```

## Run the example

Execute the following command to run the example:

```bash
bal run
```
