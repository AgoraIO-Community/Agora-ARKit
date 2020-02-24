//
//  ARBroadcaster.swift
//  Agora-ARKit Framework
//
//  Created by Hermes Frangoudis on 1/14/20.
//  Copyright © 2020 Agora.io. All rights reserved.
//

import UIKit
import ARKit
import AgoraRtcEngineKit
import ARVideoKit
import Foundation

open class ARBroadcaster: UIViewController {
    
    // MARK: ARKit properties
    /**
    A reference to the `ARSCNView`
     */
    var sceneView: ARSCNView!
    /**
    The `ARWorldTrackingConfiguration`'s setting for plane detection
     
     Defaults to `nil`
     */
    var planeDetection: ARWorldTrackingConfiguration.PlaneDetection?
    /**
        Setting to enable default lighting within the ARSCNView
     */
    open var enableDefaultLighting: Bool = true
    /**
       Setting to update lighting information within the ARSCNView
    */
    open var autoUpdateLights: Bool = true
    /**
       Setting to enable light estimation within the `ARTrackingConfiguration`
    */
    open var lightEstimation: Bool = true
    /**
       Debug option for the `ARTrackingConfiguration` to display render stats
    */
    open var showStatistics: Bool = true
    /**
       Debug option  for the `ARTrackingConfiguration` to display debug data
    */
    open var arSceneDebugOptions: SCNDebugOptions = [.showWorldOrigin, .showFeaturePoints]
    
    // MARK: Agora Properties
    /**
    A reference to the `AgoraRtcEngineKit`
     */
    var agoraKit: AgoraRtcEngineKit!                    // Agora.io Video Engine reference
    var arVideoSource: ARVideoSource = ARVideoSource()  // for passing the AR camera as the stream
    var channelProfile: AgoraChannelProfile = .liveBroadcasting
    var frameRate: AgoraVideoFrameRate = .fps30
    var videoDimension: CGSize = AgoraVideoDimension1280x720
    var videoBitRate: Int = AgoraVideoBitrateStandard
    var videoOutputOrientationMode: AgoraVideoOutputOrientationMode = .fixedPortrait
    var audioSampleRate: UInt = 44100
    var audioChannelsPerFrame: UInt = 1
    var defaultToSpeakerPhone: Bool = true
    var channelName: String!                            // name of the channel to join
    
    // MARK: ARVideoKit properties
    var arvkRenderer: RecordAR!                         // ARVideoKit Renderer - used as an off-screen renderer
    
    // MARK: UI properties
    /**
    A Dictionary of `UIView`s representing the video streams of the host users
     */
    var remoteVideoViews: [UInt:UIView] = [:]    // Dictionary of remote views
    /**
    A `UIButton` that toggles the microphone
     */
    var micBtn: UIButton!
    var micBtnFrame: CGRect?
    var micBtnImage: UIImage?
    var micBtnTextLabel: String = "un-mute"
    var muteBtnImage: UIImage?
    var muteBtnTextLabel: String = "mute"
    /**
    A `UIButton` that dismisses the view controller when tapped
     */
    var backBtn: UIButton!
    var backBtnFrame: CGRect?
    var backBtnImage: UIImage?
    var backBtnTextLabel: String = "x"
    
    /**
    An optional `UIImageView` that displays a watermark over part of the video.
     */
    var watermark: UIImageView?
    var watermarkImage: UIImage?
    var watermarkFrame: CGRect?
    var watermarkAlpha: CGFloat = 0.25
    
    var viewBackgroundColor: UIColor = .black
    
    
    // Debugging
    internal let debug: Bool = false                             // toggle the debug logs
    var showLogs: Bool = true
    
    // MARK: VC Events
    /**
    AgoraARKit uses the `viewDidLoad` method to create the UI, set up the Agora engine configuration, set the `ARSCNViewDelegate` / `ARSessionDeleagates`,  set up the off screen renderer and configure the SceneView's
     */
    override open func viewDidLoad() {
        super.viewDidLoad()
        print("viewDidLoad")
        
        self.view.backgroundColor = viewBackgroundColor
        createUI()
        
        // Agora setup
        guard let agoraAppID = AgoraARKit.agoraAppId else { return }
        let agoraKit = AgoraRtcEngineKit.sharedEngine(withAppId: agoraAppID, delegate: self) // - init engine
        agoraKit.setChannelProfile(channelProfile) // - set channel profile
        if channelProfile == .liveBroadcasting {
            agoraKit.setClientRole(.broadcaster)
        }
        let videoConfig = AgoraVideoEncoderConfiguration(size: videoDimension, frameRate: frameRate, bitrate: videoBitRate, orientationMode: videoOutputOrientationMode)
        agoraKit.setVideoEncoderConfiguration(videoConfig) // - set video encoding configuration (dimensions, frame-rate, bitrate, orientation
        agoraKit.enableVideo() // - enable video
        agoraKit.setVideoSource(self.arVideoSource) // - set the video source to the custom AR source
//        agoraKit.enableExternalAudioSource(withSampleRate: audioSampleRate, channelsPerFrame: audioChannelsPerFrame) // - enable external audio souce (since video and audio are coming from seperate sources)
        agoraKit.enableWebSdkInteroperability(true)
        self.agoraKit = agoraKit // set a reference to the Agora engine

        // set render delegate
        self.sceneView.delegate = self
        self.sceneView.session.delegate = self

        // setup ARViewRecorder
        self.arvkRenderer = RecordAR(ARSceneKit: self.sceneView)
        self.arvkRenderer?.renderAR = self // Set the renderer's delegate
        // Configure the renderer to always render the scene
        self.arvkRenderer?.onlyRenderWhileRecording = false
        // Configure ARKit content mode. Default is .auto
        self.arvkRenderer?.contentMode = .aspectFill
        // add environment light during rendering
        self.arvkRenderer?.enableAdjustEnvironmentLighting = lightEstimation
        // Set the UIViewController orientations
        self.arvkRenderer?.inputViewOrientations = [.portrait]
        self.arvkRenderer?.enableAudio = false
        // TODO: create enum to translate between Agora Orientation and ARVideoKit

        if debug {
           self.sceneView.debugOptions = arSceneDebugOptions
           self.sceneView.showsStatistics = showStatistics
        }
       
        // add default lights to the scene
        self.sceneView.autoenablesDefaultLighting = enableDefaultLighting
        self.sceneView.automaticallyUpdatesLighting = autoUpdateLights
   }

    /**
     AgoraARKit sets up and runs the ARTracking configuration within the `viewWillAppear`
     */
    override open func viewWillAppear(_ animated: Bool) {
        super .viewWillAppear(animated)
        print("viewWillAppear")        // Configure ARKit Session

    }
    
    /**
    AgoraARKit joins the Agora channel within the `viewDidAppear`
    */
    override open func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        print("viewDidAppear")
        if AgoraARKit.agoraAppId == nil {
            popView()
        } else {
            self.setARConfiguration()
            joinChannel() // Agora - join the channel
        }
        
    }
    
    /**
    AgoraARKit pauses the AR session within the `viewWillDisappear`
    */
    override open func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        print("viewWillDisappear")
        // Cleanup the session as the view is removed from heirarchy
        self.sceneView.session.pause()
    }
    
    /**
    Since Apple does not provide explicit de-initializers for the ARSCN, AgoraARKit use `viewDidDisappear` to free up resources and clean up the SceneView references.
    */
    override open func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        print("viewDidDisappear")
        sceneView.removeFromSuperview()
        sceneView = nil
    }
    
    // MARK: Hide status bar
    /**
    AgoraARKit hides the status bar UI
    */
    override open var prefersStatusBarHidden: Bool {
        return true
    }
    
    // MARK: Agora Interface
    /**
    Conencts to the Agora channel, and sets the default audio route to speakerphone
    */
    open func joinChannel() {
        // Set audio route to speaker
        // TODO: remove if statement once Agora iPhone X audio bug is resolved
        let screenMaxLength = max(UIScreen.main.bounds.size.width, UIScreen.main.bounds.size.height)
        if UIDevice.current.userInterfaceIdiom == .phone && (screenMaxLength >= 896.0 && screenMaxLength <= 1024) {
            self.agoraKit.setDefaultAudioRouteToSpeakerphone(defaultToSpeakerPhone)
        }
        // Join the channel
        self.agoraKit.joinChannel(byToken: AgoraARKit.agoraToken, channelId: self.channelName, info: nil, uid: 0)
        UIApplication.shared.isIdleTimerDisabled = true     // Disable idle timmer
    }
    
    open func leaveChannel() {
        UIApplication.shared.isIdleTimerDisabled = false
        guard self.agoraKit != nil else { return }
        // leave channel and end chat
        self.agoraKit.leaveChannel()
    }
    
    // MARK: UI
    /**
     Programmatically generated UI, creates the SceneView, and buttons.
     */
    open func createUI() {
        // Setup sceneview
        let sceneView = ARSCNView() //instantiate scene view
        self.view.insertSubview(sceneView, at: 0)
        
        //add sceneView layout contstraints
        sceneView.translatesAutoresizingMaskIntoConstraints = false
        sceneView.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
        sceneView.leftAnchor.constraint(equalTo: self.view.leftAnchor).isActive = true
        sceneView.rightAnchor.constraint(equalTo: self.view.rightAnchor).isActive = true
        sceneView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
        // set reference to sceneView
        self.sceneView = sceneView
        
        // add branded logo to view
        if let watermarkImage = self.watermarkImage {
            let watermark = UIImageView(image: watermarkImage)
            watermark.contentMode = .scaleAspectFit
            if let watermarkFrame = self.watermarkFrame {
                watermark.frame = watermarkFrame
            } else {
                watermark.frame = CGRect(x: self.view.frame.maxX-200, y: self.view.frame.maxY-200, width: 150, height: 150)
            }
            watermark.alpha = watermarkAlpha
            self.view.insertSubview(watermark, at: 2)
            self.watermark = watermark
        }

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
    }
    
    open func setARConfiguration() {
        let configuration = ARWorldTrackingConfiguration()
        if let planeDetection = self.planeDetection {
            configuration.planeDetection = planeDetection
        }
        // TODO: Enable Audio Data when iPhoneX bug is resolved
//        configuration.providesAudioData = true  // AR session needs to provide the audio data
        configuration.isLightEstimationEnabled = lightEstimation
        // run the config to start the ARSession
        self.sceneView.session.run(configuration)
        self.arvkRenderer?.prepare(configuration)
    }
    
    // MARK: Button Events
    /**
     Dismiss the current view
     */
    @IBAction func popView() {
        leaveChannel()
        self.dismiss(animated: true, completion: nil)
    }
    
    /**
     Local mirophone control for setting mute or enabled states.
     */
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
    
}
