// Copyright (c) 2021, WSO2 Inc. (http://www.wso2.org) All Rights Reserved.
//
// WSO2 Inc. licenses this file to you under the Apache License,
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

import ballerina/http;
import ballerinax/aws;
import ballerinax/aws.auth;

# Builds the request for an operation, signed with AWS Signature Version 4.
#
# + credentialProvider - Provider that resolves (and refreshes) the signing credentials
# + host - The endpoint host to sign against
# + region - The signing region
# + target - The `x-amz-target` value identifying the operation
# + payload - The request body
# + return - The signed request, or an `Error` if the credentials cannot be resolved or the request cannot be signed
isolated function generateRequest(auth:CredentialProvider credentialProvider, string host, aws:Region|string region,
        string target, json payload) returns http:Request|Error {
    string body = payload.toJsonString();
    auth:Credentials|auth:CredentialResolutionError credentials = credentialProvider.getCredentials();
    if credentials is auth:CredentialResolutionError {
        return error RequestGenerationError(
                string `Error occurred while resolving the AWS credentials: ${credentials.message()}`, credentials);
    }

    map<string>|auth:SigningError signedHeaders = auth:getSignedHeaders({
        method: http:POST,
        host: host,
        path: ROOT_PATH,
        headers: {[CONTENT_TYPE_HEADER]: JSON_CONTENT_TYPE, [TARGET_HEADER]: target},
        payload: body.toBytes()
    }, credentials, region, SERVICE_NAME);
    if signedHeaders is auth:SigningError {
        return error RequestGenerationError(
                string `Error occurred while signing the request: ${signedHeaders.message()}`, signedHeaders);
    }

    http:Request request = new;
    request.setTextPayload(body, JSON_CONTENT_TYPE);
    foreach [string, string] [name, value] in signedHeaders.entries() {
        request.setHeader(name, value);
    }
    return request;
}

# Sends a signed request to the DynamoDB endpoint.
#
# + dynamoDbClient - The HTTP client pointing at the resolved DynamoDB endpoint
# + request - The signed request to send
# + return - The JSON response payload, or an `Error`
isolated function sendRequest(http:Client dynamoDbClient, http:Request request) returns json|Error {
    http:Response|http:ClientError response = dynamoDbClient->post(ROOT_PATH, request);
    if response is http:ClientError {
        return error Error(string `Error occurred while invoking the REST API: ${response.message()}`, response);
    }
    return handleResponse(response);
}

# Reads the response payload, turning a service failure into an `Error`. The error detail carries the status code
# and text, the request id, and the `errorCode`/`errorMessage` read from the service's JSON 1.0 error document.
# When the body cannot be read at all, the read failure is the error's cause.
#
# + response - The response received from the service
# + return - The JSON response payload, or an `Error`
isolated function handleResponse(http:Response response) returns json|Error {
    // DynamoDB answers every successful operation with 200; there is no other success status.
    if response.statusCode == http:STATUS_OK {
        json|error payload = response.getJsonPayload();
        if payload is error {
            return error ResponseHandlingError(
                    string `Error occurred while reading the response payload: ${payload.message()}`, payload);
        }
        return payload;
    }

    string|error requestId = response.getHeader(REQUEST_ID_HEADER);
    string message = string `The DynamoDB operation failed with status ${response.statusCode}`;
    string|error body = response.getTextPayload();
    if body is error {
        return error Error(message, body,
            httpStatusCode = response.statusCode,
            httpStatusText = response.reasonPhrase,
            requestId = requestId is string ? requestId : ""
        );
    }

    [string, string] [errorCode, errorMessage] = parseErrorDocument(body);
    return error Error(message,
        httpStatusCode = response.statusCode,
        httpStatusText = response.reasonPhrase,
        requestId = requestId is string ? requestId : "",
        errorCode = errorCode,
        errorMessage = errorMessage
    );
}

# Pulls the exception name and message out of the service's JSON 1.0 error document, which has the shape
# `{"__type": "<prefix>#<Exception>", "message": "<text>"}`.
#
# A failure body is not always that document — a proxy or gateway in front of the endpoint may answer with
# something else entirely, such as an HTML error page. In that case there is no exception name to report, and the
# body itself is the only account of what went wrong, so it becomes the message verbatim.
#
# + body - The response body
# + return - The error code, which is empty when the body is not the service's error document, and the error message
isolated function parseErrorDocument(string body) returns [string, string] {
    json|error document = body.fromJsonString();
    if document !is map<json> {
        return ["", body];
    }

    string errorCode = "";
    json? typeName = document["__type"];
    if typeName is string {
        // The `__type` value is qualified, e.g. `com.amazonaws.dynamodb.v20120810#ResourceNotFoundException`.
        int? separator = typeName.lastIndexOf("#");
        errorCode = separator is int ? typeName.substring(separator + 1) : typeName;
    }

    // AWS is not consistent about the case of the message key across services and error shapes.
    json? serviceMessage = document["message"] ?: document["Message"];
    return [errorCode, serviceMessage is string ? serviceMessage : body];
}
