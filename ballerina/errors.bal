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

import ballerinax/aws;

# Represents an AWS DynamoDB distinct error.
public type Error distinct error<aws:ErrorDetails>;

# Represents an error that occurs while generating an API request, before anything is sent: the AWS credentials
# cannot be resolved, or the request cannot be signed. Nothing reached the service, so the detail fields are unset.
public type RequestGenerationError distinct Error;

# Represents an error that occurs when the API response cannot be handled: the payload cannot be read, or it does
# not match the expected shape. The service did not report a failure, so only the transport-level detail fields
# may be set.
public type ResponseHandlingError distinct Error;
