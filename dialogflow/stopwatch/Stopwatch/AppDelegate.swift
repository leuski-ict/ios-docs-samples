//
// Copyright 2016 Google Inc. All Rights Reserved.
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
import UIKit
import FirebaseFunctions
import Firebase

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
  var window: UIWindow?
  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions:[UIApplication.LaunchOptionsKey :Any]? = nil) -> Bool {
    // Use Firebase library to configure APIs
    FirebaseApp.configure()
    return true
  }
  
  func retrieveAccessToken(completionHandler: ((String) -> Void)? = nil) {
    NotificationCenter.default.post(name: NSNotification.Name(ApplicationConstants.retreivingToken), object: nil)
    //this sample uses Firebase Auth signInAnonymously and you can insert any auth signin that they offer.
    Auth.auth().signInAnonymously() { (authResult, error) in
      if error != nil {
        //Sign in failed
        completionHandler?("")
        return
      }
      TokenReceiver.sharedInstance.retrieveAccessToken(completionHandler: {(token, error) in
        if let token = token {
          NotificationCenter.default.post(name: NSNotification.Name(ApplicationConstants.tokenReceived), object: nil)
          completionHandler?(token)
        } else {
          completionHandler?("")
        }
      })
    }
  }
}
