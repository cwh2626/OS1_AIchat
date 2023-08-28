//
//  SideMenuViewModel.swift
//  chat_AI
//
//  Created by 조웅희 on 2023/08/28.
//

import Foundation
import RxSwift
import RxCocoa

/// 사이드메뉴  뷰모델
class SideMenuViewModel {
    // MARK: - Properties
    var tokenValue: BehaviorRelay<Double> = BehaviorRelay(value: 0)
    let repository = ChatRepository()
    
    init() {
        self.tokenValue.accept(repository.getOwnedToken()!)
    }
    
    // 포맷된 토큰 값을 관찰하기 위한 Observable
    var formattedTokenValue: Observable<String> {
        return tokenValue.map { [unowned self] in
            self.formatNumber($0)
        }
    }
    
    // MARK: - Functions
    private func formatNumber(_ num: Double) -> String {
        let absoluteNum = abs(num) // 절대값 변환
        let thousand = absoluteNum / 1000.0
        let million = absoluteNum / 1000000.0
        
        if million >= 1.0 {
            return (num < 0 ? "-" : "") + (million.truncatingRemainder(dividingBy: 1.0) == 0 ? String(format: "%.0fM", million) : "\(million)M")
        } else if thousand >= 1.0 {
            return (num < 0 ? "-" : "") + (thousand.truncatingRemainder(dividingBy: 1.0) == 0 ? String(format: "%.0fK", thousand) : "\(thousand)K")
        } else {
            return "\(Int(num))"
        }
    }
    
    func addToken(tokens: Double) -> Bool{
        let astDateTime = DateFormatter()
        astDateTime.dateFormat = "yyyy-MM-dd HH:mm:ss.SSS"
        
        let newValue = self.tokenValue.value + tokens
        
        if self.repository.updateOwnedToken(ownedTokens: newValue, updateTime: astDateTime.string(from: Date())) {
            self.tokenValue.accept(newValue)
            return true
        }
        return false
    }
}

