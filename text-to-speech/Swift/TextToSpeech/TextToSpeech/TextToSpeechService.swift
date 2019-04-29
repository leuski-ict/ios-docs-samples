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
import googleapis
import AVFoundation

class TextToSpeechRecognitionService {
  private var client : TextToSpeech!
  private var writer : GRXBufferedPipe!
  private var call : GRPCProtoCall!
  
  static let sharedInstance = TextToSpeechRecognitionService()
  
  func textToSpeech(text:String, completionHandler: @escaping (_ audioData: Data) -> Void) {
    client = TextToSpeech(host: ApplicationConstants.Host)
    writer = GRXBufferedPipe()
    
    let synthesisInput = SynthesisInput()
    synthesisInput.text = text
    
    let voiceSelectionParams = VoiceSelectionParams()
    voiceSelectionParams.languageCode = ApplicationConstants.languageCode
    voiceSelectionParams.ssmlGender = SsmlVoiceGender.neutral
    
    let audioConfig = AudioConfig()
    audioConfig.audioEncoding = AudioEncoding.mp3
    
    let speechRequest = SynthesizeSpeechRequest()
    speechRequest.audioConfig = audioConfig
    speechRequest.input = synthesisInput
    speechRequest.voice = voiceSelectionParams
    
    call = client.rpcToSynthesizeSpeech(with: speechRequest, handler: { (synthesizeSpeechResponse, error) in
      if error != nil {
        print(error?.localizedDescription ?? "No error description available")
        return
      }
      guard let response = synthesizeSpeechResponse else {
        print("No response received")
        return
      }
      print("Text to speech response\(response)")
      guard let audioData =  response.audioContent else {
        print("no audio data received")
        return
      }
      completionHandler(audioData)
    })
    call.requestHeaders.setObject(NSString(string:ApplicationConstants.API_KEY), forKey:NSString(string:"X-Goog-Api-Key"))
    
    // if the API key has a bundle ID restriction, specify the bundle ID like this
    
    call.requestHeaders.setObject(NSString(string:Bundle.main.bundleIdentifier!), forKey:NSString(string:"X-Ios-Bundle-Identifier"))
    print("HEADERS:\(String(describing: call.requestHeaders))")
    call.start()
  }
}





