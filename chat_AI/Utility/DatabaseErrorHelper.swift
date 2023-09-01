//
//  DatabaseErrorHelper.swift
//  chat_AI
//
//  Created by 조웅희 on 2023/09/01.
//

import Foundation

class DatabaseErrorHelper {
    static func dataNotFoundError() -> NSError {
        return NSError(domain: "DatabaseError", code: 1000, userInfo: ["description": "Data not found"])
    }
}
