// Copyright (c) 2026, WSO2 LLC. (http://www.wso2.com).
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

// The operational suite runs against the local mock service (`mock_service.bal`), so the whole suite passes with
// no AWS account and no network. Setting `IS_LIVE_SERVER` additionally enables the `live` group, which exercises a
// real round trip against AWS — create a table, write and read items, then tear it down.

import ballerina/os;
import ballerinax/aws;
import ballerinax/aws.auth;

configurable boolean isLiveServer = os:getEnv("IS_LIVE_SERVER") == "true";

configurable string accessKeyId = os:getEnv("BALLERINA_AWS_TEST_ACCESS_KEY_ID");
configurable string secretAccessKey = os:getEnv("BALLERINA_AWS_TEST_SECRET_ACCESS_KEY");

final readonly & aws:Region awsRegion = aws:US_EAST_1;

final readonly & auth:StaticAuthConfig liveAuth = {accessKeyId, secretAccessKey};

// The table the mock fixtures describe, and the name the live round trip creates.
final string testTableName = "BallerinaHighScores";

final Client dynamoDb = check newMockClient();

isolated function newLiveClient() returns Client|error => new ({region: awsRegion, auth: liveAuth});
