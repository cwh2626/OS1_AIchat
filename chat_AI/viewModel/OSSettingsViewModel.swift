//
//  OSSettingsViewModel.swift
//  chat_AI
//
//  Created by 조웅희 on 2023/05/11.
//

import Foundation
import RxSwift
import RxCocoa

class OSSettingsViewModel {
    
    let settingsitems = PublishRelay<[chatVO]>()
    
    let chatDAO = ChatHistoryDAO()
    var originalChatSysDataList: [chatVO]
    private let disposeBag = DisposeBag()
    
    func loadData() -> [chatVO] {
        return self.originalChatSysDataList
    }
    
    init() {
        self.originalChatSysDataList = self.chatDAO.getAllSysContent()
        
        settingsitems
            .subscribe(onNext: { [weak self] sysData in
                self?.sysContentSet(newSysDataList: sysData)
            })
            .disposed(by: disposeBag)
    }
    
    private func sysContentSet(newSysDataList: [chatVO]) {
        // 가입일은 오늘로 한다.
        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd HH:mm:ss.SSS"
        newSysDataList.forEach { newItem in
            if newItem.chatNum == 0 {
                var param = newItem
                
                param.time = df.string(from: Date())
                if self.chatDAO.create(param: param) {
                    print("데이터 생성 대성공")
                    NotificationCenter.default.post(name: .didChangeDB, object: nil)

                }
            } else if self.originalChatSysDataList.contains(where: { oldItem in
                return oldItem.chatNum == newItem.chatNum && oldItem.content != newItem.content
            }) {
                var param = newItem
                
                param.time = df.string(from: Date())
                if self.chatDAO.update(param: param) {
                    // 4-1 결과가 성공이면 데이터를 다시 읽어들여 테이블 뷰를 갱신하다.
                    print("데이터 수정 대성공")
                    NotificationCenter.default.post(name: .didChangeDB, object: nil)
                }
            }
        }
        
        // B 배열에 있는 chatNM 중 A 배열에 없는 chatNM을 찾음
        let uniqueChatNMArray = self.originalChatSysDataList.filter { oldItem in
            !newSysDataList.contains { newItem in
                newItem.chatNum == oldItem.chatNum
            }
        }
        
        if !uniqueChatNMArray.isEmpty {
            uniqueChatNMArray.forEach { deleteItem in
                if self.chatDAO.delete(number: deleteItem.chatNum) {
                    NotificationCenter.default.post(name: .didChangeDB, object: nil)
                    print("데이터 삭제 대성공")
                }
            }
        }
        
        self.originalChatSysDataList = self.chatDAO.getAllSysContent()
    }
}


