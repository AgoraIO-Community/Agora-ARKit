//
//  Broadcaster.swift
//  Arlene Live Streams
//
//  Created by Hermes on 2/6/20.
//  Copyright © 2020 Hermes. All rights reserved.
//

import UIKit
import AgoraRtcEngineKit

class Broadcaster : UIViewController, AgoraRtcEngineDelegate {
    
    var agoraKit: AgoraRtcEngineKit!        // Agora.io Video Engine reference
    var channelName: String!                // name of the channel to join
    
    var localVideoView: UIView!             // video stream of local camera
    var remoteVideoViews: [UInt:UIView] = [:]
    
    var dataStreamId: Int! = 27                         // id for data stream
    var streamIsEnabled: Int32 = -1                     // acts as a flag to keep track if the data stream is enabled
    
    // MARK: UI properties
    var micBtn: UIButton!
    var micBtnFrame: CGRect?
    var micBtnImage: UIImage?
    var micBtnTextLabel: String = "un-mute"
    var muteBtnImage: UIImage?
    var muteBtnTextLabel: String = "mute"
    
    var backBtn: UIButton!
    var backBtnFrame: CGRect?
    var backBtnImage: UIImage?
    var backBtnTextLabel: String = "x"
    
    let debug = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Add Agora setup
        guard let agoraAppID = AgoraARKit.agoraAppId else { return }
        let agoraKit = AgoraRtcEngineKit.sharedEngine(withAppId: agoraAppID, delegate: self) // - init engine
        agoraKit.setChannelProfile(.liveBroadcasting) // - set channel profile
        agoraKit.setClientRole(.broadcaster)
        self.agoraKit = agoraKit
        
        createUI()
        setupLocalVideo()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        joinChannel()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // do something when the view has appeared
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        leaveChannel();
    }
    
    // MARK: UI
    func createUI() {
        
        // add remote video view
        let localVideoView = UIView()
        localVideoView.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height)
        localVideoView.backgroundColor = UIColor.lightGray
        self.view.insertSubview(localVideoView, at: 0)
        self.localVideoView = localVideoView
        
        // mic button
        let micBtn = UIButton()
        if let micBtnFrame = self.micBtnFrame {
            micBtn.frame = micBtnFrame
        } else {
            micBtn.frame = CGRect(x: self.view.frame.midX-37.5, y: self.view.frame.maxY-100, width: 75, height: 75)
        }
        
        if let micBtnImage = self.micBtnImage {
            micBtn.setImage(micBtnImage, for: .normal)
        } else {
            micBtn.setTitle(muteBtnTextLabel, for: .normal)
        }
        micBtn.addTarget(self, action: #selector(toggleMic), for: .touchDown)
        self.view.insertSubview(micBtn, at: 2)
        self.micBtn = micBtn

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
        
        // add branded logo to remote view
        guard let agoraLogo = UIImage(named: "arlene-brandmark") else { return }
        let remoteViewBagroundImage = UIImageView(image: agoraLogo)
        remoteViewBagroundImage.frame = CGRect(x: localVideoView.frame.midX-56.5, y: localVideoView.frame.midY-100, width: 117, height: 126)
        remoteViewBagroundImage.alpha = 0.25
        localVideoView.insertSubview(remoteViewBagroundImage, at: 1)
    }

    // MARK: Button Events
    @IBAction func popView() {
        leaveChannel()
        self.dismiss(animated: true, completion: nil)
    }

    @IBAction func toggleMic() {
        if let activeMicImg = micBtnImage, let disabledMicImg = muteBtnImage {
            if self.micBtn.imageView?.image == activeMicImg {
                self.micBtn.setImage(disabledMicImg, for: .normal)
                self.agoraKit.muteLocalAudioStream(true)
                if debug {
                    print("disable local mic")
                }
            } else {
                self.micBtn.setImage(activeMicImg, for: .normal)
                self.agoraKit.muteLocalAudioStream(false)
                if debug {
                    print("enable local mic")
                }
            }
        } else {
            if self.micBtn.titleLabel?.text == micBtnTextLabel {
                micBtn.setTitle(muteBtnTextLabel, for: .normal)
                if debug {
                    print("disable local mic")
                }
            } else {
                micBtn.setTitle(micBtnTextLabel, for: .normal)
                if debug {
                    print("enable local mic")
                }
            }
        }
    }
    
    // MARK: Agora Implementation
    func setupLocalVideo() {
        guard let localVideoView = self.localVideoView else { return }
       
        // enable the local video stream
        self.agoraKit.enableVideo()
        
        // Set video configuration
        let videoConfig = AgoraVideoEncoderConfiguration(size: AgoraVideoDimension840x480, frameRate: .fps15, bitrate: AgoraVideoBitrateStandard, orientationMode: .fixedPortrait)
        self.agoraKit.setVideoEncoderConfiguration(videoConfig)
        // Set up local video view
        let videoCanvas = AgoraRtcVideoCanvas()
        videoCanvas.uid = 0
        videoCanvas.view = localVideoView
        videoCanvas.renderMode = .hidden
        // Set the local video view.
        self.agoraKit.setupLocalVideo(videoCanvas)
        
        guard let videoView = localVideoView.subviews.first else { return }
        videoView.layer.cornerRadius = 25
    }
    
    func joinChannel() {
        // Set audio route to speaker
        self.agoraKit.setDefaultAudioRouteToSpeakerphone(true)
        // get the token - returns nil if no value is set
        let token = AgoraARKit.agoraToken
        // Join the channel
        self.agoraKit.joinChannel(byToken: token, channelId: self.channelName, info: nil, uid: 0) { (channel, uid, elapsed) in
          if self.debug {
              print("Successfully joined: \(channel), with \(uid): \(elapsed) secongs ago")
          }
        }
        UIApplication.shared.isIdleTimerDisabled = true     // Disable idle timmer
    }
    
    func leaveChannel() {
        UIApplication.shared.isIdleTimerDisabled = false    // Enable idle timer
        guard self.agoraKit != nil else { return }
        self.agoraKit.leaveChannel(nil)                     // leave channel and end chat
    }
    
    // MARK: Agora event handler
    func rtcEngine(_ engine: AgoraRtcEngineKit, remoteVideoStateChangedOfUid uid: UInt, state: AgoraVideoRemoteState, reason: AgoraVideoRemoteStateReason, elapsed: Int) {
        if state == .starting {
            lprint("firstRemoteVideoStarting for Uid: \(uid)", .Verbose)
        } else if state == .decoding {
            lprint("firstRemoteVideoDecoded for Uid: \(uid)", .Verbose)
            var remoteView: UIView
            if let existingRemoteView = self.remoteVideoViews[uid] {
                remoteView = existingRemoteView
            } else {
                remoteView = createRemoteView(remoteViews: self.remoteVideoViews, view: self.view)
            }
            let videoCanvas = AgoraRtcVideoCanvas()
            videoCanvas.uid = uid
            videoCanvas.view = remoteView
            videoCanvas.renderMode = .hidden
            agoraKit.setupRemoteVideo(videoCanvas)
            self.view.insertSubview(remoteView, at: 2)
            self.remoteVideoViews[uid] = remoteView

            // create the data stream
            self.streamIsEnabled = self.agoraKit.createDataStream(&self.dataStreamId, reliable: true, ordered: true)
            if debug {
                print("Data Stream initiated - STATUS: \(self.streamIsEnabled)")
            }

        }
    }

    func rtcEngine(_ engine: AgoraRtcEngineKit, didOfflineOfUid uid: UInt, reason: AgoraUserOfflineReason) {
        guard let remoteVideoView = self.remoteVideoViews[uid] else { return }
        remoteVideoView.removeFromSuperview() // remove the remote view from the super view
        self.remoteVideoViews.removeValue(forKey: uid) // remove the remote view from the dictionary
        adjustRemoteViews(remoteViews: self.remoteVideoViews, view: self.view)
    }


}
