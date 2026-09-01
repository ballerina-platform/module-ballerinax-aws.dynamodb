# Examples

The `ballerinax/aws.dynamodb` connector provides practical examples illustrating usage in various scenarios.

1. [Mobile game high scores](game-scores) - Create a table, record scores, read the leaderboard back with a `query`, then update and delete entries before tearing the table down.
2. [Catalog bulk loader](catalog-bulk-load) - Load a product catalogue with `writeBatchItems`, read products back by key with `getBatchItems`, and scan the table with a server-side filter.

## Prerequisites

1. Generate AWS credentials as described in the [Setup guide](../README.md#setup-guide).

2. For each example, create a `Config.toml` file in that example's directory. The two examples authenticate differently, so their configuration differs.

    The [game scores](game-scores) example uses static credentials, and creates and deletes the `HighScores` table for itself:

    ```toml
    accessKeyId = "<AWS_ACCESS_KEY_ID>"
    secretAccessKey = "<AWS_SECRET_ACCESS_KEY>"
    region = "us-east-1"
    ```

    The [catalog bulk loader](catalog-bulk-load) runs on the default credential provider chain, so it takes no keys — it resolves them from the environment, which is what lets the same program run unchanged on EC2, ECS and EKS. It expects a table that already exists, whose partition key is `Sku` (String) and which has no sort key:

    ```toml
    region = "us-east-1"
    tableName = "<TABLE_NAME>"
    ```

## Running an example

Execute the following commands to build an example from the source:

* To build an example:

    ```bash
    bal build
    ```

* To run an example:

    ```bash
    bal run
    ```

## Building the examples with the local module

**Warning**: Because of the absence of support for reading local repositories for single Ballerina files, the bala of
the module is manually written to the central repository as a workaround. Consequently, the bash script may modify your
local Ballerina repositories.

Execute the following commands to build all the examples against the changes you have made to the module locally:

* To build all the examples:

    ```bash
    ./build.sh build
    ```

* To run all the examples:

    ```bash
    ./build.sh run
    ```
