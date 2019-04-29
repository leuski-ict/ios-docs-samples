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

import UIKit
import MaterialComponents
import AVFoundation
import googleapis

class DialogflowViewController: UIViewController {
  let headerViewController = DrawerHeaderViewController()
  let contentViewController = DrawerContentViewController()
  var appBar = MDCAppBar()
  var audioData: NSMutableData!
  var listening: Bool = false
  var isFirst: Bool = true
  // Text Field
  var intentTextField: MDCTextField = {
    let textField = MDCTextField()
    textField.translatesAutoresizingMaskIntoConstraints = false
    return textField
  }()
  var  textFieldBottomConstraint: NSLayoutConstraint!
  let intentTextFieldController: MDCTextInputControllerOutlined
  var tableViewDataSource = [[String: String]]()
  lazy var alert : UIAlertController = {
    let alert = UIAlertController(title: ApplicationConstants.tokenFetchingAlertTitle, message: ApplicationConstants.tokenFetchingAlertMessage, preferredStyle: .alert)
    return alert
  }()

  @IBOutlet weak var tableView: UITableView!
  @IBOutlet weak var optionsCard: MDCCard!
  @IBOutlet weak var audioButton: UIButton!
  @IBOutlet weak var keyboardButton: UIButton!
  @IBOutlet weak var cancelButton: UIButton!
  var avPlayer: AVAudioPlayer?


  //init with nib name
  override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
    intentTextFieldController = MDCTextInputControllerOutlined(textInput: intentTextField)
    super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    intentTextFieldController.placeholderText = ApplicationConstants.queryTextFieldPlaceholder
  }

  //init with coder
  required init?(coder aDecoder: NSCoder) {
    intentTextFieldController = MDCTextInputControllerOutlined(textInput: intentTextField)
    super.init(coder: aDecoder)
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    self.view.tintColor = .black
    self.view.backgroundColor = ApplicationScheme.shared.colorScheme.surfaceColor
    self.title = ApplicationConstants.dialogflowScreenTitle
    setUpNavigationBarAndItems()
    registerKeyboardNotifications()
    //Register for notification
    NotificationCenter.default.addObserver(self, selector: #selector(dismissAlert), name: NSNotification.Name(ApplicationConstants.tokenReceived), object: nil)
    NotificationCenter.default.addObserver(self, selector: #selector(presentAlert), name: NSNotification.Name(ApplicationConstants.retreivingToken), object: nil)
    //Audio Controller initialization
    AudioController.sharedInstance.delegate = self
    optionsCard.cornerRadius = optionsCard.frame.height/2
    self.view.addSubview(intentTextField)
    intentTextField.isHidden = true
    intentTextField.backgroundColor = .white
    intentTextField.returnKeyType = .send
    intentTextFieldController.placeholderText = "Type your intent"
    intentTextField.delegate = self

    // Constraints
    textFieldBottomConstraint = NSLayoutConstraint(item: intentTextField,
                                                   attribute: .bottom,
                                                   relatedBy: .equal,
                                                   toItem: view,
                                                   attribute: .bottom,
                                                   multiplier: 1,
                                                   constant: 0)

    var constraints = [NSLayoutConstraint]()
    constraints.append(textFieldBottomConstraint)
    constraints.append(contentsOf:
      NSLayoutConstraint.constraints(withVisualFormat: "H:|-[intentTF]-|",
                                     options: [],
                                     metrics: nil,
                                     views: [ "intentTF" : intentTextField]))
    NSLayoutConstraint.activate(constraints)
    let colorScheme = ApplicationScheme.shared.colorScheme
    MDCTextFieldColorThemer.applySemanticColorScheme(colorScheme,
                                                     to: self.intentTextFieldController)

  }

  @objc func presentAlert() {
    //Showing the alert until token is received
    if alert.isViewLoaded == false {
      self.present(alert, animated: true, completion: nil)
    }
  }
  
  @objc func dismissAlert() {
    alert.dismiss(animated: true, completion: nil)
  }

  @objc func presentNavigationDrawer() {
    let bottomDrawerViewController = MDCBottomDrawerViewController()
    bottomDrawerViewController.setTopCornersRadius(24, for: .collapsed)
    bottomDrawerViewController.setTopCornersRadius(8, for: .expanded)
    bottomDrawerViewController.isTopHandleHidden = false
    bottomDrawerViewController.topHandleColor = UIColor.lightGray
    bottomDrawerViewController.contentViewController = contentViewController
    bottomDrawerViewController.headerViewController = headerViewController
    bottomDrawerViewController.delegate = self
    MDCBottomDrawerColorThemer.applySemanticColorScheme(MDCSemanticColorScheme(),
                                                        toBottomDrawer: bottomDrawerViewController)
    present(bottomDrawerViewController, animated: true, completion: nil)
  }

  func bottomDrawerControllerDidChangeTopInset(_ controller: MDCBottomDrawerViewController,
                                               topInset: CGFloat) {
    headerViewController.titleLabel.center =
      CGPoint(x: headerViewController.view.frame.size.width / 2,
              y: (headerViewController.view.frame.size.height + topInset) / 2)
  }

  func setUpNavigationBarAndItems() {
    //Initialize and add AppBar
    self.addChild(appBar.headerViewController)
    self.appBar.headerViewController.headerView.trackingScrollView = tableView
    appBar.addSubviewsToParent()
    let barButtonLeadingItem = UIBarButtonItem()
    barButtonLeadingItem.tintColor = ApplicationScheme.shared.colorScheme.primaryColorVariant
    barButtonLeadingItem.title = ApplicationConstants.moreButtonTitle
    barButtonLeadingItem.target = self
    barButtonLeadingItem.action = #selector(presentNavigationDrawer)
    appBar.navigationBar.backItem = barButtonLeadingItem
    MDCAppBarColorThemer.applySemanticColorScheme(ApplicationScheme.shared.colorScheme, to:self.appBar)
  }
  //Action to start text chat bot
  @IBAction func didTapkeyboard(_ sender: Any) {
    //make intentTF first responder
    intentTextField.isHidden = false
    intentTextField.becomeFirstResponder()
  }

  //Action to stat microphone for speech chat
  @IBAction func didTapMicrophone(_ sender: Any) {
    if !listening {
      self.startListening()
    } else {
      self.stopListening()
    }

  }


  @IBAction func didTapCancelButton(_ sender: Any) {
    optionsCard.isHidden = false
    optionsCard.isHidden = true
    DispatchQueue.global().async {
      self.stopListening()
    }

  }

}

extension DialogflowViewController: MDCBottomDrawerViewControllerDelegate {

  class func catalogMetadata() -> [String: Any] {
    return [
      "breadcrumbs": ["Navigation Drawer", "Bottom Drawer"],
      "primaryDemo": false,
      "presentable": false,
    ]
  }
}
//MARK: helper functions
extension DialogflowViewController {
  func handleError(error: Error) {
    tableViewDataSource.append([ApplicationConstants.botKey: error.localizedDescription])
    tableView.insertRows(at: [IndexPath(row: tableViewDataSource.count -  1, section: 0)], with: .automatic)
    tableView.scrollToBottom()
  }
}

extension DialogflowViewController: AudioControllerDelegate {
  //Microphone start listening
  func startListening() {
    listening = true
    optionsCard.isHidden = true
    cancelButton.isHidden = false
    audioData = NSMutableData()
    _ = AudioController.sharedInstance.prepare(specifiedSampleRate: ApplicationConstants.SampleRate)
    StopwatchService.sharedInstance.sampleRate = ApplicationConstants.SampleRate
    _ = AudioController.sharedInstance.start()
  }

  //Microphone stops listening
  func stopListening() {
    DispatchQueue.main.async {
      self.optionsCard.isHidden = false
      self.cancelButton.isHidden = true
      _ = AudioController.sharedInstance.stop()
      StopwatchService.sharedInstance.stopStreaming()
      self.listening = false
    }
  }

  //Process sample data
  func processSampleData(_ data: Data) -> Void {
    audioData.append(data)

    // We recommend sending samples in 100ms chunks
    let chunkSize : Int /* bytes/chunk */ =
      Int(0.1 /* seconds/chunk */
        * Double(ApplicationConstants.SampleRate) /* samples/second */
        * 2 /* bytes/sample */);
    //Handling the response by the agent eg. showing the quertText, fulfillmentText, and also
    //if user has selected TTS then playing the response audio
    if (audioData.length > chunkSize) {
      StopwatchService.sharedInstance.streamAudioData(
        audioData,
        completion: { [weak self] (response, error) in
          guard let strongSelf = self else {
            return
          }
          if let error = error, !error.localizedDescription.isEmpty {
            strongSelf.handleError(error: error)
          } else if let response = response {
            if !response.recognitionResult.transcript.isEmpty {
              if strongSelf.isFirst{
                strongSelf.tableViewDataSource.append([ApplicationConstants.selfKey: response.recognitionResult.transcript])
                strongSelf.tableView.insertRows(at: [IndexPath(row: strongSelf.tableViewDataSource.count - 1, section: 0)], with: .automatic)
                strongSelf.isFirst = false
              }else {
                strongSelf.tableViewDataSource.removeLast()
                strongSelf.tableViewDataSource.append([ApplicationConstants.selfKey: response.recognitionResult.transcript])
                strongSelf.tableView.reloadRows(at: [IndexPath(row: strongSelf.tableViewDataSource.count - 1, section: 0)], with: .automatic)
              }
            }
            if let recognitionResult = response.recognitionResult {
              if recognitionResult.isFinal {
                strongSelf.stopListening()
                strongSelf.isFirst = true
              }
            }
            if !response.queryResult.queryText.isEmpty {
              strongSelf.tableViewDataSource.removeLast()
              strongSelf.tableViewDataSource.append([ApplicationConstants.selfKey: response.queryResult.queryText])
              strongSelf.tableView.reloadRows(at: [IndexPath(row: strongSelf.tableViewDataSource.count -  1, section: 0)], with: .automatic)
            }
            if !response.queryResult.fulfillmentText.isEmpty {
              var text = response.queryResult.fulfillmentText ?? ""
              if response.queryResult.fulfillmentMessagesArray_Count > 0, let lastTextObj = response.queryResult.fulfillmentMessagesArray.lastObject as? DFIntent_Message, let finalText = lastTextObj.text.textArray.lastObject as? String {
                text = finalText
              }
              if response.queryResult.hasSentimentAnalysisResult {
                text += "\nSentiment score:\(response.queryResult.sentimentAnalysisResult.queryTextSentiment.score)"
                text += "\nSentiment magnitude:\(response.queryResult.sentimentAnalysisResult.queryTextSentiment.magnitude)"
              }
              strongSelf.tableViewDataSource.append([ApplicationConstants.botKey: text])
              strongSelf.tableView.insertRows(at: [IndexPath(row: strongSelf.tableViewDataSource.count - 1, section: 0)], with: .automatic)
            }
            if response.hasOutputAudioConfig, let audioOutput = response.outputAudio {
              self?.audioPlayerFor(audioData: audioOutput)
              print("playing audio")
            }
            strongSelf.tableView.scrollToBottom()
          }
      })
      self.audioData = NSMutableData()
    }
  }
}

// MARK: - Keyboard Handling
extension DialogflowViewController {

  func registerKeyboardNotifications() {
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(self.keyboardWillShow),
      name: UIResponder.keyboardDidShowNotification,
      object: nil)

    NotificationCenter.default.addObserver(
      self,
      selector: #selector(self.keyboardWillHide),
      name: UIResponder.keyboardWillHideNotification,
      object: nil)
  }

  @objc func keyboardWillShow(notification: NSNotification) {
    let keyboardFrame =
      (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
    textFieldBottomConstraint.constant = -keyboardFrame.height

  }

  @objc func keyboardWillHide(notification: NSNotification) {
    textFieldBottomConstraint.constant = 0
    intentTextField.isHidden = true

  }
}

//MARK: Textfield delegate
extension DialogflowViewController: UITextFieldDelegate {
  //Captures the query typed by user
  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    textField.resignFirstResponder()
    if let text = textField.text, text.count > 0 {
      sendTextToDialogflow(text: text)
      textField.text = ""
    }

    return true
  }

  //Start sending text
  func sendTextToDialogflow(text: String) {
    StopwatchService.sharedInstance.sendText(text, completion: { [weak self] (response, error) in
      guard let strongSelf = self else {
        return
      }
      if let error = error, !error.localizedDescription.isEmpty {

        strongSelf.handleError(error: error)
      } else if let response = response {
        if response.hasOutputAudioConfig {
          if let audioOutput = response.outputAudio {
            self?.audioPlayerFor(audioData: audioOutput)
          }
        }
        if !response.queryResult.queryText.isEmpty {
          strongSelf.tableViewDataSource.append([ApplicationConstants.selfKey: response.queryResult.queryText])
          strongSelf.tableView.insertRows(at: [IndexPath(row: strongSelf.tableViewDataSource.count - 1, section: 0)], with: .automatic)
        }
        if !response.queryResult.fulfillmentText.isEmpty {
          var text = response.queryResult.fulfillmentText ?? ""
          if response.queryResult.fulfillmentMessagesArray_Count > 0, let lastTextObj = response.queryResult.fulfillmentMessagesArray.lastObject as? DFIntent_Message, let finalText = lastTextObj.text.textArray.lastObject as? String {
            text = finalText
          }
          if response.queryResult.hasSentimentAnalysisResult {
            text += "\nSentiment score:\(response.queryResult.sentimentAnalysisResult.queryTextSentiment.score)"
            text += "\nSentiment magnitude:\(response.queryResult.sentimentAnalysisResult.queryTextSentiment.magnitude)"
          }
          strongSelf.tableViewDataSource.append([ApplicationConstants.botKey: text])
          strongSelf.tableView.insertRows(at: [IndexPath(row: strongSelf.tableViewDataSource.count - 1, section: 0)], with: .automatic)
        }
        strongSelf.tableView.scrollToBottom()

      }
    })
  }

  func audioPlayerFor(audioData: Data) {
    DispatchQueue.main.async {
      do {
        self.avPlayer = try AVAudioPlayer(data: audioData)
        self.avPlayer?.play()
      } catch let error {
        print("Error occurred while playing audio: \(error.localizedDescription)")
      }
    }
  }
}

// MARK: Table delegate handling
extension DialogflowViewController: UITableViewDataSource {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return tableViewDataSource.count
  }
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let data = tableViewDataSource[indexPath.row]
    let cell = tableView.dequeueReusableCell(withIdentifier: data[ApplicationConstants.selfKey] != nil ? "selfCI" : "intentCI", for: indexPath) as! ChatTableViewCell
    if data[ApplicationConstants.selfKey] != nil {
      cell.selfText.text = data[ApplicationConstants.selfKey]
    } else {
      cell.botResponseText.text = data[ApplicationConstants.botKey]
    }
    return cell
  }
}

extension UITableView {
  func  scrollToBottom(animated: Bool = true) {
    let sections = self.numberOfSections
    let rows = self.numberOfRows(inSection: sections - 1)
    if (rows > 0) {
      self.scrollToRow(at: NSIndexPath(row: rows - 1, section: sections - 1) as IndexPath, at: .bottom, animated: true)
    }
  }
}
