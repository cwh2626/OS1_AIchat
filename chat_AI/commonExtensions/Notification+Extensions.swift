//
//  Notification+Extensions.swift
//  chat_AI
//
//  Created by 조웅희 on 2023/06/07.
//

import UIKit

extension Notification.Name {
    static let childViewControllerDidAppear = Notification.Name("childViewControllerDidAppear")
    static let childViewControllerDidDisappear = Notification.Name("childViewControllerDidDisappear")
    static let didChangeDB = NSNotification.Name("didChangeDB")
    
}
