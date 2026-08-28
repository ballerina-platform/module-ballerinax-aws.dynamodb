# Change Log
This file contains all the notable changes done to the Ballerina AWS DynamoDB package through the releases.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/), and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## Unreleased

This release revamps the connector's authentication and region configuration to use the shared
[`ballerinax/aws`](https://github.com/ballerina-platform/module-ballerinax-aws) package, so that all AWS
connectors share a single, consistent credential model.

It contains breaking changes. See the "Migrating from 2.x" section below.

The shapes of the request and response records are unchanged: their fields keep the AWS wire names
(`TableName`, `AttributeDefinitions`, and so on) exactly as in 2.x, and so do the operation names.

### Changed

- **[Breaking]** Credentials are now supplied through a single `ConnectionConfig.auth` field of type
  `auth:AuthConfig`, sourced from `ballerinax/aws.auth` instead of being defined locally by this package.
  In 2.x, credentials were passed as `awsCredentials`, which accepted static keys only. Every 2.x
  credential source remains supported, with six new ones added.
- **[Breaking]** `ConnectionConfig` no longer includes `ballerinax/client.config:ConnectionConfig`. The
  HTTP configuration fields are now declared directly on the record, which additionally makes
  `socketConfig`, `validation` and `laxDataBinding` available.
- **[Breaking]** The `ConnectionConfig.region` field type changed from `string` to `aws:Region|string`.
  This is a widening — plain region strings continue to work, so regions that are not yet present in the
  `aws:Region` enum can still be supplied directly.
- **[Breaking]** Operations now return the module's own `Error` type instead of the generic `error`, and the
  streams they return are typed `stream<T, Error?>` rather than `stream<T, error?>`. Code that binds the
  result to `error` continues to compile; code that declares the stream type explicitly must be updated.
- Temporary credentials (STS assume-role, SSO, container and instance profiles) are now refreshed
  transparently by the credential provider, instead of the connector holding a single set of keys
  resolved at initialization time.
- The package now requires Ballerina distribution `2201.12.0` (was `2201.11.0`).
- The package no longer carries a platform-specific artifact. Request signing was reimplemented on the shared
  `aws.auth` signer.

### Removed

- **[Breaking]** The `ConnectionConfig.awsCredentials` field, and the `AwsCredentials` and
  `AwsTemporaryCredentials` records it accepted, have been removed in favour of `ConnectionConfig.auth`.

### Added

- Support for six additional AWS credential sources, available through `auth:AuthConfig`:
  - `auth:ProfileAuthConfig` — credentials read from a named profile in the shared credentials file.
  - `auth:AssumeRoleConfig` — temporary credentials obtained by assuming an IAM role via AWS STS.
  - `auth:WebIdentityConfig` — web identity (OIDC) federation, including IAM Roles for Service Accounts (IRSA).
  - `auth:SsoAuthConfig` — AWS IAM Identity Center (SSO).
  - `auth:ProcessAuthConfig` — credentials sourced from an external credential process.
  - `auth:DEFAULT_CREDENTIALS` — the AWS default credential provider chain.
- A new optional `ConnectionConfig.endpoint` field of type `aws:EndpointConfig`, for selecting FIPS or
  dualstack endpoint variants and for overriding the endpoint entirely (for example, LocalStack or VPC
  interface endpoints).
- A `Client.close()` method that releases the resources held by the credential provider (background
  refresh threads and any HTTP connections opened for STS/SSO). It is a normal method rather than a
  remote method, since closing the client does not send a request to DynamoDB.
- A `RequestGenerationError` and a `ResponseHandlingError`, distinct subtypes of `Error`, which mark the
  failures that occur either side of the service call: credentials that cannot be resolved or a request
  that cannot be signed, and a response that cannot be read or bound.
- The shared `aws:ErrorDetails` record as the detail of `Error`, so `httpStatusCode`, `httpStatusText`,
  `errorCode`, `errorMessage` and `requestId` are named and typed identically across every revamped AWS
  connector.

### Fixed

- Temporary credentials are now usable. 2.x accepted a `securityToken` on `AwsTemporaryCredentials` but never
  sent it, so every request signed with temporary credentials was rejected by AWS. The session token is now
  part of the signed request.
- Paginated results no longer stop early or panic. `listTables`, `query`, `scan` and `getBatchItems` treated an
  empty page as the end of the result set, and indexed into it unconditionally when a continuation token said
  otherwise — a valid response that DynamoDB does return. The iterators now keep fetching until a page yields a
  value or the result set is genuinely exhausted.
- `getBatchItems` now re-requests only the keys DynamoDB reported as unprocessed. 2.x mutated the caller's
  request record in place while doing so, so the request the caller passed in was modified as the stream was
  consumed.
- Requests are now sent with the `application/x-amz-json-1.0` content type. 2.x sent `application/json`,
  which is not the protocol DynamoDB speaks.
- Service failures are now reported with their status code and text, request id, error code and error
  message, rather than surfacing as a raw `http:ClientError` whose message was only the HTTP reason phrase.

### Migrating from 2.x

Add an `import ballerinax/aws;` alongside the existing DynamoDB import, and move the credential fields under
`auth`:

```ballerina
// 2.x
import ballerinax/aws.dynamodb;

dynamodb:ConnectionConfig config = {
    awsCredentials: {accessKeyId, secretAccessKey},
    region: "us-east-1"
};
```

```ballerina
// 3.0.0
import ballerinax/aws;
import ballerinax/aws.dynamodb;

dynamodb:ConnectionConfig config = {
    auth: {accessKeyId, secretAccessKey},
    region: aws:US_EAST_1
};
```

Temporary credentials move from `securityToken` to `sessionToken` inside `auth` — and, unlike in 2.x, are
actually sent:

```ballerina
// 2.x
dynamodb:ConnectionConfig config = {
    awsCredentials: {accessKeyId, secretAccessKey, securityToken},
    region: "us-east-1"
};
```

```ballerina
// 3.0.0
dynamodb:ConnectionConfig config = {
    auth: {accessKeyId, secretAccessKey, sessionToken},
    region: aws:US_EAST_1
};
```

Deployments that should resolve credentials from the environment rather than from hardcoded keys can now
use the default credential provider chain:

```ballerina
// 3.0.0
import ballerinax/aws;
import ballerinax/aws.auth;

dynamodb:ConnectionConfig config = {
    auth: auth:DEFAULT_CREDENTIALS,
    region: aws:US_EAST_1
};
```

Code that declares the type of a returned stream explicitly must name the module's `Error` type. The record
shapes and the operation names are unchanged, so nothing else in the call has to move:

```ballerina
// 2.x
stream<dynamodb:QueryOutput, error?> results = check dynamoDb->query({TableName: "HighScores"});
```

```ballerina
// 3.0.0
stream<dynamodb:QueryOutput, dynamodb:Error?> results = check dynamoDb->query({TableName: "HighScores"});
```

A client now holds resources that outlive a single request, so release it when it is no longer needed:

```ballerina
// 3.0.0
check dynamoDb.close();
```

## Previous releases

This changelog was introduced with the 3.0.0 revamp. For the notes on releases up to and including 2.x, see the
[GitHub releases](https://github.com/ballerina-platform/module-ballerinax-aws.dynamodb/releases) page.
