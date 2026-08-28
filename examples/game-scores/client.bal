// Copyright (c) 2023, WSO2 LLC. (http://www.wso2.org) All Rights Reserved.
//
// WSO2 LLC. licenses this file to you under the Apache License,
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

import ballerina/io;
import ballerina/lang.runtime;
import ballerinax/aws;
import ballerinax/aws.dynamodb;

configurable string accessKeyId = ?;
configurable string secretAccessKey = ?;
configurable string region = ?;

const string TABLE_NAME = "HighScores";

public function main() returns error? {
    dynamodb:Client dynamoDb = check new ({
        auth: {accessKeyId, secretAccessKey},
        region: region is "" ? aws:US_EAST_1 : region
    });

    // The leaderboard is keyed by game, and sorted by score within a game, so that the top scores for one
    // game can be read with a single query rather than a scan of the whole table.
    _ = check dynamoDb->createTable({
        TableName: TABLE_NAME,
        AttributeDefinitions: [
            {AttributeName: "GameId", AttributeType: dynamodb:S},
            {AttributeName: "Score", AttributeType: dynamodb:N}
        ],
        KeySchema: [
            {AttributeName: "GameId", KeyType: dynamodb:HASH},
            {AttributeName: "Score", KeyType: dynamodb:RANGE}
        ],
        BillingMode: dynamodb:PAY_PER_REQUEST
    });
    check waitUntilActive(dynamoDb);
    io:println(string `Created the '${TABLE_NAME}' table`);

    // Record a few scores. A put replaces any existing item with the same primary key.
    foreach [string, string] [player, score] in [["PlayerOne", "500"], ["PlayerTwo", "900"], ["PlayerThree", "700"]] {
        _ = check dynamoDb->createItem({
            TableName: TABLE_NAME,
            Item: {
                "GameId": {S: "FlappyBird"},
                "Score": {N: score},
                "PlayerName": {S: player}
            }
        });
    }
    io:println("Recorded three scores");

    // Read the leaderboard. `ScanIndexForward: false` walks the sort key downwards, so the highest scores
    // come first. The returned stream pages through the result set on its own.
    io:println(string `Top scores for FlappyBird:`);
    stream<dynamodb:QueryOutput, dynamodb:Error?> scores = check dynamoDb->query({
        TableName: TABLE_NAME,
        KeyConditionExpression: "GameId = :game",
        ExpressionAttributeValues: {":game": {S: "FlappyBird"}},
        ScanIndexForward: false,
        Limit: 10
    });
    check from dynamodb:QueryOutput result in scores
        do {
            map<dynamodb:AttributeValue> item = check result?.Item.ensureType();
            io:println(string `  ${item["PlayerName"]?.S ?: "?"}: ${item["Score"]?.N ?: "?"}`);
        };

    // A player renamed their profile. Only the non-key attribute changes, so this is an update in place.
    _ = check dynamoDb->updateItem({
        TableName: TABLE_NAME,
        Key: {"GameId": {S: "FlappyBird"}, "Score": {N: "500"}},
        UpdateExpression: "SET PlayerName = :name",
        ExpressionAttributeValues: {":name": {S: "NewPlayer"}}
    });
    io:println("Renamed the player holding the 500 score");

    // A player asked for their score to be removed.
    _ = check dynamoDb->deleteItem({
        TableName: TABLE_NAME,
        Key: {"GameId": {S: "FlappyBird"}, "Score": {N: "700"}}
    });
    io:println("Deleted the 700 score");

    _ = check dynamoDb->deleteTable(TABLE_NAME);
    io:println(string `Deleted the '${TABLE_NAME}' table`);

    check dynamoDb.close();
}

// A freshly created table cannot be written to until DynamoDB reports it as ACTIVE.
function waitUntilActive(dynamodb:Client dynamoDb) returns error? {
    foreach int _ in 0 ..< 60 {
        dynamodb:TableDescription description = check dynamoDb->describeTable(TABLE_NAME);
        if description?.TableStatus == dynamodb:ACTIVE {
            return;
        }
        runtime:sleep(2);
    }
    return error(string `The '${TABLE_NAME}' table did not become ACTIVE in time`);
}
