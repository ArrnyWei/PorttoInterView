//
//  GlobalMethods.swift
//  NextDriveAppSDK_iOS
//
//  Created by Ming on 2019/08/08.
//  Copyright © 2019 Ming. All rights reserved.
//

import UIKit

enum QueueDispatch {
    case sync
    case async
}

func ensureInMainQueue(dispatch: QueueDispatch = .async, _ block: @escaping () -> Void) {
    if Thread.isMainThread { block() } else {
        if dispatch == .async {
            DispatchQueue.main.async { block() }
        } else {
            DispatchQueue.main.sync { block() }
        }
    }
}
