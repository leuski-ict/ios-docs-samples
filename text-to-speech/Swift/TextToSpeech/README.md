# Cloud Text to Speech gRPC Swift Sample

This app demonstrates how to make gRPC connections to the [Cloud TextToSpeech API](https://cloud.google.com/text-to-speech/) to get the audio data of the text.

## Prerequisites
- An API key for the Cloud Text to Speech API (See
  [the docs][getting-started] to learn more)
- An OSX machine or emulator
- [Xcode 8 beta 6][xcode] or later
- [Cocoapods][cocoapods] version 1.0 or later

## Quickstart
- Clone this repo and `cd` into this directory.
- Run `./INSTALL-COCOAPODS`
- In `TextToSpeech/ApplicationConstants.swift`, replace `YOUR_API_KEY` with the API key obtained above.
- Build and run the app.


## Running the app

- As with all Google Cloud APIs, every call to the Text to Speech API must be associated
  with a project within the [Google Cloud Console][cloud-console] that has the
  Text to Speech API enabled. This is described in more detail in the [getting started
  doc][getting-started], but in brief:
  - Create a project (or use an existing one) in the [Cloud
    Console][cloud-console]
  - [Enable billing][billing] and the [TextToSpeech API][enable-text-to-speech].
  - Create an [API key][api-key], and save this for later.

- Clone this repository on GitHub. If you have [`git`][git] installed, you can do this by executing the following command:

        $ git clone https://github.com/GoogleCloudPlatform/ios-docs-samples.git

    This will download the repository of samples into the directory
    `ios-docs-samples`.

- `cd` into this directory in the repository you just cloned, and run the command `./INSTALL-COCOAPODS` to prepare all Cocoapods-related dependencies.

- `open TextToSpeech.xcworkspace` to open this project in Xcode. Since we are using Cocoapods, be sure to open the workspace and not Speech.xcodeproj.

- In Xcode's Project Navigator, open the `ApplicationConstants.swift` file within the `TextToSpeech` directory.

- Find the line where the `API_KEY` is set. Replace the string value with the API key obtained from the Cloud console above. This key is the credential used to authenticate all requests to the TextToSpeech API. Calls to the API are thus associated with the project you created above, for access and billing purposes.

- You are now ready to build and run the project. In Xcode you can do this by clicking the 'Play' button in the top left. This will launch the app on the simulator or on the device you've selected. Be sure that the 'TextToSpeech' target is selected in the popup near the top left of the Xcode window. 

- Tap the `Type your input` text field. This sends the text to the TextToSpeechService class, which sends it to the TextToSpeech Service. Once the response `SynthesizeSpeechResponse` comes, then it extracts audio data from it and sends it to the controller.
- Controller plays the audio from audioData.

- Type a few words and wait for the audio to play when your text is recognized.

[getting-started]: https://cloud.google.com/text-to-speech/docs/quickstarts
[cloud-console]: https://console.cloud.google.com
[git]: https://git-scm.com/
[xcode]: https://developer.apple.com/xcode/
[billing]: https://console.cloud.google.com/billing?project=_
[enable-text-to-speech]: https://console.cloud.google.com/apis/library/texttospeech.googleapis.com
[api-key]: https://console.cloud.google.com/apis/credentials?project=_
[cocoapods]: https://cocoapods.org/
[gRPC Objective-C setup]: https://github.com/grpc/grpc/tree/master/src/objective-c

