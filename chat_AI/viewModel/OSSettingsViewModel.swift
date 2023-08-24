//
//  OSSettingsViewModel.swift
//  chat_AI
//
//  Created by 조웅희 on 2023/05/11.
//
// 개선점! NO.01 : 설정화면에서 데이터를 추가하면 채팅방의 메시지 데이터에 적용하는 방식을 현재 노티피케이션으로 하고있다.
// 이 방법보다는 채팅방의 메시지를 보낼때 sys데이터가 최신데이터인지 업데이트타임으로 체크후 데이터 업데이트유무를 판단하는게 더 효율적으로 보인다 추후 개선을 해보자

import Foundation
import RxSwift
import RxCocoa

/// OS1 행동 및 성격 설정 페이지 뷰모델
class OSSettingsViewModel {
    
    // MARK: - Properties

    let settingsitems = PublishRelay<[Chat]>()
    private let chatRepository: ChatRepository
    private var originalChatSysDataList: [Chat]
    private let disposeBag = DisposeBag()
        
    // MARK: - Initializer
    
    init(repository: ChatRepository) {
        Environment.debugPrint_START()
        
        self.chatRepository = repository
        self.originalChatSysDataList = self.chatRepository.getAllSysContent()
        
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

        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd HH:mm:ss.SSS"
        
        newSysDataList.forEach { newItem in
            if newItem.chatNum == 0 {
                var param = newItem
                
                param.time = df.string(from: Date())
                if self.chatRepository.create(param: param) {
                    // 개선점! NO.01
                    NotificationCenter.default.post(name: .didChangeDB, object: nil)

                }
            } else if self.originalChatSysDataList.contains(where: { oldItem in
                return oldItem.chatNum == newItem.chatNum && oldItem.content != newItem.content
            }) {
                var param = newItem
                
                param.time = df.string(from: Date())
                if self.chatRepository.update(param: param) {
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
                if self.chatRepository.delete(number: deleteItem.chatNum) {
                    // 개선점! NO.01
                    NotificationCenter.default.post(name: .didChangeDB, object: nil)
                }
            }
        }
        
        self.originalChatSysDataList = self.chatRepository.getAllSysContent()
        
        Environment.debugPrint_END()
    }
}
