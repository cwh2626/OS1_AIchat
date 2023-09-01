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
    private let ownedToken = BehaviorRelay<Double>(value: 0)
    private let usedToken = BehaviorRelay<Int>(value: 0)
    private let isExceedingLimitRelay = BehaviorRelay<Bool>(value: false)
    private let errorRelay = PublishRelay<Error>()
    
    private let maximumToken: Int
    private let limitToken: Double = 999999
    private let rewardedTokens: Double = 4000
    private let disposeBag = DisposeBag()
    private let repository = ChatRepository.shared
    
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSS"
        return formatter
    }()
    
    // 포맷된 토큰 값을 관찰하기 위한 Observable
    var formattedOwnedToken: Observable<String> {
        return ownedToken.map { [unowned self] in
            self.formatNumber($0)
        }
    }
    
    // 포맷된 사용한 토큰 값을 관찰하기 위한 Observable
    var formattedUsedTokenForLimitValueLabel: Observable<String> {
        return usedToken.map { tokenValue in
            "\(tokenValue)/\(self.maximumToken)"
        }
    }

    var formattedUsedTokenForLimitProgressBar: Observable<Float> {
        return usedToken.map { tokenValue in
            Float(tokenValue) / Float(self.maximumToken)
        }
    }

    // 토큰 충전 한계를 초과했는지 나타내는 값을 방출하는 Observable
    var isExceedingLimit: Observable<Bool> {
        return isExceedingLimitRelay.asObservable()
    }
    
    // ViewModel에서 발생하는 오류 이벤트를 방출하는 Observable
    var error: Observable<Error> {
        return errorRelay.asObservable()
    }
    
    init(){
        Environment.debugPrint_START()
        
        self.maximumToken = repository.getMixmumMessageToken()!
        
        self.ownedToken
            .map { $0 > self.limitToken - self.rewardedTokens }
            .bind(to: isExceedingLimitRelay)
            .disposed(by: disposeBag)
        
        Environment.debugPrint_END()
    }
    
    // MARK: - Functions
    private func formatNumber(_ num: Double) -> String {
        Environment.debugPrint_START()
        
        let absoluteNum = abs(num) // 절대값 변환
        let thousand = absoluteNum / 1000.0
        let million = absoluteNum / 1000000.0
        let result:String
        
        if million >= 1.0 {
            result = (num < 0 ? "-" : "") + (million.truncatingRemainder(dividingBy: 1.0) == 0 ? String(format: "%.0fM", million) : "\(million)M")
        } else if thousand >= 1.0 {
            result = (num < 0 ? "-" : "") + (thousand.truncatingRemainder(dividingBy: 1.0) == 0 ? String(format: "%.0fK", thousand) : "\(thousand)K")
        } else {
            result = "\(Int(num))"
        }
        
        Environment.debugPrint_END()
        return result
    }
    
    /// 이 함수는 Single<T> 타입의 observable을 처리
    /// Observable은 비동기적으로 동작하여 결과가 준비될 때까지 함수 실행을 기다릴 필요 없이
    /// 다른 작업을 계속 수행가능.
    /// 그래서, 클로저들 (`onSuccess` 및 `onFailure`)은
    /// 함수의 실행이 끝난 후에도 호출될 수 있으니,  `successHandler` 클로저에는
    /// `@escaping` 키워드가 필요
    private func handleTokenFetching<T>(_ observable: Single<T>, successHandler: @escaping (T) -> Void) {
        Environment.debugPrint_START()
        
        observable
            .subscribe(onSuccess: { value in
                successHandler(value)
            }, onFailure: { [weak self] error in
                self?.errorRelay.accept(error)
            })
            .disposed(by: disposeBag)
        
        Environment.debugPrint_END()
    }
    
    private func handleCompletion(_ completable: Completable, completionHandler: @escaping () -> Void) {
        Environment.debugPrint_START()
        
        completable
            .subscribe(
                onCompleted: {
                    completionHandler()
                },
                onError: { [weak self] error in
                    self?.errorRelay.accept(error)
                }
            )
            .disposed(by: disposeBag)
        
        Environment.debugPrint_END()
    }

    
    func fetchTokenInfo(isCalledFromSideMenuButton: Bool) {
        Environment.debugPrint_START()
        
        handleTokenFetching(repository.getOwnedToken()) { [weak self] value in
            self?.ownedToken.accept(value)
        }
        
        if isCalledFromSideMenuButton {
            // 사이드 메뉴 버튼에 의해 호출된 경우의 처리
            handleTokenFetching(repository.getCurrentMessageToken()) { [weak self] value in
                self?.usedToken.accept(value)
            }
        }
        
        Environment.debugPrint_END()
    }
    
    func addToken(tokens: Double){
        Environment.debugPrint_START()
        
        let newValue = self.ownedToken.value + tokens
        let updateTime = dateFormatter.string(from: Date())
        
        handleCompletion(repository.updateOwnedToken(ownedTokens: newValue, updateTime: updateTime)) { [weak self] in
            self?.ownedToken.accept(newValue)
        }
        
        Environment.debugPrint_END()
    }
}

