//
//  Chat.swift
//  chat_AI
//
//  Created by 조웅희 on 2023/04/14.
//

enum ChatRoleType: Int {
    case SYS = 0, AST, USER // 순서대로 시스템(0), AI(1), 사용자(2)
    
    // 룰을 문자열로 변환해 주는 메소드
    func desc() -> String {
        switch self {
        case .SYS:
            return "system"
        case .AST:
            return "assistant"
        case .USER:
            return "user"
        }
    }
}

struct Chat {
    var chatNum = 0 // 채팅 넘버
    var role = ChatRoleType.SYS // 채팅 룰
    var content = "" // 채팅 내용
    var time = "" // 채팅 시간
}
