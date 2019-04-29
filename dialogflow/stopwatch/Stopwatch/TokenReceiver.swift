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
import Firebase

class TokenReceiver {
  public static let sharedInstance = TokenReceiver()
  //This func retrieves tokens from index.js
  public func retrieveAccessToken(completionHandler: @escaping (String?, Error?) -> Void) {
    Functions.functions().httpsCallable(ApplicationConstants.getTokenAPI).call { (result, error) in
      if error != nil {
        completionHandler(nil, error)
        return
      }
      guard let res: HTTPSCallableResult = result else {
        completionHandler(nil, "Result found nil" as? Error)
        return
      }
      guard let tokenData = res.data as? [String: Any] else {return}
      UserDefaults.standard.set(tokenData, forKey: ApplicationConstants.token)
      if let accessToken = tokenData[ApplicationConstants.accessToken] as? String, !accessToken.isEmpty {
        completionHandler(accessToken, nil)
      }
    }
  }
  
  //This function compares token expiry date with current date
  //Returns bool value True if the token is expired else false
  static func isExpired() -> Bool {
    guard let token = UserDefaults.standard.value(forKey: ApplicationConstants.token) as? [String: String],
      let expDate = token[ApplicationConstants.expireTime] else{
        return true
    }
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
    guard let expiryDate = dateFormatter.date(from: expDate) else {
      return true
    }
    return (Date() > expiryDate)
  }

  //Return token from user defaults if token is there and not expired.
  //Request for new token if token is expired or not there in user defaults.
  //Return the newly generated token.
  static func getToken(completionHandler: @escaping (String)->Void) {
    if isExpired() {
      guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
        return completionHandler("")
      }
      appDelegate.retrieveAccessToken { (result) in
        completionHandler(result)
      }
    } else {
      guard let token = UserDefaults.standard.value(forKey: ApplicationConstants.token) as? [String: String],
        let accessToken = token[ApplicationConstants.accessToken] else {
          return completionHandler("")
      }
      return completionHandler(accessToken)
    }
  }

}
