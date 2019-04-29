//
// Copyright 2017 Google Inc. All Rights Reserved.
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
import googleapis

typealias StopwatchCompletionHandler =
  (DFStreamingDetectIntentResponse?, NSError?) -> (Void)

typealias StopwatchTextCompletionHandler = (DFDetectIntentResponse?, NSError?) -> (Void)

enum StopwatchServiceError: Error {
  case unknownError
  case invalidCredentials
  case tokenNotAvailable
}

class StopwatchService {
  var sampleRate: Int = ApplicationConstants.SampleRate
  private var streaming = false

  private var client : DFSessions!
  private var writer : GRXBufferedPipe!
  private var call : GRPCProtoCall!
  private var session : String {
    return "projects/" + ApplicationConstants.ProjectName + "/agent/sessions/" + ApplicationConstants.SessionID
  }

  static let sharedInstance = StopwatchService()

  func authorization(completionHandler: @escaping (String)-> Void) {
    TokenReceiver.getToken { (token) in
      if !token.isEmpty {
        completionHandler(ApplicationConstants.tokenType + token)
      } else {
        completionHandler(ApplicationConstants.noTokenError)
      }
    }
  }

  func streamAudioData(_ audioData: NSData, completion: @escaping StopwatchCompletionHandler) {
    // authenticate using an authorization token (obtained using OAuth)
    authorization { (authT) in
      if (!self.streaming) {
        // if we aren't already streaming, set up a gRPC connection
        self.client = DFSessions(host:ApplicationConstants.Host)
        self.writer = GRXBufferedPipe()
        self.call = self.client.rpcToStreamingDetectIntent(
          withRequestsWriter: self.writer,
          eventHandler: { (done, response, error) in
            completion(response, error as NSError?)
        })
        self.call.requestHeaders.setObject(NSString(string:authT),
                                           forKey:NSString(string:"Authorization"))
        self.call.start()
        self.streaming = true

        // send an initial request message to configure the service

        let queryInput = DFQueryInput()
        let inputAudioConfig = DFInputAudioConfig()
        inputAudioConfig.audioEncoding = DFAudioEncoding(rawValue:1)!
        inputAudioConfig.languageCode = ApplicationConstants.languageCode
        inputAudioConfig.sampleRateHertz = Int32(self.sampleRate)
        queryInput.audioConfig = inputAudioConfig

        let streamingDetectIntentRequest = DFStreamingDetectIntentRequest()
        streamingDetectIntentRequest.session = self.session
        streamingDetectIntentRequest.singleUtterance = true
        streamingDetectIntentRequest.queryParams = self.getQueryParmasFor()
        streamingDetectIntentRequest.queryInput = queryInput
        streamingDetectIntentRequest.outputAudioConfig = self.getOutputAudioConfig()
        self.writer.writeValue(streamingDetectIntentRequest)
      }

      // send a request message containing the audio data
      let streamingDetectIntentRequest = DFStreamingDetectIntentRequest()
      streamingDetectIntentRequest.inputAudio = audioData as Data
      self.writer.writeValue(streamingDetectIntentRequest)
    }
  }

  func sendText(_ userInput: String, completion: @escaping StopwatchTextCompletionHandler) {
    // authenticate using an authorization token (obtained using OAuth)
    authorization { (authT) in
      self.client = DFSessions(host:ApplicationConstants.Host)
      let queryInput = DFQueryInput()
      let inputTextConfig = DFTextInput()
      inputTextConfig.text = userInput
      inputTextConfig.languageCode = ApplicationConstants.languageCode
      queryInput.text = inputTextConfig
      let detectIntentRequest = DFDetectIntentRequest()
      detectIntentRequest.session = self.session
      detectIntentRequest.queryInput = queryInput
      detectIntentRequest.outputAudioConfig = self.getOutputAudioConfig()
      detectIntentRequest.queryParams = self.getQueryParmasFor()
      self.call = self.client.rpcToDetectIntent(with: detectIntentRequest, handler: { (response, error) in
        completion(response, error as NSError?)
      })
      self.call.requestHeaders.setObject(NSString(string:authT),
                                         forKeyedSubscript:NSString(string:"Authorization"))
      self.call.start()
    }
  }

  func getOutputAudioConfig() -> DFOutputAudioConfig? {
    let defaults = UserDefaults.standard
    if let defaultItems = defaults.value(forKey: ApplicationConstants.selectedMenuItems) as? [Int],
      defaultItems.count > 0 {
      if defaultItems.contains(BetaFeatureMenu.textToSpeech.rawValue) {
        let outputAudioConfig = DFOutputAudioConfig()
        outputAudioConfig.audioEncoding = DFOutputAudioEncoding(rawValue:2)!
        outputAudioConfig.sampleRateHertz = Int32(sampleRate)
        return outputAudioConfig
      }
    }
    return nil
  }

  func getSentimentAnalysisConfig(sentimentSelected: Bool) -> DFSentimentAnalysisRequestConfig {
    let sentimentConfig = DFSentimentAnalysisRequestConfig()
    sentimentConfig.analyzeQueryTextSentiment = sentimentSelected
    return sentimentConfig
  }

  func getQueryParmasFor() -> DFQueryParameters {
    let queryParams = DFQueryParameters()
    let defaults = UserDefaults.standard
    if let defaultItems = defaults.value(forKey: ApplicationConstants.selectedMenuItems) as? [Int],
      defaultItems.count > 0 {
      let sentimentSelected =
        defaultItems.contains(BetaFeatureMenu.sentimentAnalysis.rawValue)
      queryParams.sentimentAnalysisRequestConfig = getSentimentAnalysisConfig(sentimentSelected: sentimentSelected)

      if defaultItems.contains(BetaFeatureMenu.knowledgeConnector.rawValue) {
        getKnowledgeBasePath { (knowledgeBasePath) in
          queryParams.knowledgeBaseNamesArray = [knowledgeBasePath]
        }
      }
    }else {
      queryParams.sentimentAnalysisRequestConfig = getSentimentAnalysisConfig(sentimentSelected: false)
    }
    return queryParams
  }

  func getKnowledgeBasePath(handler: @escaping (_ KnowledgeBasePath: String) -> Void) {
    // authenticate using an authorization token (obtained using OAuth)
    authorization { (authT) in
      let knowledgeBase = DFKnowledgeBases(host: ApplicationConstants.Host)
      let request = DFListKnowledgeBasesRequest()
      request.parent = "projects/\(ApplicationConstants.ProjectName)/agent"
      let call = knowledgeBase.rpcToListKnowledgeBases(with: request, handler: {(knowledgeBaseRes, error) in
        if let error = error {
          print("Error occured while calling knowledge base api \(error.localizedDescription)")
          return
        }
        if let res = knowledgeBaseRes,
          res.knowledgeBasesArray_Count > 0,
          let lastKB = res.knowledgeBasesArray.lastObject as? DFKnowledgeBase,
          let knowledgeBasePath = lastKB.name {
          print("Source response for knowledge base: \(res)")
          print("Found path:\(knowledgeBasePath)")
          handler(knowledgeBasePath)
        }
      })
      call.requestHeaders.setObject(NSString(string:authT),
                                    forKey:NSString(string:"Authorization"))
      call.start()
    }
  }

  func stopStreaming() {
    if (!streaming) {
      return
    }
    writer.finishWithError(nil)
    streaming = false
  }

  func isStreaming() -> Bool {
    return streaming
  }
}


