# Specification: Ballerina DynamoDB Library

_Owners_: @daneshk @bhashinee  
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
       
## 1. [Overview](#1-overview)

The Ballerina `dynamodb` library facilitates APIs to allow you to access the Amazon DynamoDB REST API. Amazon DynamoDB is a fully managed NoSQL database service that provides fast and predictable performance with seamless scalability. AmazonDynamoDB enables customers to offload the administrative burdens of operating and scaling distributed databases to AWS, so they do not have to worry about hardware provisioning, setup and configuration, replication, software patching, or cluster scaling.

## 2. 