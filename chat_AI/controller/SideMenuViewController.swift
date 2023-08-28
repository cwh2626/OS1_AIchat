//
//  SideMenuViewController.swift
//  chat_AI
//
//  Created by 조웅희 on 2023/08/28.
//

import UIKit
import RxSwift
import RxCocoa

class SideMenuViewController: UIViewController {
    // MARK: - Properties
    private let menuItems = ["Settings", "Exit"]
    private let sideMenuWidth: CGFloat = UIScreen.main.bounds.width * 0.8 > 340 ? 340 : UIScreen.main.bounds.width * 0.8
    private var padding = UIEdgeInsets(top: 10.0, left: 10.0, bottom: 10.0, right: 10.0)
    private let viewModel = SideMenuViewModel()
    // Observable의 메모리 누수 방지를 위한 자동 구독해지 기능이라고 생각하면 편할듯
    private let disposeBag = DisposeBag()
    
    // MARK: - UI Components
    private var balanceCardView = BalanceCardView()
        
    // 실제로 표시될 메뉴 뷰
    private let menuContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = .secondaryBackgroundColor
        return view
    }()
    
    // 메뉴 뒤에 표시될 반투명 오버레이 뷰
    private let overlayView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.2)
        view.alpha = 0
        return view
    }()
    
    private var menuTableView: UITableView = {
        let tableView = UITableView()
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bindViewModel()
    }
    
    // UI초기화 메서드
    private func setupUI() {
        self.view.backgroundColor = UIColor.secondaryBackgroundColor
        self.view.alpha = 0
        self.view.backgroundColor = .clear
        
        // 오버레이뷰 설정
        self.overlayView.frame = self.view.bounds
                
        // 테이블뷰 설정
        self.menuTableView.delegate = self
        self.menuTableView.dataSource = self
        self.menuTableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        
        // 토큰카드뷰 설정
        self.balanceCardView.delegate = self
        self.balanceCardView.translatesAutoresizingMaskIntoConstraints = false
        
        // 사이드메뉴컨테이너뷰 설정
        self.menuContainerView.frame = CGRect(x: self.view.frame.width, y: 0, width: self.sideMenuWidth, height: self.view.frame.height)
        
        self.menuContainerView.addSubview(self.balanceCardView)
        self.menuContainerView.addSubview(self.menuTableView)
        
        // 제스처 설정
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.handleOverlayTap(_:)))
        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(self.handlePanGesture(_:)))
        
        self.overlayView.addGestureRecognizer(tapGesture)
        self.menuContainerView.addGestureRecognizer(panGestureRecognizer)
        
        self.view.addSubview(self.overlayView)
        self.view.addSubview(self.menuContainerView)
        
        NSLayoutConstraint.activate([
            self.balanceCardView.leadingAnchor.constraint(equalTo: self.menuContainerView.leadingAnchor,constant: self.padding.left),
            self.balanceCardView.trailingAnchor.constraint(equalTo: self.menuContainerView.trailingAnchor, constant: -self.padding.right),
            self.balanceCardView.topAnchor.constraint(equalTo: self.menuContainerView.safeAreaLayoutGuide.topAnchor),
            
            self.menuTableView.leadingAnchor.constraint(equalTo: self.menuContainerView.leadingAnchor),
            self.menuTableView.trailingAnchor.constraint(equalTo: self.menuContainerView.trailingAnchor),
            self.menuTableView.topAnchor.constraint(equalTo: self.balanceCardView.bottomAnchor),
            self.menuTableView.bottomAnchor.constraint(equalTo: self.menuContainerView.safeAreaLayoutGuide.bottomAnchor),
        ])
    }
    
    func bindViewModel() {
        // ownedToken 과 self.tokenLabel.text를 바인딩하는 코드
        // .bind : viewModel.displayText의 값이 변경될떄 마다 self.resultLabel.rx.text도 같은 값으로 변경됨 (rx란 UIkit컴포넌트에 Observable 구조체와 연결하게 해주는 역할)
        // .disposed: 바인드후 Disposable을 방출하는데 이걸 disposeBag 에 담아주는 역할 _ 메모리 자동 해지를 위해 (자동구독해지)
        viewModel.formattedTokenValue
            .bind(to: self.balanceCardView.tokenLabel.rx.text)
            .disposed(by: disposeBag)
        
//        viewModel.chatCurrentTokens
//            .map{"\($0)/\(self.viewModel.chatMaximumTokens)"}
//            .bind(to: self.balanceCardView.limitValueLabel.rx.text)
//            .disposed(by: disposeBag)
//
//        viewModel.chatCurrentTokens
//            .map { return Float($0) / Float(self.viewModel.chatMaximumTokens) }
//            .bind(to: self.balanceCardView.limitProgressBar.rx.progress)
//            .disposed(by: disposeBag)
        
    }
    
    // MARK: - Action Methods
    @objc func handlePanGesture(_ recognizer: UIPanGestureRecognizer) {
        let translation = recognizer.translation(in: view)

        switch recognizer.state {
        case .changed:
            if translation.x > 0 {
                recognizer.view!.frame.origin.x = (UIScreen.main.bounds.width - self.sideMenuWidth) + translation.x
                
            } else {
                
                recognizer.view!.frame.origin.x = UIScreen.main.bounds.width - self.sideMenuWidth
            }
        case .ended:
            if translation.x > 0 {
                self.closeSideMenu()
            }
            
        default:
            break
        }
    }
    
    @objc func handleOverlayTap(_ gesture: UITapGestureRecognizer) {
        self.closeSideMenu()
    }
    
    // MARK: - Utility Methods
    
    func openSideMenu() {
        self.view.alpha = 1
        
        UIView.animate(withDuration: 0.3) {
           self.menuContainerView.frame.origin.x = self.view.frame.width - self.sideMenuWidth
           self.overlayView.alpha = 1
        }
    }
    
    private func closeSideMenu() {
        
        UIView.animate(withDuration: 0.3, animations: {
            self.menuContainerView.frame.origin.x = self.view.frame.width
            self.overlayView.alpha = 0
        },completion: { _ in
            self.view.alpha = 0
        })
    }
}


// MARK: - Extensions
extension SideMenuViewController: UITableViewDataSource, UITableViewDelegate {
    
    // 섹션당 행의 수
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.menuItems.count
    }
    
    // 셀 설정
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        // 이미지 설정
        cell.backgroundColor = UIColor.secondaryBackgroundColor
        if self.menuItems[indexPath.row] == "Settings" {
            cell.imageView?.image = UIImage(named: "setting")?.withRenderingMode(.alwaysTemplate)
        } else {
            cell.imageView?.image = UIImage(named: "exit")?.withRenderingMode(.alwaysTemplate)
        }
        cell.imageView?.tintColor = UIColor.primaryBackgroundColor
        cell.textLabel?.text = self.menuItems[indexPath.row]
        cell.textLabel?.textColor = UIColor.primaryBackgroundColor
        
        return cell
    }
    
    // 셀 선택 시
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        // 선택한 셀에 따라 다른 뷰 컨트롤러를 생성합니다.
        let viewController: UIViewController

        switch indexPath.row {
        case 0:
            viewController = OSSettingsViewController(isStartupView: false)
            viewController.modalPresentationStyle = .overFullScreen
            
            // 뷰 컨트롤러를 프레젠트합니다.
            self.present(viewController, animated: true, completion: nil)
        case 1:
            self.showAlert()
        default:
            print("Invalid row selected")
            return
        }
        
    }
}

extension SideMenuViewController: BalanceCardViewDelegate {
    func adButtonDidTap() {
//        guard self.viewModel.ownedToken.value + 4000 < 99999999 else { return self.showAlert(alertText: "허용된 토큰 보유 한도를 초과했습니다.") }
//        guard isRewardedAdLoaded else { return self.showAlert(alertText: "광고가 준비 중입니다. 잠시 후에 다시 시도해 주시기 바랍니다.") }
//        showAd()
        
    }
}

extension SideMenuViewController: CustomAlertDelegate {
    // CustomAlertDelegate 메서드 구현
    func handleConfirmAction() {
        let chatDAO = ChatRepository()
        if chatDAO.clearAllChatData() {
            let initVC = InitialSetupViewController()

            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let sceneDelegate = windowScene.delegate as? SceneDelegate {
                UserDefaults.standard.set(false, forKey: "initialSetupCompleted") // 초기설정 안된것을 바꾸는 초기화 처리
                sceneDelegate.changeRootVC(initVC, animated: true)
            }
        }
        print("확인 버튼을 눌렀습니다.")
    }

    func handleCancelAction() {
        print("취소 버튼을 눌렀습니다.")
    }
    
    func showAlert() {
        let customAlertVC = CustomAlertViewController(
            alertText: "채팅방을 나가면 대화 내용이 모두 삭제됩니다.\n정말 나가시겠습니까?",
            alertType: .canCancel,
            delegate: self
        )

        present(customAlertVC, animated: true, completion: nil)
    }
}
