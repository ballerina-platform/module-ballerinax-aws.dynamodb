# Mobile Game High Scores

## Overview

Imagine you are developing a mobile gaming application that tracks high scores for different games. In this scenario, DynamoDB could be employed to manage the backend data storage efficiently. This example demonstrates how DynamoDB can be used to store and manage high scores efficiently, providing low-latency access to data and allowing for seamless scaling as the number of players and high scores grows. DynamoDB's ability to handle large amounts of data with high throughput makes it suitable for such real-time, dynamic applications.

## Implementation

1. Create a table

You create a DynamoDB table named "HighScores" with the following structure:
   a. Partition key: GameID (String)
   b. Sort key: Score (Number)

2. Insert High scores

Whenever a player completes a game, the mobile app sends the high score data to DynamoDB.

3. Querying the high scores

Players can view the top scores for a specific game. The program is written to retrieve the top 10 high scores for the game. 

3. Updating high scores

If a player achieves a higher score, the app updates the DynamoDB record. Using the `updateItem` API, the player name for the high score of 500 in the "FlappyBird" game to "NewPlayer."

4. Delete high scores

If a player wants to remove their score, the app can delete the corresponding record using the `deleteItem` API.

## Run the Example

First, clone this repository, and then run the following commands to run this example in your local machine.

```sh
// Run the dynamoDB client
$ cd examples/game/client
$ bal run
```
