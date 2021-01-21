//
//  ARVideoSource.swift
//  Agora-ARKit Framework
//
//  Created by GongYuhua on 2018/1/11.
//  Edited by Hermes Frangoudis on 2020/1/15
//  Copyright © 2018 Agora. All rights reserved.
//

import UIKit
import AgoraRtcKit

/**
 A custom video source for the AgoraRtcEngine. This class conforms to the AgoraVideoSourceProtocol and is used to pass the AR pixel buffer as a video source of the Agora stream.
 */
public class ARVideoSource: NSObject, AgoraVideoSourceProtocol {
    public func captureType() -> AgoraVideoCaptureType { .camera }

    public func contentHint() -> AgoraVideoContentHint { .none }

    public var consumer: AgoraVideoFrameConsumer?
    public var rotation: AgoraVideoRotation = .rotationNone

    public func shouldInitialize() -> Bool { return true }

    public func shouldStart() { }

    public func shouldStop() { }

    public func shouldDispose() { }

    public func bufferType() -> AgoraVideoBufferType {
        return .pixelBuffer
    }

    func sendBuffer(_ buffer: CVPixelBuffer, timestamp: TimeInterval) {
        let time = CMTime(seconds: timestamp, preferredTimescale: 1000)
        consumer?.consumePixelBuffer(buffer, withTimestamp: time, rotation: rotation)
    }
}
