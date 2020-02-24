//
//  ARBroadcaster+RenderARDelegate.swift
//  Agora-ARKit Framework
//
//  Created by Hermes Frangoudis on 1/15/20.
//  Copyright © 2020 Agora.io. All rights reserved.
//

import ARVideoKit
import CoreMedia
/**
 `ARBroadcaster` implements the `RenderARDelegate` from ARVideoKit to pass the composited rendered frame to the active Agora stream as the custom video source.
 */
extension ARBroadcaster: RenderARDelegate {
    // MARK: ARVidoeKit Renderer
    open func frame(didRender buffer: CVPixelBuffer, with time: CMTime, using rawBuffer: CVPixelBuffer) {
        self.arVideoSource.sendBuffer(buffer, timestamp: time.seconds)
    }
}

