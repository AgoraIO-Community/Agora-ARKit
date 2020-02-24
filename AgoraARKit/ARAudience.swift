//
//  ARAudience.swift
//  Agora-ARKit Framework
//
//  Created by Hermes Frangoudis on 1/14/20.
//  Copyright © 2020 Agora.io. All rights reserved.
//

import UIKit
import AgoraRtcEngineKit

/**
The `ARAudience` is a `UIViewController` that implements all the needed methods for the viewer (aundience member)  of the AR Live Stream. The class provides a manged UI for the audience user.
 - Note: All class methods can be extended or overwritten.
*/
open class ARAudience: UIViewController {
    
    // MARK: Agora properties
    /**
    A reference to the `AgoraRtcEngineKit`
     */
    var agoraKit: AgoraRtcEngineKit!
    /**
    The `ARVideoSource` object used to pass the AR content to the video stream
     */
    var arVideoSource: ARVideoSource = ARVideoSource()  // for passing the AR camera as the stream
    /**
    Sets the [AgoraChannelProfile](https://docs.agora.io/en/Video/API%20Reference/oc/Constants/AgoraChannelProfile.html).
    
     Defaults to `.liveBroadcasting`
     */
    var channelProfile: AgoraChannelProfile = .liveBroadcasting
    /**
    Flag to determine whether the device enable to speaker mode when entering the channel
     
     Defaults to `true`
     */
    var defaultToSpeakerPhone: Bool = true
    /**
    Name of the channel to use when connecting to an Agora channel.
     
     - Note: Defaults to `nil`
     - Warning: This value must be set before the ViewController is presented.
    */
    var channelName: String!
    /**
    A reference to the host user.
     */
    var remoteUser: UInt?                       // remote user id
    
    // MARK: UI properties
    /**
    A `UIView` representing the video stream of the host user
     */
    var remoteVideoView: UIView!                // video stream from remote user
    
    /**
    A Dictionary of `UIView`s representing the video streams of the host users
     */
    var remoteVideoViews: [UInt:UIView] = [:]    // Dictionary of remote views
    /**
    The `remoteViewBackgroundColor` is the background color for the UIView until the remote video stream is received.
     
     Defaults to `.lightGray`
     */
    var remoteViewBackgroundColor: UIColor = .lightGray
    /**
    A `UIButton` that dismisses the view controller when tapped
     */
    var backBtn: UIButton!
    /**
    A `CGRect` that represents the frame for the `backBtn`.
    - Note: If a value is not explicitly set, the managed UI will uses default settings
     */
    var backBtnFrame: CGRect?
    /**
    An optional `UIImage` that is used as the image for the `backBtn`
     */
    var backBtnImage: UIImage?
    /**
    The default value to display if an image is not set for the `backBtn`
     */
    var backBtnTextLabel: String = "x"
    /**
    An optional `UIImageView` that displays a watermark over part of the video.
     */
    var watermark: UIImageView?
    /**
    An optional `UIImage` that is used as the image for the `watermark`
     - Warning: If this value is not set, then a watermark will not be displayed.
     */
    var watermarkImage: UIImage?
    /**
    A `CGRect` that represents the frame for the `watermark`,
     - Note: If a `watermarkImage` is set but `watermarkFrame` is not explicitly set, the managed UI will uses default settings
     */
    var watermarkFrame: CGRect?
    /**
    A `CGFloat` that represents the transparency of the `watermark`
     */
    var watermarkAlpha: CGFloat = 0.25
    
    // Debugging
    var showLogs: Bool = true
    internal let debug: Bool = true
    
    // MARK: VC Events

    /**
    AgoraARKit uses the `viewDidLoad` method to create the UI and set up the Agora engine configuration
     */
    override open func viewDidLoad() {
        super.viewDidLoad()
        lprint("AudienceVC - viewDidLoad", .Verbose)
        createUI()
        guard let agoraAppID = AgoraARKit.agoraAppId else { return }
        // Add Agora setup
        let agoraKit = AgoraRtcEngineKit.sharedEngine(withAppId: agoraAppID, delegate: self) // - init engine
        agoraKit.setChannelProfile(channelProfile) // - set channel profile
        if channelProfile == .liveBroadcasting {
            agoraKit.setClientRole(.audience)
        }
        self.agoraKit = agoraKit
    }
    
    /**
    AgoraARKit joins the Agora channel within the `viewDidAppear`
    */
    override open func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        lprint("AudienceVC - viewDidAppear", .Verbose)
        // do something when the view has appeared
        if AgoraARKit.agoraAppId == nil {
            popView()
        } else {
            joinChannel() // Agora - join the channel
        }
    }

    // MARK: Hide status bar
    override open var prefersStatusBarHidden: Bool {
       return true
    }
    
    // MARK: Agora Interface
    /**
    Conencts to the Agora channel, and sets the default audio route to speakerphone
    */
    open func joinChannel() {
        // Set audio route to speaker
        self.agoraKit.setDefaultAudioRouteToSpeakerphone(defaultToSpeakerPhone)
        // Join the channel
        self.agoraKit.joinChannel(byToken: AgoraARKit.agoraToken, channelId: self.channelName, info: nil, uid: 0) 
        UIApplication.shared.isIdleTimerDisabled = true     // Disable idle timmer
    }
    
    open func leaveChannel() {
        lprint("leaveChannel", .Verbose)
        UIApplication.shared.isIdleTimerDisabled = false
        guard self.agoraKit != nil else { return }
        // leave channel and end chat
        self.agoraKit.leaveChannel(nil)
    }
    
    // MARK: UI
    /**
     Programmatically generated UI, creates the view, and buttons.
     */
    open func createUI() {
        lprint("createUI", .Verbose)
        // add remote video view
        let remoteView = UIView()
        remoteView.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height)
        remoteView.backgroundColor = remoteViewBackgroundColor
        remoteView.contentMode = .scaleAspectFit
        self.view.insertSubview(remoteView, at: 1)
        self.remoteVideoView = remoteView
        
        // add branded logo to view
        if let watermarkImage = self.watermarkImage {
            let watermark = UIImageView(image: watermarkImage)
            watermark.contentMode = .scaleAspectFit
            if let watermarkFrame = self.watermarkFrame {
                watermark.frame = watermarkFrame
            } else {
                watermark.frame = CGRect(x: self.view.frame.maxX-100, y: self.view.frame.maxY-100, width: 75, height: 75)
            }
            watermark.alpha = watermarkAlpha
            self.view.insertSubview(watermark, at: 2)
            self.watermark = watermark
        }
        
        //  back button
        let backBtn = UIButton()
        if let backBtnFrame = self.backBtnFrame {
            backBtn.frame = backBtnFrame
        } else {
            backBtn.frame = CGRect(x: self.view.frame.maxX-55, y: self.view.frame.minY + 20, width: 30, height: 30)
        }
        if let backBtnImage = self.backBtnImage {
            backBtn.setImage(backBtnImage, for: .normal)
        } else {
            backBtn.setTitle(backBtnTextLabel, for: .normal)
        }
        backBtn.addTarget(self, action: #selector(popView), for: .touchUpInside)
        self.view.insertSubview(backBtn, at: 2)
    }
    
    // MARK: Button Events
    /**
     Dismiss the current view
     */
    @IBAction func popView() {
        leaveChannel()
        self.dismiss(animated: true, completion: nil)
    }
}
