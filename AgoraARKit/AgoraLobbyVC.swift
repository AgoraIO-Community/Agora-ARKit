//
//  AgoraLobby.swift
//  Agora-ARKit Framework
//
//  Created by Hermes Frangoudis on 1/14/20.
//  Copyright © 2020 Agora.io. All rights reserved.
//

import UIKit

/**
The `AgoraLobbyVC` is a `UIViewController` that provides a manged UIView that gives the user the ability to enter a channel name and choose their role as either a Broadcaster or Audience. Based on their selection an `ARBroadcaster` or `ARAudience` _ViewController_ is presented.
 - Note: All class methods can be extended or overwritten.
*/
open class AgoraLobbyVC: UIViewController  {

    var debug : Bool = false
    
    // UI properties
    /**
    The `UIImageView` containing the banner image vsible within the Lobby view
     */
    var banner: UIImageView?
    /**
    The `UIImage` representing the banner image vsible within the Lobby view.
     */
    var bannerImage: UIImage?
    /**
    The `CGRect` that is used as the `.frame` for the `banner`
     */
    var bannerFrame: CGRect?
    /**
    The `String` used to set the text value for the button that launches the ARBroadcaster
     */
    var broadcastBtnText: String = "Broadcast"
    /**
    The `UIColor` used to set the text color for the button that launches the ARBroadcaster
     */
    var broadcastBtnColor: UIColor = .systemBlue
    /**
    The `String` used to set the text value for the button that launches the ARAudience
     */
    var audienceBtnText: String = "Audience"
    /**
    The `UIColor` used to set the text color for the button that launches the ARAudience
     */
    var audienceBtnColor: UIColor = .systemGray
    /**
    The  `UITextField` used to set the set the Agora channel name
     */
    var userInput: UITextField!
    /**
    The `String` used to set the set the placeholder text value for the `userInput` text field
     */
    var textFieldPlaceholder: String = "Channel Name"
    
    
    // MARK: VC Events
    override open func loadView() {
        super.loadView()
        lprint("LobbyVC - loadView", .Verbose)
    }

    override open func viewDidLoad() {
        super.viewDidLoad()
        lprint("LobbyVC - viewDidLoad", .Verbose)
        createUI()
    }
    
    override open func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        lprint("LobbyVC - viewWillAppear", .Verbose)
        guard (AgoraARKit.agoraAppId != nil) else {
            fatalError("You msst include an Agora APP ID to use ARKitLive. Get your Agora App ID from: https://console.agora.io")
        }
    }
    
    override open func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        lprint("LobbyVC - viewDidAppear", .Verbose)
    }
    
    override open func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        lprint("LobbyVC - viewWillDisappear", .Verbose)
    }
    
    // dismiss the keyboard when user touches the view
    override open func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        lprint("touches began", .Verbose)
        self.view.endEditing(true)
    }

    // MARK: Create UI
    /**
    The `createUI()` method is used to generate the managed UI for the "Lbby", a view where hte user has the ability to enter a channel name and choose their role within the channel
     */
    open func createUI() {
        // add branded logo to remote view
        if let logoImage = self.bannerImage {
            let banner = UIImageView(image: logoImage)
            if let bannerFrame = self.bannerFrame {
                banner.frame = bannerFrame
            } else {
                 banner.frame = CGRect(x: self.view.center.x-100, y: self.view.center.y-275, width: 200, height: 200)
            }
            self.view.insertSubview(banner, at: 1)
        }
        
        // text input field
        let textField = UITextField()
        textField.frame = CGRect(x: self.view.center.x-150, y: self.view.center.y-40, width: 300, height: 40)
        textField.placeholder = textFieldPlaceholder
        textField.font = UIFont.systemFont(ofSize: 15)
        textField.borderStyle = UITextField.BorderStyle.roundedRect
        textField.autocorrectionType = UITextAutocorrectionType.no
        textField.keyboardType = UIKeyboardType.default
        textField.returnKeyType = UIReturnKeyType.done
        textField.clearButtonMode = UITextField.ViewMode.whileEditing;
        textField.contentVerticalAlignment = UIControl.ContentVerticalAlignment.center
        textField.delegate = self
        self.view.addSubview(textField)
        userInput = textField

        //  create button
        let createBtn = UIButton()
        createBtn.frame = CGRect(x: textField.frame.midX+12.5, y: textField.frame.maxY + 20, width: 100, height: 50)
        createBtn.backgroundColor = broadcastBtnColor
        createBtn.layer.cornerRadius = 5
        createBtn.setTitle(broadcastBtnText, for: .normal)
        createBtn.addTarget(self, action: #selector(createSession), for: .touchUpInside)
        self.view.addSubview(createBtn)
        
        // add the join button
        let joinBtn = UIButton()
        joinBtn.frame = CGRect(x: createBtn.frame.minX-125, y: createBtn.frame.minY, width: 100, height: 50)
        joinBtn.backgroundColor = audienceBtnColor
        joinBtn.layer.cornerRadius = 5
        joinBtn.setTitle(audienceBtnText, for: .normal)
        joinBtn.addTarget(self, action: #selector(joinSession), for: .touchUpInside)
        self.view.addSubview(joinBtn)
    }
    
    // MARK: Button Actions
    /**
       The `createSession` method is called whenever the user taps the _Broadcast_ button. Ovveride this method to implement a custom `ARBroadcaster`.
     */
    @IBAction open func createSession() {
        let arBroadcastVC: ARBroadcaster = ARBroadcaster()
        if let channelName = self.userInput.text {
            if channelName != "" {
                arBroadcastVC.channelName = channelName
                arBroadcastVC.modalPresentationStyle = .fullScreen
                self.present(arBroadcastVC, animated: true, completion: nil)
            } else {
               // TODO: add visible msg to user
               lprint("unable to launch a broadcast without a channel name")
            }
        }
    }
    
    /**
    The `joinSession` method is called whenever the user taps the _Audience_ button
     */
    @IBAction open func joinSession() {
        let arAudienceVC: ARAudience = ARAudience()
        if let channelName = self.userInput.text {
            if channelName != "" {
                arAudienceVC.channelName = channelName
                arAudienceVC.modalPresentationStyle = .fullScreen
                self.present(arAudienceVC, animated: true, completion: nil)
            } else {
               // TODO: add visible msg to user
               lprint("unable to join a broadcast without a channel name")
            }
        }
    }

}



