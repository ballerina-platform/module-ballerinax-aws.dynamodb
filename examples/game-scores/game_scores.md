# Mobile Game High Scores

This use case shows how a mobile gaming backend can keep a high-score leaderboard in DynamoDB. The table is keyed
by game and sorted by score within each game, which is what lets the top scores for one game be read with a single
`query` rather than a scan of the whole table.

The example runs the full lifecycle: it creates the table, records a few scores, reads the leaderboard back in
descending order, renames the player holding one of the scores, deletes another score, and then tears the table
down again.

## Prerequisites

### 1. Setup AWS account

Refer to the [Setup guide](https://github.com/ballerina-platform/module-ballerinax-aws.dynamodb/blob/main/README.md#setup-guide)
to obtain the necessary credentials (access key ID, secret access key, region).

The credentials need the `CreateTable`, `DescribeTable`, `DeleteTable`, `PutItem`, `UpdateItem`, `DeleteItem` and
`Query` actions on a table named `HighScores`, which the example creates and deletes for itself.

### 2. Configuration

Create a `Config.toml` file in the example's root directory and provide your AWS account related configurations as
follows:

```toml
accessKeyId = "<access-key-id>"
secretAccessKey = "<secret-access-key>"
region = "<region>"
```

## Run the example

Execute the following command to run the example:

```bash
bal run
```

> **Note:** the example creates a `HighScores` table on the account and deletes it again at the end. If a table of
> that name already exists, `createTable` fails with a `ResourceInUseException`.
