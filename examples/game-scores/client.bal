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
import ballerina/os;
import ballerinax/aws.dynamodb;

public function main() returns error? {
    dynamodb:ConnectionConfig amazonDynamodbConfig = {
        awsCredentials: {
            accessKeyId: os:getEnv("ACCESS_KEY_ID"),
            secretAccessKey: os:getEnv("SECRET_ACCESS_KEY")
        },
        region: os:getEnv("REGION")
    };

    dynamodb:Client amazonDynamodbClient = check new (amazonDynamodbConfig);
    dynamodb:TableCreateInput createTableInput = {
        TableName: "HighScores",
        AttributeDefinitions: [
            {AttributeName: "GameID", AttributeType: "S"},
            {AttributeName: "Score", AttributeType: "N"}
        ],
        KeySchema: [
            {AttributeName: "GameID", KeyType: "HASH"},
            {AttributeName: "Score", KeyType: "RANGE"}
        ],
        ProvisionedThroughput: {
            ReadCapacityUnits: 5,
            WriteCapacityUnits: 5
        }
    };
    _ = check amazonDynamodbClient->createTable(createTableInput);

    dynamodb:ItemCreateInput createItemInput = {
        TableName: "HighScores",
        Item: {
            "GameID": {"S": "FlappyBird"},
            "Score": {"N": "500"},
            "PlayerName": {"S": "JohnDoe"}
        }
    };
    dynamodb:ItemDescription createItemResult = check amazonDynamodbClient->createItem(createItemInput);
    io:println("Added item: ", createItemResult);

    dynamodb:QueryInput queryInput = {
        TableName: "HighScores",
        KeyConditionExpression: "GameID = :game",
        ExpressionAttributeValues: {
            ":game": {"S": "FlappyBird"}
        },
        Limit: 10,
        ScanIndexForward: false
    };

    stream<dynamodb:QueryOutput, error?> response = check amazonDynamodbClient->query(queryInput);
    check response.forEach(function(dynamodb:QueryOutput resp) {
        io:println(resp?.Item);
    });

    dynamodb:ItemUpdateInput updateItemInput = {
        TableName: "HighScores",
        Key: {
            "GameID": {"S": "FlappyBird"},
            "Score": {"N": "1000"}
        },
        UpdateExpression: "set PlayerName = :name",
        ExpressionAttributeValues: {
            ":name": {"S": "Jasper"}
        }
    };
    dynamodb:ItemDescription updateItemResult = check amazonDynamodbClient->updateItem(updateItemInput);
    io:println("Updated the high score: ", updateItemResult);

    dynamodb:ItemDeleteInput deleteItemInput = {
        TableName: "HighScores",
        Key: {
            "GameID": {"S": "FlappyBird"},
            "Score": {"N": "500"}
        }
    };

    dynamodb:ItemDescription deleteItemResult = check amazonDynamodbClient->deleteItem(deleteItemInput);
    io:println("Deleted the high score: ", deleteItemResult);
}
