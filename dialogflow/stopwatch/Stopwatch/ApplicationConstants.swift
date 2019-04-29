//
// Copyright 2019 Google Inc. All Rights Reserved.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

import Foundation

//MARK: Stopwatch service
extension ApplicationConstants {
  static let Host = "dialogflow.googleapis.com"
  // TODO: Replace with your GCP PROJECT_ID
  static let ProjectName = "your-project-identifier"
  static let SessionID = "001"
  static let SampleRate = 16000 //Sample rate (in Hertz) of the audio content sent in the query.
  static let tokenType = "Bearer "
  static let noTokenError = "No token is available"
  static let languageCode = "en-US"
}

//MARK: Bottom drawer
struct ApplicationConstants {
  static let selectedMenuItems = "selected Menu Items"
  static let sentimentAnalysis = "Sentiment Analysis"
  static let textToSpeech = "Text To Speech"
  static let knowledgeConnector = "Knowledge Connector"
  static let tableViewCellID = "Cell"
  static let menuDrawerTitle = "Tap to enable additional Dialogflow features"

}

//MARK: Token generator constants
extension ApplicationConstants {
  static let token = "Token"
  static let accessToken = "accessToken"
  static let expireTime = "expireTime"
  static let tokenReceived = "tokenReceived"
  static let retreivingToken = "RetrievingToken"
  static let getTokenAPI = "getOAuthToken"
}

extension ApplicationConstants {
  static let selfKey = "Self"
  static let botKey = "Bot"
  static let tokenFetchingAlertTitle = "Alert"
  static let tokenFetchingAlertMessage = "Retrieving token ..."
  static let queryTextFieldPlaceholder = "Type your intent"
  static let dialogflowScreenTitle = "Dialogflow Sample"
  static let moreButtonTitle = "More"
  static let sentimentScore = "Sentiment Score:"
  static let sentimentMagnitude = "Sentiment magnitude:"
}

