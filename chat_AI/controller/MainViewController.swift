//
//  MainViewController.swift
//  chat_AI
//
//  Created by 조웅희 on 2023/03/29.
//

import UIKit
import Lottie
import GoogleMobileAds
import RxSwift
import RxCocoa

/// 메인 채팅방
class MainViewController: UIViewController, UITextFieldDelegate {
    // MARK: - Properties and Constants
    private var rewardedAd: GADRewardedAd?
    private let viewModel = GPTChatViewModel()
    private var balanceCardView = BalanceCardView()
    private var sideMenuTableViewController = SideMenuTableViewController()
    
    private var isAnimationItemVisible = false // 메시지 응답 로딩애니메이션 토글
    private var isRewardedAdLoaded = false
    private var containerViewBottomConstraint: NSLayoutConstraint!
    
    // 전송버튼과 로딩뷰의 전환을 위해 전역변수로 설정
    private var sendButtonItem: UIBarButtonItem!
    private var loadingAnimationItem: UIBarButtonItem!
    private let sideMenuWidth: CGFloat = UIScreen.main.bounds.width * 0.8 > 340 ? 340 : UIScreen.main.bounds.width * 0.8
    
    private var shouldProcessNotifications = true
    private let AdMobRewardADId = Environment.AdMobRewardADId
    
    // Observable의 메모리 누수 방지를 위한 자동 구독해지 기능이라고 생각하면 편할듯
    private let disposeBag = DisposeBag()
    
    // MARK: - UI Components
    private var sideMenuView: UIView!
    private var overlayView: UIView!
    
    private let floatingAnimation: CABasicAnimation = {
        let animation = CABasicAnimation(keyPath: "transform.translation.y")
        animation.duration = 1.0
        animation.repeatCount = Float.infinity
        animation.autoreverses = true
        animation.fromValue = -1.5
        animation.toValue = 1.5
        return animation
    }()
    
    private let bannerView: GADBannerView = {
        let banner = GADBannerView()
        banner.adUnitID = Environment.AdMobBannerADId // 실제로는 여기에 AdMob에서 받은 배너 광고 단위 ID를 넣어야 합니다.
        banner.translatesAutoresizingMaskIntoConstraints = false
        return banner
    }()
    
    private let bannerContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "OS1"
        label.font = UIFont.systemFont(ofSize: 30) // 폰트 크기
        label.textColor = .secondaryBackgroundColor
        label.sizeToFit()
        return label
    }()
    
    private let topMenuButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(UIImage(named: "horizontal_menu")?.withRenderingMode(.alwaysTemplate), for: .normal)
        button.tintColor = .secondaryBackgroundColor
        return button
    }()
    
    // 응답대기 로딩애니메이션뷰
    private let loadingAnimationView: LottieAnimationView = {
        let animationView = LottieAnimationView(name: "send_loading")
        animationView.loopMode = .loop
        animationView.play()
        return animationView
    }()
    
    // 텍스트인풋툴바와 스택뷰를 포함하는 새로운 UIView를 생성합니다.
    private let mainContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = .secondaryBackgroundColor
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    // 메시지 스택 뷰를 담아줄 스크롤뷰를 생성합니다.
    private let chatScrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()
    
    // 말풍선을 담아줄 스택 뷰를 생성합니다.
    private let chatContainerView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical // 스택뷰를 수직으로 설정
        stackView.spacing = 20 // 스택간의 거리설정
        stackView.translatesAutoresizingMaskIntoConstraints = false
        //        stackView.isLayoutMarginsRelativeArrangement = true // 스택뷰의 양쪽 가장자리에 마진오브젝트?를 넣어서 공간을 여유롭게 보이게하는 기능 default= true
        return stackView
    }()
    
    private let messageInputView: UITextField = {
        let textField = UITextField()
        textField.textColor = .black
        textField.backgroundColor = .secondaryBackgroundColor
        textField.borderStyle = .roundedRect
        textField.layer.cornerRadius = 18
        textField.clipsToBounds = true // cornerRadius에 둥글게 잘린부분에 맞추어 text도 알맞게 잘라서 보여주는 기능
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    // 전송 버튼 생성합니다.
    private let sendButton: UIButton = {
        let button = SendButton(type: .custom)
        button.setImage(UIImage(named: "send")?.withRenderingMode(.alwaysTemplate), for: .normal)
        button.setImage(UIImage(named: "send")?.withRenderingMode(.alwaysTemplate), for: .highlighted)
        button.tintColor = .secondaryBackgroundColor
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    // 텍스트입력필드와 전송 버튼을 담아줄 툴바를 생성합니다.
    private let bottomToolbar: UIToolbar = {
        let toolbar = UIToolbar()
        // UIToolbar는 기본적으로 블러처러가 true로 되어있기에 다른 ui컨트롤러와 같은색상으로 하고자한다면
        // 블러를 없애(false)주면된다
        toolbar.isTranslucent = false
        toolbar.barTintColor = .tertiaryBackgroundColor
        toolbar.translatesAutoresizingMaskIntoConstraints = false
        return toolbar
    }()
    
    // 탑툴바를 생성합니다.
    private let topNavigationBar: UINavigationBar = {
        let toolbar = UINavigationBar()
        toolbar.isTranslucent = false  // 블러처리 유무 default = true
        toolbar.barTintColor = .tertiaryBackgroundColor
        toolbar.translatesAutoresizingMaskIntoConstraints = false
        return toolbar
    }()
    
    // MARK: - View Lifecycle
    override func viewDidLoad() {
        debugPrint_START()
        super.viewDidLoad()

        setupUI()
        setupSideMenu()
        setupOverlayView()
        addGestureRecognizers()
        setAllBubbleLabel()
        loadRewardedAd()
        bannerView.rootViewController = self
        bannerView.load(GADRequest())
        bindViewModel()
        
        
        // MARK: 키보드 유무 감시
        
        // UIResponder.keyboardWillShowNotification 는 키보드가 활성화 되어있는지 감시하는건데
        // 키보드를 활성화 해둔 상태에서 홈이나 다른 어플전환후 다시 해당 앱으로 돌아왔을때 키보드가 활성화가 되어있으면
        // 활성화되어있다고 다시 함수를 불러오게 된다. 이를 방지하기 위해
        // UIApplication.didBecomeActiveNotification 와
        // UIApplication.willResignActiveNotification 을 활용하여 앱이 활성화 되어있을때만 감시하는하도록 코드를 수정
        // ## 2023/05/09 ## 추가 수정
        // 기본적으로 기동시에는 감시하는걸로 해야한다 현재 초기화면에서 루트설정을 메인으로 변경시에 didBecomeActiveNotification 가 작동안하는걸로 확인, 그로인해 디펄트로 감시해두어도 앱비활성화시 감시가 있기에 문제는 없는걸로 보임
         NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardNotification), name: UIResponder.keyboardWillShowNotification, object: nil)
        
        // 키보드가 비활성화 되어있을때는 앱을 전환하든 홈에서 다시 돌아오든 재검사를 하지않는걸로 보이므로 문제가없다
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardNotification), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        // 앱이 활성화 될 때 실행되는 코드
        // 사용자와 상호작용 가능한 상태가 되면 발생
        // 예: 앱 시작, 앱을 다시 전환하여 활성화
        // UIApplication.didBecomeActiveNotification
        NotificationCenter.default.addObserver(self, selector: #selector(applicationDidBecomeActive), name: UIApplication.didBecomeActiveNotification, object: nil)
        
        // 앱이 비활성화 될 때 실행되는 코드
        // 사용자와의 상호작용이 일시 중단되는 상태가 되면 발생
        // 예: 전화 수신, 다른 앱으로 전환, 홈 화면 이동
        // UIApplication.willResignActiveNotification
        NotificationCenter.default.addObserver(self, selector: #selector(applicationWillResignActive), name: UIApplication.willResignActiveNotification, object: nil)
        
        // 자식뷰의 유무 (설정뷰에서 채팅뷰의 키보드 핸들러 인식 버그 해결)
        NotificationCenter.default.addObserver(self, selector: #selector(handleChildViewControllerDidAppear), name: .childViewControllerDidAppear, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleChildViewControllerDidDisappear), name: .childViewControllerDidDisappear, object: nil)
        
        // 앱이 활성화될 때 애니메이션을 다시 시작하기 위한 알림 구독 (앱이 백그라운드에서 포그라운드로 전환될 때마다 발생합니다.)
        NotificationCenter.default.addObserver(self, selector: #selector(restartAnimation), name: UIApplication.willEnterForegroundNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.handleDBChange), name: .didChangeDB, object: nil)
        debugPrint_END()
    }
    
    // 뷰가 화면에 완전히 나타난 직후에 호출됩니다. 뷰가 화면에 나타난 후 필요한 작업을 여기서 수행할 수 있습니다.
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        // 첫 기동시에 스택 뷰의 맨 아래로 스크롤합니다.
        // 콘텐츠전체 높이와 스크롤뷰의 보이는 높이만큼 빼주면 스택 뷰의 맨 아래 값이 딱 bottomToolbar의 top부분과 경계부분에 맞게 내용이 보이겠네요
        let bottomOffset = chatScrollView.contentSize.height - chatScrollView.bounds.size.height
        
        if bottomOffset > 0 { // 현재 보이는 스크롤뷰의 사이즈보다 컨텐트의 사이즈가 작을시에는 스크롤하지 않음
            chatScrollView.setContentOffset(CGPoint(x: 0, y: bottomOffset), animated: false)
        }
    }
        
    deinit {
        // NotificationCenter는 해제를 해줘야 메모리 누수방지를 할 수 있다
        // 물론 여기가 메인단이여서 안해도 문제는 없을거같은데 추후 변경이라던지 습관 등 안해서 손해볼것은 없다.
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Action Methods
    
    @objc func handlePanGesture(_ recognizer: UIPanGestureRecognizer) {
        let translation = recognizer.translation(in: view)

        switch recognizer.state {
        case .changed:
            if translation.x > 0 {
                recognizer.view!.frame.origin.x = (UIScreen.main.bounds.width - sideMenuWidth) + translation.x
                
            } else {
                
                recognizer.view!.frame.origin.x = UIScreen.main.bounds.width - sideMenuWidth
            }
        case .ended:
            if translation.x > 0 {
                print("closeSideMenu #######")
                closeSideMenu()
            }
            
        default:
            break
        }
    }
    
    @objc func handleOverlayTap(_ gesture: UITapGestureRecognizer) {
       closeSideMenu()
    }
    
    @objc func buttonTapped() {
        view.endEditing(true)
        openSideMenu()
    }
    
    @objc func handleDBChange(notification: NSNotification) {
        // DB 변경 시 수행할 동작을 여기에 코딩합니다.
        print(#function)
        self.viewModel.initMessage()
    }
    
    // 앱이 활성화 될 때 실행되는 액션이벤트
    @objc func applicationDidBecomeActive() {
//        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil) // viewDidLoad의 NotificationCenter와 겹치기에 안전성을 위해 한번 제거처리를 하고가자
//        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardNotification), name: UIResponder.keyboardWillShowNotification, object: nil)
    }
    
    // 앱이 비활성화 될 때 실행되는 액션이벤트
    @objc func applicationWillResignActive() {
//        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
    }

    // 키보드 내리는 액션이벤트
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    // 알림 핸들러
    @objc func handleChildViewControllerDidAppear(_ notification: Notification) {
        // 자식 뷰 컨트롤러가 나타났을 때 수행할 작업
        shouldProcessNotifications = false
    }

    @objc func handleChildViewControllerDidDisappear(_ notification: Notification) {
        // 자식 뷰 컨트롤러가 사라졌을 때 수행할 작업
        shouldProcessNotifications = true
    }
    
    // 키보드 유무에 따른 containerView(스크롤뷰, 입력바) 제약 설정 액션이벤트
    @objc func handleKeyboardNotification(_ notification: Notification) {
        // 앱이 활성 상태가 아니면 알림을 무시합니다.
        guard UIApplication.shared.applicationState == .active else { return }
        guard shouldProcessNotifications else {return}
        if let userInfo = notification.userInfo {
            let keyboardFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as! CGRect // 키보드의 frame 사이즈 가져오기
            let isKeyboardShowing = notification.name == UIResponder.keyboardWillShowNotification // 키보드의 유무 판단 변수
            print(#function, "- START \(isKeyboardShowing)" )
            // 키보드가 있을시에 키보드의 높이만큼 bottomAnchor의 거리를 줌
            // 없을 시에 0 로 설정
            containerViewBottomConstraint.constant = isKeyboardShowing ? view.safeAreaInsets.bottom - keyboardFrame.height : 0
            
            // transform은 뷰자체를 옮기기에 다른뷰를 침해하거나 잘리는 현상이 있어 조금 까다로운부분이 있다.
            // 물론 이걸 이용하면 스크롤뷰도 같이 올리기에 스크롤위치 조정을 따로 할 필요가없어지는 장점이 있긴하다
            // containerView.transform = isKeyboardShowing ? CGAffineTransform(translationX: 0, y: -keyboardFrame.height + view.safeAreaInsets.bottom) : CGAffineTransform.identity
            print(chatScrollView.contentOffset.y,view.safeAreaInsets.bottom,keyboardFrame.height)
            // 키보드 유무에 따른 스크롤뷰의 스크롤위치 조정
            // 키보드가 보일떄 키보드가 보이니 높이만큼 더하고 배경 뷰의 하단 여백이 사라지는 여백은 없애고
            // 반대로 키보드가 사라질때 여백은 나타나니 더하고 키보드는 사라지는 높이를 빼고
            chatScrollView.contentOffset.y += isKeyboardShowing ? keyboardFrame.height - view.safeAreaInsets.bottom : view.safeAreaInsets.bottom - keyboardFrame.height
            
            // 뷰의 레이아웃 업데이트를 즉시하게 해주는 메서드
            // 사실 아직 잘 이해가 안가는 기능이지만
            // 쓰고 안쓰고의 차이는 확연하다
            // 사용하지 않을시에 툴바가 애니메이션없이 드득 하면서 올라가진다 이건 추후에 더 공부해보자
            self.view.layoutIfNeeded()
        }
    }
    
    @objc func restartAnimation() {
        // 애니메이션을 다시 시작하는 코드
        balanceCardView.chargeButton.layer.add(floatingAnimation, forKey: "buttonFloatingAnimation")
    }
    
//    @objc func sendButtonTapped(_ sender: UIButton) {
//        let message = messageInputView.text!
//        addBubbleLabel(message, isUser: true)
//        viewModel.addMessage(role: "user", content: message)
//        viewModel.fetchGPT3Response(query: query) { response in
//            if let response = response {
//                print(response)
//                DispatchQueue.main.async {
//                    self.addBubbleLabel(response, isUser: false)
//                }
//                self.viewModel.addMessage(role: "assistant", content: response)
//            } else {
//                print("Error: No response")
//            }
//        }
//
//
//    }
    
    // 전송 버튼 액션이벤트
//        @objc func sendButtonTapped(_ sender: UIButton) {
//            guard !(messageInputView.text!.isEmpty) else { return } // 텍스트가 있을시에
//
//            let message = messageInputView.text!
//            print("유저의 메시지: \(message)")
//            addBubbleLabel(message, isUser: true)
//
//            messageInputView.text = ""
//            textFieldDidChange(messageInputView) // 전송버튼 수동 활성화체크
//            toggleToolbarItemAnimation()
//
//            viewModel.addMessage(role: "user", content: message) // 입력한 메시지를 user입장의 gpt 모델에 내용 추가
//            viewModel.addMessage(role: ChatRoleType.USER, content: message) // 입력한 메시지를 user입장의 gpt 모델에 내용 추가
//            viewModel.fetchGPT3Response() { response in
//                if let response = response {
//                    print(response)
//                    DispatchQueue.main.async {
//                        self.addBubbleLabel(response, isUser: false) // 답변을 채팅창에 추가
//                        self.toggleToolbarItemAnimation()
//                    }
//                    self.viewModel.addMessage(role: "assistant", content: response) // 입력한 메시지를 AI입장의 gpt 모델에 내용 추가
//                    self.viewModel.addMessage(role: ChatRoleType.AST, content: response) // 입력한 메시지를 AI입장의 gpt 모델에 내용 추가
//                } else {
//                    print("Error: No response")
//                }
//            }
//
//        }
    
    // 전송 버튼 액션이벤트
    @objc func sendButtonTapped(_ sender: UIButton) {
        guard !(messageInputView.text!.isEmpty) else { return self.showAlert(alertText: "대화를 시작하려면 메시지를 입력해주세요.") } // 텍스트가 있을시에
        guard viewModel.ownedToken.value > 0 else { return self.showAlert(alertText: "토큰이 부족해요. 토큰을 충전해주세요.") }
        
        let userDateTime = DateFormatter()
        userDateTime.dateFormat = "yyyy-MM-dd HH:mm:ss.SSS"
        
        let userParam = Chat(role: ChatRoleType.USER, content: messageInputView.text!,time:userDateTime.string(from: Date()))
        
        let userMessage = userParam.content
        
        addBubbleLabel(userMessage, isUser: true)
        
        viewModel.addMessage(role: ChatRoleType.USER, content: userMessage) // 입력한 메시지를 user입장의 gpt 모델에 내용 추가
        
        messageInputView.text = ""
        textFieldDidChange(messageInputView) // 전송버튼 수동 활성화체크
        toggleToolbarItemAnimation()
        
        // MARK: chatGPT 응답 코드
        
        viewModel.fetchGPT3Response() { [weak self] response, state, tokens in
            guard let self = self else { return print("Error: No self")}
            var stopToggle = false
            defer {
                DispatchQueue.main.async {
                    self.removeBubbleLabel(toggle: stopToggle)
                }
            }
            guard let _state = state, let _response = response, let _tokens = tokens else {
                // .now() + 0.5는 현재 시간에서 0.5초 후를 의미, 하며 toggleToolbarItemAnimation의 애니메이션이 끝나지 않은 상태에서 다시 작동하게 toggleToolbarItemAnimation을 호출하게 되면 애니메이션이 정상적으로 처리되지않기에 이렇게 딜레이를 주어서 애니메이션 충돌을 막게한다
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5)  {
                    self.toggleToolbarItemAnimation()
                    self.showAlert(alertText: "Error")
                }
                return print("Error: No state")
                
            }
            
            
            if finishReasonState.stop == _state || finishReasonState.length == _state {
                let astDateTime = DateFormatter()
                astDateTime.dateFormat = "yyyy-MM-dd HH:mm:ss.SSS"
                
                let astParam = Chat(role: ChatRoleType.AST, content: _response,time:astDateTime.string(from: Date()))
                
                self.viewModel.addMessage(role: ChatRoleType.AST, content: _response) // 입력한 메시지를 AI입장의 gpt 모델에 내용 추가
                
                // ######### 다음 여기서 상정한대로 DB에러시에 defer과 guard문이 작동하는지 확인하는걸로
                // 현재 확읹중 xcode의 실행을 stop하면 defer이 먹지않는걸 발견 음,, 이건 다음에 확인시에 같이 확인하는걸로
                // 확인 결과: defer은 비정상 종료가되거난 애플리케이션이 종료되면 실행되지 않는다 해당 구문은 말그대로 해당 함수가 끝났을때 발동하기에 중간에 종료되면 안되는게 정상 굳이 비정상 종료시에 어떤 행동을 취하고싶다면 'applicationWillTerminate(_:)' 메서드를 활용할것
                // 그럼 여기서 문제 비정상 종료시에 롤백은 어떻게 해야할까?
                // - 사실 sqlite3는 트랜젝션 중에 커밋이 되지않으면 자동으로 롤백이 된다
                // 그런데 여기서 마음에 걸리는거는 '.db-journal' 라는 확장자 파일이 남아 버리는데
                // 이 또한 sqlite3가 알아서 다음 db실행시에 삭제될것이다 해당 파일은 그냥 sqlite3의 기록용 파일이라고 생각하는게 편할듯
                var isDBUpdateSuccessful: Bool = false
                self.viewModel.chatDAO.fmdb.beginTransaction()
                    
                defer {
                    if !isDBUpdateSuccessful {
                        self.viewModel.chatDAO.fmdb.rollback()
                    }
                }
                guard self.viewModel.insertMessageIntoDatabase(messageData: userParam) else { return }
                guard self.viewModel.insertMessageIntoDatabase(messageData: astParam) else { return }
                guard self.viewModel.setCurrentMessageToken(tokens: _tokens, updateTime: astDateTime.string(from: Date())) else { return }
                self.viewModel.chatDAO.fmdb.commit()
                isDBUpdateSuccessful = true
                stopToggle = true
            }
            
            print(_state.rawValue)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.toggleToolbarItemAnimation()
                if stopToggle {
                self.addBubbleLabel(_response, isUser: false) // 답변을 채팅창에 추가
                    if finishReasonState.length == _state  {
                        self.showAlert(alertText: _state.desc())
                    }
                } else if self.viewModel.chatMaximumTokens <= self.viewModel.chatCurrentTokens.value {
                    self.showAlert(alertText: finishReasonState.length.desc())
                } else {
                    self.showAlert(alertText: _state.desc())
                }
            }
        }
        
    }
    
    // 메시지 박스 입력 체크 액션이벤트
    @objc func textFieldDidChange(_ textField: UITextField) {

        // text 값이 있다면, text의 앞뒤 공백과 줄바꿈 문자를 제거한 후, 그 결과가 비어있는지 확인합니다.
        // trimmingCharacters(in: .whitespacesAndNewlines): 이 메소드는 호출하는 문자열에서 지정된 문자 집합(CharacterSet)에 포함된 모든 문자를 문자열의 양 끝(시작과 끝)에서 제거합니다. .whitespacesAndNewlines는 공백과 줄바꿈 문자를 포함하는 CharacterSet입니다. 따라서 이 코드는 문자열의 양 끝에서 모든 공백과 줄바꿈 문자를 제거합니다.
        if let text = textField.text, !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            sendButton.isEnabled = true
        } else {
            sendButton.isEnabled = false
        }
    }
    
    // MARK: - Interface Setup
    
    // UI초기화 메서드
    private func setupUI() {
        self.view.backgroundColor = .tertiaryBackgroundColor
        
        bannerContainerView.addSubview(bannerView)
        chatScrollView.addSubview(chatContainerView)
        mainContainerView.addSubview(chatScrollView)
        mainContainerView.addSubview(bottomToolbar)
        
        self.view.addSubview(topNavigationBar)
        self.view.addSubview(mainContainerView)
        self.view.addSubview(bannerContainerView)
                
        setupToolbar()
        
        // sendButton 터치시 sendButtonTapped 메서드 호출
        sendButton.addTarget(self, action: #selector(sendButtonTapped(_:)), for: .touchUpInside)
        
        balanceCardView.delegate = self
        
        // messageInputView의 text유무에 따른 sendbutton의 활성화 유무 처리
        messageInputView.delegate = self // 이거 uibuttom은 안하는데 왜하는지 추후에 gpt로 물어보자
        messageInputView.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        
        textFieldDidChange(messageInputView) // 처음 앱실행시에는 체크하지않기에 수동으로 한번 실행시키는 구문
        
        // 키보드 유무에 따른 채팅뷰 하단위치 조정 제약조건 초기화
        containerViewBottomConstraint = mainContainerView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        
        // 제약조건 활성화
        NSLayoutConstraint.activate([
            // containerView
            mainContainerView.topAnchor.constraint(equalTo: bannerContainerView.bottomAnchor),
            mainContainerView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            mainContainerView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            containerViewBottomConstraint,
            
            // scrollView
            chatScrollView.topAnchor.constraint(equalTo: mainContainerView.topAnchor),
            chatScrollView.leadingAnchor.constraint(equalTo: mainContainerView.leadingAnchor),
            chatScrollView.trailingAnchor.constraint(equalTo: mainContainerView.trailingAnchor),
            chatScrollView.bottomAnchor.constraint(equalTo: bottomToolbar.topAnchor),
            
            // messageContainerView
            chatContainerView.topAnchor.constraint(equalTo: chatScrollView.topAnchor, constant: 20),
            chatContainerView.leadingAnchor.constraint(equalTo: chatScrollView.leadingAnchor),
            chatContainerView.trailingAnchor.constraint(equalTo: chatScrollView.trailingAnchor),
            chatContainerView.bottomAnchor.constraint(equalTo: chatScrollView.bottomAnchor, constant: -20),
            chatContainerView.widthAnchor.constraint(equalTo: chatScrollView.widthAnchor),
            
            // bannerContainerView
            bannerContainerView.topAnchor.constraint(equalTo: topNavigationBar.bottomAnchor),
            bannerContainerView.heightAnchor.constraint(equalToConstant: 50),
            bannerContainerView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            bannerContainerView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            
            // bannerView
            bannerView.topAnchor.constraint(equalTo: bannerContainerView.topAnchor),
            bannerView.bottomAnchor.constraint(equalTo: bannerContainerView.bottomAnchor),
            bannerView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            bannerView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            
            // topNavigationBar
            topNavigationBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            topNavigationBar.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            topNavigationBar.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),

            // bottomToolbar
            bottomToolbar.topAnchor.constraint(equalTo: chatScrollView.bottomAnchor),
            bottomToolbar.leadingAnchor.constraint(equalTo: mainContainerView.leadingAnchor),
            bottomToolbar.trailingAnchor.constraint(equalTo: mainContainerView.trailingAnchor),
            bottomToolbar.bottomAnchor.constraint(equalTo: mainContainerView.bottomAnchor),

            // messageInputView
            messageInputView.widthAnchor.constraint(equalToConstant: view.bounds.width * 0.80)
        ])
    }
    
    // 바 설정 메서드
    private func setupToolbar() {
        let textFieldItem = UIBarButtonItem(customView: messageInputView)
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil) // 스페이스 아이템
        self.sendButtonItem = UIBarButtonItem(customView: sendButton)
        self.loadingAnimationItem = UIBarButtonItem(customView: loadingAnimationView)
        let barButtonItem = UIBarButtonItem(customView: topMenuButton)
        let navigationItem = UINavigationItem()
        
        self.topMenuButton.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)

        navigationItem.rightBarButtonItem = barButtonItem
        navigationItem.titleView = self.titleLabel

        self.topNavigationBar.items = [navigationItem]

        // 툴바 아이템 설정, 구도: [ 입력필드 - 공백 - 전송버튼 ]
        self.bottomToolbar.setItems([textFieldItem, flexibleSpace, self.sendButtonItem], animated: false)
    }
    
    func setupSideMenu() {
        sideMenuView = UIView(frame: CGRect(x: view.frame.width, y: 0, width: sideMenuWidth, height: view.frame.height))

        sideMenuView.backgroundColor = UIColor.secondaryBackgroundColor
        
        // MyTableViewController 인스턴스 생성
        sideMenuTableViewController = SideMenuTableViewController()
        
        // 여기서 버튼에 애니메이션 추가
        balanceCardView.chargeButton.layer.add(floatingAnimation, forKey: "buttonFloatingAnimation")
        balanceCardView.translatesAutoresizingMaskIntoConstraints = false
        // 컨트롤안에 컨트롤을 추가할시에는 부모자식의 관계를 확실히해야 부모가 종료될때(예:viewDidDisappear) 자식도 같이 종료해야하는데 자식이 이를 모르기에
        // 종료가 안되고 메모리누수가 될수가있다 그렇기에 라이플사이클을 서로 공유해야 메모리누수를 방지 할 수 있다.
        addChild(sideMenuTableViewController)
        sideMenuView.addSubview(balanceCardView)
        sideMenuView.addSubview(sideMenuTableViewController.view)
        view.addSubview(sideMenuView)
        
        
        sideMenuTableViewController.view.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            balanceCardView.leadingAnchor.constraint(equalTo: sideMenuView.leadingAnchor,constant: 10),
            balanceCardView.trailingAnchor.constraint(equalTo: sideMenuView.trailingAnchor, constant: -10),
            balanceCardView.topAnchor.constraint(equalTo: sideMenuView.safeAreaLayoutGuide.topAnchor),
            
            sideMenuTableViewController.view.leadingAnchor.constraint(equalTo: sideMenuView.leadingAnchor),
            sideMenuTableViewController.view.trailingAnchor.constraint(equalTo: sideMenuView.trailingAnchor),
            sideMenuTableViewController.view.topAnchor.constraint(equalTo: balanceCardView.bottomAnchor),
            sideMenuTableViewController.view.bottomAnchor.constraint(equalTo: sideMenuView.safeAreaLayoutGuide.bottomAnchor),
        ])
        
        // 컨테이너 뷰 컨트롤러로 추가
        // .didMove(toParent: self): 이건 반대로 자식에게 너의 부모가 누구누구이며 부모뷰에 추가되거나 해제되었을때 유용하게 부모뷰의 기능에 간섭할수있는 기능입니다.
        sideMenuTableViewController.didMove(toParent: self)
    }

    func setupOverlayView() {
       overlayView = UIView(frame: view.bounds)
       overlayView.backgroundColor = UIColor.black.withAlphaComponent(0.2)
       overlayView.alpha = 0
       view.insertSubview(overlayView, belowSubview: sideMenuView)
    }
    
    
    // MARK: - Utility Methods
    func bindViewModel() {
        // ownedToken 과 self.tokenLabel.text를 바인딩하는 코드
        // .bind : viewModel.displayText의 값이 변경될떄 마다 self.resultLabel.rx.text도 같은 값으로 변경됨 (rx란 UIkit컴포넌트에 Observable 구조체와 연결하게 해주는 역할)
        // .disposed: 바인드후 Disposable을 방출하는데 이걸 disposeBag 에 담아주는 역할 _ 메모리 자동 해지를 위해 (자동구독해지)
        viewModel.ownedToken
            .map{self.formatNumber($0)}
            .bind(to: self.balanceCardView.tokenLabel.rx.text)
            .disposed(by: disposeBag)
        
        viewModel.chatCurrentTokens
            .map{"\($0)/\(self.viewModel.chatMaximumTokens)"}
            .bind(to: self.balanceCardView.limitValueLabel.rx.text)
            .disposed(by: disposeBag)
        
        viewModel.chatCurrentTokens
            .map { return Float($0) / Float(self.viewModel.chatMaximumTokens) }
            .bind(to: self.balanceCardView.limitProgressBar.rx.progress)
            .disposed(by: disposeBag)
        
    }
    
    func formatNumber(_ num: Double) -> String {
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
    
    private func setAllBubbleLabel() {
        let messageList = viewModel.getAllMessages()
//        print(#function, messageList)
        messageList.forEach { body in
            if body["role"] != ChatRoleType.SYS.desc() {
//                print(#function,body["role"]!," : \(body["content"]!)")
                if body["role"] == ChatRoleType.AST.desc() {
                    self.addBubbleLabel(body["content"]!, isUser: false, isInit: true)
                } else {
                    self.addBubbleLabel(body["content"]!, isUser: true, isInit: true)
                }
            }
        }
    }
    
    private func removeBubbleLabel(toggle: Bool){
        if let lastView = self.chatContainerView.arrangedSubviews.last, !toggle {
            self.chatContainerView.removeArrangedSubview(lastView)
            lastView.removeFromSuperview()
            self.viewModel.removeLastMessage()
        }
    }
    
    // 채팅 말풍선 삽입 메서드
    private func addBubbleLabel(_ text: String, isUser: Bool, isInit: Bool = false){
        let label = ChatBubbleView(text: text, isUser: isUser)
        chatContainerView.addArrangedSubview(label) // 스택뷰 맨 끝에 추가
        
        guard !isInit else { return }
        
        // layoutIfNeeded: 레이아웃 업데이트가 필요할 때 즉시 실행할 수 있는 메서드입니다.
        // 애니메이션 또는 뷰의 크기 및 위치를 즉시 업데이트해야 할 때 사용됩니다.

        // layoutSubviews: 뷰의 하위 뷰를 레이아웃하는 작업을 수행하는 메서드입니다.
        // 시스템에 의해 자동으로 호출되며, 뷰의 크기가 변경되거나 하위 뷰가 추가되거나 제거될 때 호출됩니다.
        // 뷰의 레이아웃에 변경 사항이 생길 때 호출되며, 필요한 경우 하위 뷰의 레이아웃을 조절할 수 있습니다.
        chatContainerView.layoutIfNeeded()
        chatScrollView.layoutIfNeeded()

//        DispatchSemaphore는 GCD(Grand Central Dispatch)의 일부로서, 특정 작업의 동기화 및 제어를 위해 사용되는 도구입니다. 주요 기능은 다음과 같습니다.
//
//        초기 카운트 설정: 생성 시 초기 카운트 값을 설정하여, 세마포어의 상태를 제어할 수 있습니다.
//        wait(): 세마포어의 카운트가 0보다 크면 카운트를 감소시키고, 그렇지 않으면 대기 상태에 머무릅니다. 이는 다른 스레드나 작업이 세마포어를 시그널할 때까지 기다립니다.
//        signal(): 세마포어의 카운트를 증가시켜 대기 중인 스레드나 작업이 진행될 수 있도록 합니다.
//        주의할 점은 메인 스레드에서 wait()를 사용할 때 발생할 수 있는 문제입니다. 메인 스레드에서 대기하게 되면 사용자 인터페이스가 멈추고, 애플리케이션이 정상적으로 동작하지 않을 수 있습니다. 따라서 메인 스레드에서는 주의하여 사용해야 합니다. 이와 같은 상황에서는 백그라운드 스레드에서 동기화 작업을 처리하는 것이 좋습니다.
        
        // 그렇기에 UIView.animate의 컴플리션에 적용을 못하게되었습니다.
        
        // 유저가 스크롤하는중에 애니메이션으로 스크롤을 강제로 움직이면 살짝 스크롤방향으로 움직이는 경향이 있기에
        // 한 번 강제로 현재위치에 스크롤을 고정후에 애니메이션 스크롤로 움직이게 한다
        let bottomOffset = chatScrollView.contentSize.height - chatScrollView.bounds.size.height
        
        if bottomOffset > 0 { // 현재 보이는 스크롤뷰의 사이즈보다 컨텐트의 사이즈가 작을시에는 스크롤하지 않음
            chatScrollView.setContentOffset(chatScrollView.contentOffset, animated: false)
            UIView.animate(withDuration: 0.2, animations: {
                self.chatScrollView.contentOffset = CGPoint(x: 0, y: bottomOffset)
            })
        }

    }

    func addGestureRecognizers() {
        // scrollView 영역 터치시 dismissKeyboard 메서드 호출
        let scrollViewTapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard)) //
        chatScrollView.addGestureRecognizer(scrollViewTapGesture)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleOverlayTap(_:)))
        overlayView.addGestureRecognizer(tapGesture)

        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture(_:)))
        sideMenuView.addGestureRecognizer(panGestureRecognizer)
    }

  
// 데드코드
//    @objc func handleSwipeGesture(_ gesture: UISwipeGestureRecognizer) {
//       if gesture.direction == .right {
//           closeSideMenu()
//       }
//    }

    func openSideMenu() {
       UIView.animate(withDuration: 0.3) {
           self.sideMenuView.frame.origin.x = self.view.frame.width - self.sideMenuWidth
           self.overlayView.alpha = 1
       }
    }

    func closeSideMenu() {
       UIView.animate(withDuration: 0.3) {
           self.sideMenuView.frame.origin.x = self.view.frame.width
           self.overlayView.alpha = 0
       }
    }
    
    

    // 하단툴바의 전송버튼, 로딩뷰 전환 토글함수
    func toggleToolbarItemAnimation() {
        
        if isAnimationItemVisible {
            topMenuButton.isEnabled = true
            // 로딩 애니메이션 아이템 사라지게 하기
            UIView.animate(withDuration: 0.2, animations: {
                
                self.loadingAnimationItem.customView?.alpha = 0
            }) { _ in
                self.bottomToolbar.items?.removeLast()
                self.bottomToolbar.items?.append(self.sendButtonItem)
                self.sendButtonItem.customView?.alpha = 0

                // 보내기 버튼 아이템 나타나게 하기
                UIView.animate(withDuration: 0.2) {
                    self.chatScrollView.alpha = 1
                    self.sendButtonItem.customView?.alpha = 1
                }
            }
        } else {
            topMenuButton.isEnabled = false
            // 보내기 버튼 아이템 사라지게 하기
            UIView.animate(withDuration: 0.2, animations: {
                
                self.sendButtonItem.customView?.alpha = 0
            }) { _ in
                self.bottomToolbar.items?.removeLast()
                self.bottomToolbar.items?.append(self.loadingAnimationItem)
                self.loadingAnimationItem.customView?.alpha = 0

                // 로딩 애니메이션 아이템 나타나게 하기
                UIView.animate(withDuration: 0.2) {
                    self.chatScrollView.alpha = 0.7
                    self.loadingAnimationItem.customView?.alpha = 1
                }
            }
        }
        isAnimationItemVisible.toggle()
    }
    
}

// MARK: - Extensions

extension MainViewController: CustomAlertDelegate {
    // CustomAlertDelegate 메서드 구현
    func handleConfirmAction() {
        print("확인 버튼을 눌렀습니다.")
    }

    func handleCancelAction() {
        print("취소 버튼을 눌렀습니다.")
    }
    
    func showAlert(alertText: String) {
        let customAlertVC = CustomAlertViewController(
            alertText: alertText,
            alertType: .onlyConfirm,
            delegate: self
        )

        present(customAlertVC, animated: true, completion: nil)
    }
}

extension MainViewController: GADFullScreenContentDelegate, BalanceCardViewDelegate {
    func adButtonDidTap() {
        // 광고 연동전 스크린샷
//        guard self.viewModel.ownedToken.value + 4000 < 20000 else { return self.showAlert(alertText: "허용된 토큰 보유 한도를 초과했습니다.") }
//        var isDBUpdateSuccessful: Bool = false
//        self.viewModel.chatDAO.fmdb.beginTransaction()
//
//        defer {
//            if !isDBUpdateSuccessful {
//                self.viewModel.chatDAO.fmdb.rollback()
//            }
//        }
//        // TODO: 사용자에게 보상 제공.
//        if self.viewModel.adjustOwnedToken(tokens: 4000) {
//            self.viewModel.chatDAO.fmdb.commit()
//            isDBUpdateSuccessful = true
//        } else {
//            return
//        }
        guard self.viewModel.ownedToken.value + 4000 < 99999999 else { return self.showAlert(alertText: "허용된 토큰 보유 한도를 초과했습니다.") }
        guard isRewardedAdLoaded else { return self.showAlert(alertText: "광고가 준비 중입니다. 잠시 후에 다시 시도해 주시기 바랍니다.") }
        showAd()
        
    }
    
    func loadRewardedAd() {
        let request = GADRequest()
        GADRewardedAd.load(withAdUnitID:AdMobRewardADId,
                           request: request,
                           completionHandler: { [self] ad, error in
            if let error = error {
                print("보상형 광고 로딩 실패: \(error.localizedDescription)")
                return
            }
            rewardedAd = ad
            rewardedAd?.fullScreenContentDelegate = self
            isRewardedAdLoaded = true
            print("보상형 광고 로딩 완료.")
        })
    }
    
    func showAd() {
        if let ad = rewardedAd {
            ad.present(fromRootViewController: self, userDidEarnRewardHandler: {
                let reward = ad.adReward
                print("보상 받음. 화폐: \(reward.type), 수량: \(reward.amount.doubleValue)")
                
                var isDBUpdateSuccessful: Bool = false
                self.viewModel.chatDAO.fmdb.beginTransaction()
                    
                defer {
                    if !isDBUpdateSuccessful {
                        self.viewModel.chatDAO.fmdb.rollback()
                    }
                }
                // TODO: 사용자에게 보상 제공.
                if self.viewModel.adjustOwnedToken(tokens: 4000) {
                    self.viewModel.chatDAO.fmdb.commit()
                    isDBUpdateSuccessful = true
                } else {
                    return
                }
            })
        } else {
            self.showAlert(alertText: "광고가 준비 중입니다. 잠시 후에 다시 시도해 주시기 바랍니다.")
            print("광고 준비가 되지 않았습니다.")
        }
    }
    
    // MARK: GADFullScreenContentDelegate

    func adDidRecordImpression(_ ad: GADFullScreenPresentingAd) {
        isRewardedAdLoaded = false
        print("광고가 정상적으로 로드되었습니다.")
    }

    func adDidDismissFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        print("광고가 닫혔습니다. 새로운 광고를 로드합니다.")
        loadRewardedAd() // 광고가 닫힌 후 새로운 광고를 로드합니다.
        restartAnimation()
    }
    
    func ad(_ ad: GADFullScreenPresentingAd, didFailToPresentFullScreenContentWithError error: Error) {
        print("광고 표시에 실패했습니다: \(error.localizedDescription)")
    }

    func adWillPresentFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        print("광고가 풀 스크린으로 표시될 예정입니다.")
    }
}
