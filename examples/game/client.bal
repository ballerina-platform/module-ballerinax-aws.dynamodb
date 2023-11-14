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
    dynamodb:CreateTableInput createTableInput = {
        tableName: "HighScores",
        attributeDefinitions: [
            {attributeName: "GameID", attributeType: "S"},
            {attributeName: "Score", attributeType: "N"}
        ],
        keySchema: [
            {attributeName: "GameID", keyType: "HASH"},
            {attributeName: "Score", keyType: "RANGE"}
        ],
        provisionedThroughput: {
            readCapacityUnits: 5,
            writeCapacityUnits: 5
        }
    };
    _ = check amazonDynamodbClient->createTable(createTableInput);

    dynamodb:CreateItemInput createItemInput = {
        tableName: "HighScores",
        item: {
            "GameID": {"S": "FlappyBird"},
            "Score": {"N": "500"},
            "PlayerName": {"S": "JohnDoe"}
        }
    };
    dynamodb:ItemDescription createItemResult = check amazonDynamodbClient->createItem(createItemInput);
    io:println("Added item: ", createItemResult);

    dynamodb:QueryInput queryInput = {
        tableName: "HighScores",
        keyConditionExpression: "GameID = :game",
        expressionAttributeValues: {
            ":game": {"S": "FlappyBird"}
        },
        'limit: 10,
        scanIndexForward: false
    };

    stream<dynamodb:QueryOutput, error?> response = check amazonDynamodbClient->query(queryInput);
    check response.forEach(function(dynamodb:QueryOutput resp) {
        io:println(resp?.item);
    });

    dynamodb:UpdateItemInput updateItemInput = {
        tableName: "HighScores",
        'key: {
            "GameID": {"S": "FlappyBird"},
            "Score": {"N": "1000"}
        },
        updateExpression: "set PlayerName = :name",
        expressionAttributeValues: {
            ":name": {"S": "newPlayer"}
        }
    };
    dynamodb:ItemDescription updateItemResult = check amazonDynamodbClient->updateItem(updateItemInput);
    io:println("Updated the high score: ", updateItemResult);

    dynamodb:DeleteItemInput deleteItemInput = {
        tableName: "HighScores",
        'key: {
            "GameID": {"S": "FlappyBird"},
            "Score": {"N": "500"}
        }
    };

    dynamodb:ItemDescription deleteItemResult = check amazonDynamodbClient->deleteItem(deleteItemInput);
    io:println("Deleted the high score: ", deleteItemResult);
}
