//
//  UIManager.swift
//  AgoraARKit
//
//  Created by Hermes Frangoudis on 2/19/20.
//  Copyright © 2020 Agora.io. All rights reserved.
//

import UIKit

func createRemoteView(remoteViews: [UInt:UIView], view: UIView) -> UIView {
   let offset = remoteViews.count
   let remoteViewScale = view.frame.width * 0.33
   let yPos = (remoteViewScale * CGFloat(offset)) + 25
   let remoteView = UIView()
   remoteView.frame = CGRect(x: view.frame.minX+15, y: view.frame.minY+yPos, width: remoteViewScale, height: remoteViewScale)
   remoteView.backgroundColor = UIColor.lightGray
   remoteView.layer.cornerRadius = 25
   remoteView.layer.masksToBounds = true
   return remoteView
}

func adjustRemoteViews(remoteViews: [UInt:UIView], view: UIView) {
    for (index, remoteViewDictRow) in remoteViews.enumerated() {
        let remoteView = remoteViewDictRow.value
        let offset = CGFloat(index)
        let remoteViewScale = remoteView.frame.width
        remoteView.frame.origin.y = (remoteViewScale * offset) + 25
    }
}
