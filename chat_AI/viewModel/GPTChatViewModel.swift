//
//  GPTViewModel.swift
//  chat_AI
//
//  Created by 조웅희 on 2023/03/31.
//

import Foundation
import RxSwift
import RxCocoa

class GPTChatViewModel {
    private let apiUrl = "https://api.openai.com/v1/chat/completions"
    private let apiKey = Environment.gptAPIKey
    
    var ownedToken = BehaviorRelay<Double>(value: 0)
        
    let chatDAO = ChatHistoryDAO()
    var chatDataList: [chatVO]
    var chatMaximumTokens: Int
    var chatCurrentTokens = BehaviorRelay<Int>(value: 0)
    
    private var messages: [[String: String]] = []
    
    init() {
        self.ownedToken.accept(chatDAO.getOwnedToken()!)
        self.chatDataList = chatDAO.get(sysRole: true) + chatDAO.get(sysRole: false)
        self.chatMaximumTokens = chatDAO.getMixmumMessageToken()!
        self.chatCurrentTokens.accept(chatDAO.getCurrentMessageToken()!)

        chatDataList.forEach { body in
            self.addMessage(role: body.role, content: body.content)
        }
    }
    
    func initMessage() {
        self.chatDataList = chatDAO.get(sysRole: true) + chatDAO.get(sysRole: false)
        messages.removeAll()
        chatDataList.forEach { body in
            self.addMessage(role: body.role, content: body.content)
        }
    }
    
    func setCurrentMessageToken(tokens: Int, updateTime: String) -> Bool{
        if self.chatDAO.updateMessageToken(promptTokens: tokens, updateTime: updateTime) {
            
            print("토큰 데이터 업데이트 성공",updateTime)
            let newTotalTokens = self.chatDAO.getCurrentMessageToken()!
            self.chatCurrentTokens.accept(newTotalTokens)
            guard self.adjustOwnedToken(tokens: Double(newTotalTokens), isSubtractionMode: true) else {return false}
            return true
        }
        return false
    }
    
    func getAllMessages() -> [[String: String]]  {
        return messages
    }
 
    func removeLastMessage() {
        messages.removeLast()
    }
    
    func addMessage(role: ChatRoleType, content: String) {
        
        let message: [String: String] = [
            "role": role.desc(),
            "content": content
        ]
        messages.append(message)
    }
    
    func insertMessageIntoDatabase(messageData: chatVO) -> Bool {
        if self.chatDAO.create(param: messageData) {
            
            print("데이터 넣기 대성공")
            self.chatDataList = chatDAO.get(sysRole: true) + chatDAO.get(sysRole: false)
            return true
            
        }
        return false
    }
    
    func adjustOwnedToken(tokens: Double, isSubtractionMode: Bool = false) -> Bool{
        let astDateTime = DateFormatter()
        astDateTime.dateFormat = "yyyy-MM-dd HH:mm:ss.SSS"
        
        let totalTokens = isSubtractionMode ? ownedToken.value - tokens : ownedToken.value + tokens
        
        if self.chatDAO.updateOwnedToken(ownedTokens: totalTokens, updateTime: astDateTime.string(from: Date())) {
            
            print("보유 토큰 업데이트 성공",totalTokens)
            self.ownedToken.accept(self.chatDAO.getOwnedToken()!)
            print("보유 토큰 업데이트 성공후",self.chatDAO.getOwnedToken()!)
            return true
        }
        return false
    }
    
    func fetchGPT3Response(completion: @escaping (String?, finishReasonState?, Int?) -> Void) {
        let json: [String: Any] = [
            "model": "gpt-3.5-turbo",
            "messages": messages
        ]

        guard let jsonData = try? JSONSerialization.data(withJSONObject: json),
              let url = URL(string: apiUrl) else {
            completion(nil, nil, nil)
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = jsonData
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")

        print(#function, messages)

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                print("❌ Error: \(error?.localizedDescription ?? "Unknown error")")
                completion(nil, nil, nil)
                return
            }

            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                    if let choices = json["choices"] as? [[String: Any]],
                       let firstChoice = choices.first,
                       let message = firstChoice["message"] as? [String: Any],
                       let content = message["content"] as? String,
                       let finishReasonStr = firstChoice["finish_reason"] as? String,
                       let usage = json["usage"] as? [String: Any],
                       let totalTokens = usage["total_tokens"] as? Int {
                        
                        // 유니코드 디코딩
                        let jsonReadyString = "\"\(content)\""
                        if let decodedData = jsonReadyString.data(using: .utf8),
                           let decodedContent = try? JSONDecoder().decode(String.self, from: decodedData) {
                            completion(decodedContent, finishReasonState(rawValue: finishReasonStr), totalTokens)
                            return
                        } else {
                            completion(content, finishReasonState(rawValue: finishReasonStr), totalTokens)
                            return
                        }
                    }

                    // 오류 처리
                    if let error = json["error"] as? [String: Any],
                       let message = error["message"] as? String,
                       let code = error["code"] as? String {
                        print("API Error code:", code)
                        completion(message, finishReasonState(rawValue: code), 0)
                        return
                    }
                }
            } catch {
                print("❌ JSON parsing error: \(error.localizedDescription)")
                completion(nil, nil, nil)
            }
        }

        task.resume()
    }
}

enum finishReasonState: String {
    case stop = "stop"
    case length = "length"
    case contentFilter = "content_filter"
    case null = "null"
    case contextLengthExceeded = "context_length_exceeded"
    
    // 룰을 문자열로 변환해 주는 메소드
    func desc() -> String {
        switch self {
        case .stop:
            return "정상적으로 출력되었습니다."
        case .length:
            return "OS의 용량이 초과되어 더 이상 대화를\n나눌 수 없습니다.\n사이드 메뉴의 'Exit'을 눌러 초기화를 진행해주세요."
        case .contentFilter:
            return "응답 에러가 발생하였습니다.\n메시지를 다시 작성해 주시기 바랍니다."
        case .null: // API 응답이 아직 진행 중이거나 완료되지 않음
            return "응답 에러가 발생하였습니다.\n메시지를 다시 작성해 주시기 바랍니다."
        case .contextLengthExceeded: // 이 모델의 최대 컨텍스트 길이는 4097 토큰입니다. 그러나 당신의 메시지는 그 이상의 토큰을 생성했습니다. 메시지의 길이를 줄여주세요.
            return "모델의 최대 길이를 초과하였습니다. 메시지의 길이를 줄여주세요."
        }
    }
}
