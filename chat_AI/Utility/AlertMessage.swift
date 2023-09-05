//
//  AlertMessage.swift
//  chat_AI
//
//  Created by 조웅희 on 2023/09/05.
//

enum AlertMessage: String {
    case unknownError = "알 수 없는 문제가 발생했습니다. 잠시 후에 다시 시도해 주세요."
    case leaveChatroom = "채팅방을 나가면 대화 내용이 모두 삭제됩니다.\n정말 나가시겠습니까?"
    case adPreparing = "광고가 준비 중입니다. 잠시 후에 다시 시도해 주시기 바랍니다."
    case exceededAllowedLimit = "허용된 토큰 보유 한도를 초과했습니다."
    case databaseError = "데이터베이스 오류가 발생하였습니다. 앱을 재시작해 주세요."
    case adError = "광고 중 에러가 발생했습니다. 앱을 재시작해 주세요."
    case promptForChatStart = "대화를 시작하려면 메시지를 입력해주세요."
    case insufficientTokens = "토큰이 부족해요. 토큰을 충전해주세요."
    case maxCardLimitReached = "설정 카드는 최대 5개까지만\n추가하실 수 있습니다."
        
    // 기타 다른 메시지들 추가...
}
