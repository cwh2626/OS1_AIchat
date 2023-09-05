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

    private let generalErrorRelay = PublishRelay<Error>()
    private let adErrorRelay = PublishRelay<Error>()
    private let changeRootVCRelay = PublishRelay<Void>()
    
    /// `private(set)`은 프로퍼티의 설정자에 대한 접근을 제한하는 접근 제어자입니다.
    /// 이를 사용하면 해당 프로퍼티는 외부에서 읽기만 가능하며, 수정은 해당 클래스나 구조체 내부에서만 가능하게 됩니다.
    /// 이 방식은 프로퍼티의 값을 외부에서 변경하지 못하게 보호하면서, 내부 로직에서는 변경이 필요할 때 활용할 수 있습니다.
    private(set) var maximumToken: Int?
    
    private let limitToken: Double = 999999
    private let rewardedTokens: Double = 4000
    private let disposeBag = DisposeBag()
    private let repository: ChatRepository
    
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSS"
        return formatter
    }()
    
    // MARK: - Observables
    var formattedOwnedToken: Observable<String> {
        return ownedToken.map { [unowned self] in
            self.formatNumber($0)
        }
    }
    
    var formattedUsedTokenForLimitValueLabel: Observable<String> {
        return usedToken.map { tokenValue in
            "\(tokenValue)/\(self.maximumToken ?? 0000)"
        }
    }

    var formattedUsedTokenForLimitProgressBar: Observable<Float> {
        return usedToken.map { tokenValue in
            Float(tokenValue) / Float(self.maximumToken ?? 0000)
        }
    }

    var isExceedingLimit: Observable<Bool> {
        return isExceedingLimitRelay.asObservable()
    }
    
    var changeRootVC: Observable<Void> {
        return changeRootVCRelay.asObservable()
    }
    
    // ViewModel에서 발생하는 오류 이벤트를 방출하는 Observable
    var adError: Observable<Error> {
        return adErrorRelay.asObservable()
    }
    
    var generalError: Observable<Error> {
        return generalErrorRelay.asObservable()
    }
    
    // MARK: - Initializer
    init(repository: ChatRepository = ChatRepository.shared){
        Environment.debugPrint_START()

        self.repository = repository
        
        self.ownedToken
            .map { $0 > self.limitToken - self.rewardedTokens }
            .bind(to: isExceedingLimitRelay)
            .disposed(by: disposeBag)
        
        Environment.debugPrint_END()
    }
        
    // MARK: - Public Functions
    func loadMaximumToken() {
        Environment.debugPrint_START()
        
        self.handleSingleResponse(repository.getMixmumMessageToken(), successHandler:{ [weak self] value in
            self?.maximumToken = value
        }, errorHandler: { [weak self] error in
            self?.generalErrorRelay.accept(error)
        })

        Environment.debugPrint_END()
    }
    
    func fetchTokenInfo(isCalledFromSideMenuButton: Bool) {
        Environment.debugPrint_START()
        
        self.handleSingleResponse(repository.getOwnedToken(), successHandler: { [weak self] value in
            self?.ownedToken.accept(value)
        }, errorHandler: { [weak self] error in
            self?.generalErrorRelay.accept(error)
        })
        
        if isCalledFromSideMenuButton {
            // 사이드 메뉴 버튼에 의해 호출된 경우의 처리
            self.handleSingleResponse(repository.getCurrentMessageToken(), successHandler: { [weak self] value in
                self?.usedToken.accept(value)
            }, errorHandler: { [weak self] error in
                self?.generalErrorRelay.accept(error)
            })
        }
        
        Environment.debugPrint_END()
    }
    
    func addToken(tokens: Double){
        Environment.debugPrint_START()
        
        let newValue = self.ownedToken.value + tokens
        let updateTime = dateFormatter.string(from: Date())
        
        self.handleCompletableResponse(repository.updateOwnedToken(ownedTokens: newValue, updateTime: updateTime),completionHandler: { [weak self] in
            self?.ownedToken.accept(newValue)
        }, errorHandler: { [weak self] error in
            self?.adErrorRelay.accept(error)
        })
        
        Environment.debugPrint_END()
    }
    
    func leaveChatroom(){
        Environment.debugPrint_START()
        
        let updateTime = dateFormatter.string(from: Date())
        
        self.handleCompletableResponse(repository.clearAllChatData(updateTime: updateTime),completionHandler: { [weak self] in
            UserDefaults.standard.set(false, forKey: "initialSetupCompleted")
            self?.changeRootVCRelay.accept(())
        }, errorHandler: { [weak self] error in
            self?.generalErrorRelay.accept(error)
        })
        
        Environment.debugPrint_END()
    }
    
    // MARK: - Private Functions
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
    private func handleSingleResponse<T>(_ observable: Single<T>, successHandler: @escaping (T) -> Void, errorHandler: @escaping (Error) -> Void) {
        Environment.debugPrint_START()
        
        observable
            .subscribe(onSuccess: { value in
                successHandler(value)
            }, onFailure: { error in
                errorHandler(error)
            })
            .disposed(by: disposeBag)
        
        Environment.debugPrint_END()
    }
    
    private func handleCompletableResponse(_ completable: Completable, completionHandler: @escaping () -> Void, errorHandler: @escaping (Error) -> Void) {
        Environment.debugPrint_START()
        
        completable
            .subscribe(
                onCompleted: {
                    completionHandler()
                },
                onError: { error in
                    errorHandler(error)
                }
            )
            .disposed(by: disposeBag)
        
        Environment.debugPrint_END()
    }
}

