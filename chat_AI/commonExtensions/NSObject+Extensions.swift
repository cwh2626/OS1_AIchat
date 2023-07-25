//
//  NSObject+Extensions.swift
//  chat_AI
//
//  Created by 조웅희 on 2023/07/25.
//

import Foundation

extension NSObject {
    func debugPrint_START(fileID: String = #fileID, function: String = #function, line: Int = #line) {
        #if DEBUG
        print("<== \(fileID) - \(function) - LINE:\(line) - START ==>")
        #endif
    }
    func debugPrint_END(fileID: String = #fileID, function: String = #function, line: Int = #line) {
        #if DEBUG
        print("<== \(fileID) - \(function) - LINE:\(line) - END ==>")
        #endif
    }
}
