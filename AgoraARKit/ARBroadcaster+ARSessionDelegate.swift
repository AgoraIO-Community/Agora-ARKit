//
//  ARBroadcaster+ARSessionDelegate.swift
//  Agora-ARKit Framework
//
//  Created by Hermes Frangoudis on 1/15/20.
//  Copyright © 2020 Agora.io. All rights reserved.
//

import ARKit
/**
 `ARBroadcaster` implements the `ARSessionDelegate` and uses the `didOutputAudioSampleBuffer` callback to pass the audio data provided by the ARKit session to the active Agora stream as part of the custom audio source*
 */
extension ARBroadcaster: ARSessionDelegate {
    
    open func session(_ session: ARSession, didUpdate frame: ARFrame) {
        // updated every frame.
    }
    
    open func session(_ session: ARSession, didOutputAudioSampleBuffer audioSampleBuffer: CMSampleBuffer) {
        guard self.agoraKit != nil else { return }
        self.agoraKit.pushExternalAudioFrameSampleBuffer(audioSampleBuffer)
    }
    
    open func session(_ session: ARSession, didFailWithError error: Error) {
        lprint("session failed with error: \(error)", .Verbose)
    }
    
    open func sessionWasInterrupted(_ session: ARSession) {
        lprint("sessionWasInterrupted", .Verbose)
    }
}
