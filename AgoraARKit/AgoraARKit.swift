//
//  AgoraARKit.swift
//  Agora-ARKit Framework
//
//  Created by Hermes Frangoudis on 1/15/20.
//  Copyright © 2020 Agora.io. All rights reserved.
//

import Foundation

/**
The `AgoraARKit` object provides static properties to be used when initializing the Agora engine
*/
public class AgoraARKit {
    /**
     The `agoraAppId` is a static value that is used to connect to the Agora.io service. Get your Agora App Id from https://console.agora.io
     
     ```swift
     AgoraARKit.agoraAppId = "<Your Agora APP ID>"
     ```
     
     - Note: the `agoraAppId` can be set within the `AppDelegate` or within any `ViewController`, the only requirement is that the `agoraAppId` is set before joining a channel. This takes place within the `viewWillAppear` fucntion for both `ARBroadcaster` or `ARAudience` _ViewControllers_
     - Warning: This value defaults to nil, and will throw a runtime error if not set.
     */
    static var agoraAppId: String!
    
    /**
     The `agoraToken` is a static value that is used to as the user's channel token. You can set either a dynamic token or a temp token. Generate a temp token usic https://console.agora.io. Default is `nil`
     
    
     ```swift
     AgoraARKit.agoraToken = "<Your Agora Token>"
     ```
     
     - Note: The `agoraToken` can be set within the `AppDelegate` or within any `ViewController`, the only requirement is that the `agoraToken`is set before joining a channel. This takes place within the `viewWillAppear` fucntion for both `ARBroadcaster` or `ARAudience` _ViewControllers_
     - Warning: You must set a token if you have enabled the certificate on the channel.
      - If you have not enabled certificate security on your AppiId, then you do not need to set this value.
     */
    static var agoraToken: String?
}

