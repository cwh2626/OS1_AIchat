//
//  OSSettingsViewModelToRxSwift.swift
//  chat_AI
//
//  Created by 조웅희 on 2023/09/04.
// 개선점! NO.01 : 설정화면에서 데이터를 추가하면 채팅방의 메시지 데이터에 적용하는 방식을 현재 노티피케이션으로 하고있다.
// 이 방법보다는 채팅방의 메시지를 보낼때 sys데이터가 최신데이터인지 업데이트타임으로 체크후 데이터 업데이트유무를 판단하는게 더 효율적으로 보인다 추후 개선을 해보자

import Foundation
import RxSwift
import RxCocoa

/// OS1 행동 및 성격 설정 페이지 뷰모델
class OSSettingsViewModelToRxSwift {
    
    // MARK: - Properties
    let settingsitems = PublishRelay<[Chat]>()
    
    private var originalChatSysDataList: [Chat]
    private let repository = ChatRepository.shared
    
    private let changedSysData = BehaviorRelay<[Chat]>(value: [])
    private let originalSysData: [Chat]

    private let disposeBag = DisposeBag()
    
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSS"
        return formatter
    }()
        
    // MARK: - Initializer
    
    init() {
        Environment.debugPrint_START()
        
        self.originalSysData = self.repository.getAllSysContent()
        self.originalChatSysDataList = self.repository.getAllSysContent()
        
        settingsitems
            .subscribe(onNext: { [weak self] sysData in
                self?.sysContentSet(newSysDataList: sysData)
            })
            .disposed(by: disposeBag)
        
        Environment.debugPrint_END()
    }
    
    // MARK: - Functions

    func loadData() -> [Chat] {
        return self.originalChatSysDataList
    }
    
    private func sysContentSet(newSysDataList: [Chat]) {
        Environment.debugPrint_START()
        
        newSysDataList.forEach { newItem in
            if newItem.chatNum == 0 {
                var param = newItem
                
                param.time = dateFormatter.string(from: Date())
                if self.repository.create(param: param) {
                    // 개선점! NO.01
                    NotificationCenter.default.post(name: .didChangeDB, object: nil)

                }
            } else if self.originalChatSysDataList.contains(where: { oldItem in
                return oldItem.chatNum == newItem.chatNum && oldItem.content != newItem.content
            }) {
                var param = newItem
                
                param.time = dateFormatter.string(from: Date())
                if self.repository.update(param: param) {
                    // 개선점! NO.01
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
                if self.repository.delete(number: deleteItem.chatNum) {
                    // 개선점! NO.01
                    NotificationCenter.default.post(name: .didChangeDB, object: nil)
                }
            }
        }
        
        self.originalChatSysDataList = self.repository.getAllSysContent()
        
        Environment.debugPrint_END()
    }
}

