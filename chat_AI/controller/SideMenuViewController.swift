//
//  SideMenuViewController.swift
//  chat_AI
//
//  Created by 조웅희 on 2023/08/28.
//
// 개선점! NO.02 : 광고 로딩 실패시 처리를 넣어야함 한번 실패하면 광고로딩을 재차 시도하도록 Bool형값을 넣어서 수정하도록 추후 개선필요

import UIKit
import RxSwift
import RxCocoa
import GoogleMobileAds
import SnapKit

/// 사이드메뉴 페이지
class SideMenuViewController: UIViewController {
    // MARK: - Properties
    private let AdMobRewardADId = Environment.AdMobRewardADId
    private var rewardedAd: GADRewardedAd?
    private var isRewardAdShowing = false
    private var isRewardedAdLoaded = false
    private let menuItems = ["Settings", "Exit"]
    private let sideMenuWidth: CGFloat = UIScreen.main.bounds.width * 0.8 > 340 ? 340 : UIScreen.main.bounds.width * 0.8
    private let padding = UIEdgeInsets(top: 10.0, left: 10.0, bottom: 10.0, right: 10.0)
    private var viewModel: SideMenuViewModel!
    private var hadAdError = false
    private var didAdLoadFail = false
    
    // Observable의 메모리 누수 방지를 위한 자동 구독해지 기능이라고 생각하면 편할듯
    private let disposeBag = DisposeBag()
    
    // MARK: - UI Components
    private let balanceCardView = BalanceCardView()
        
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
    
    private let menuTableView: UITableView = {
        let tableView = UITableView()
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    // MARK: - View Lifecycle
    override func viewDidLoad() {
        Environment.debugPrint_START()
        
        super.viewDidLoad()
        self.viewModel = SideMenuViewModel()
        loadRewardedAd()
        setupUI()
        bindViewModel(self.viewModel)
        
        Environment.debugPrint_END()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.viewModel.loadMaximumToken()
    }
    
    // MARK: - Interface Setup
    // UI초기화 메서드
    private func setupUI() {
        Environment.debugPrint_START()
        
        self.view.backgroundColor = .clear
        self.view.alpha = 0
        
        
        // 오버레이뷰 설정
        self.overlayView.frame = self.view.bounds
                
        // 테이블뷰 설정
        self.menuTableView.delegate = self
        self.menuTableView.dataSource = self
        self.menuTableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        
        // 토큰카드뷰 설정
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
        
        Environment.debugPrint_END()
    }
    
    // MARK: - ViewModel Binding
    private func bindViewModel(_ : SideMenuViewModel) {
        Environment.debugPrint_START()
        
        viewModel.formattedOwnedToken
            .bind(to: self.balanceCardView.tokenLabel.rx.text)
            .disposed(by: disposeBag)
        
        viewModel.formattedUsedTokenForLimitValueLabel
            .bind(to: self.balanceCardView.limitValueLabel.rx.text)
            .disposed(by: disposeBag)

        viewModel.formattedUsedTokenForLimitProgressBar
            .bind(to: self.balanceCardView.limitProgressBar.rx.progress)
            .disposed(by: disposeBag)
        
        // rootVC 변경 이벤트를 핸들링
        viewModel.changeRootVC.subscribe(onNext: {
            let initVC = InitialSetupViewController()
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let sceneDelegate = windowScene.delegate as? SceneDelegate {
                sceneDelegate.changeRootVC(initVC, animated: true)
            }
        }).disposed(by: disposeBag)
        
        self.balanceCardView.chargeButton.rx.tap
            .withLatestFrom(viewModel.isExceedingLimit) // withLatestFrom : 최신값 호출
            .subscribe(onNext: { [weak self] isExceeding in // onNext : 'withLatestFrom' 으로부터 받아온 최신값 구독
                guard !self!.didAdLoadFail else {
                    self?.showAlert(alertText: .adError, alertType: .onlyConfirm)
                    return
                }
                
                guard self!.isRewardedAdLoaded else {
                    self?.showAlert(alertText: .adPreparing, alertType: .onlyConfirm)
                    return
                }
                
                guard !isExceeding else {
                    self?.showAlert(alertText: .exceededAllowedLimit, alertType: .onlyConfirm)
                    return
                }
                
                self?.showAd()
            })
            .disposed(by: disposeBag)
        
        // 에러 처리 바인딩
        viewModel.adError
            .subscribe(onNext: { [weak self] error in
                self?.hadAdError = true
                
            })
            .disposed(by: disposeBag)
        
        viewModel.generalError
            .subscribe(onNext: { [weak self] error in
                self?.showAlert(alertText: .databaseError, alertType: .onlyConfirm)
            })
            .disposed(by: disposeBag)
        
        Environment.debugPrint_END()
    }
    
    // MARK: - Action Methods
    @objc func handlePanGesture(_ recognizer: UIPanGestureRecognizer) {
        Environment.debugPrint_START()
        
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
        
        Environment.debugPrint_END()
    }
    
    @objc func handleOverlayTap(_ gesture: UITapGestureRecognizer) {
        Environment.debugPrint_START()
        
        self.closeSideMenu()
        
        Environment.debugPrint_END()
    }
    
    // MARK: - Utility Methods
    func openSideMenu() {
        Environment.debugPrint_START()
        
        viewModel.fetchTokenInfo(isCalledFromSideMenuButton: true)
        
        self.view.alpha = 1
        
        UIView.animate(withDuration: 0.3) {
           self.menuContainerView.frame.origin.x = self.view.frame.width - self.sideMenuWidth
           self.overlayView.alpha = 1
        }
        
        Environment.debugPrint_END()
    }
    
    private func closeSideMenu() {
        Environment.debugPrint_START()
        
        UIView.animate(withDuration: 0.3, animations: {
            self.menuContainerView.frame.origin.x = self.view.frame.width
            self.overlayView.alpha = 0
        },completion: { _ in
            self.view.alpha = 0
        })
        
        Environment.debugPrint_END()
    }
    
    private func loadRewardedAd() {
        Environment.debugPrint_START()
        
        let request = GADRequest()
        GADRewardedAd.load(withAdUnitID:AdMobRewardADId,
                           request: request,
                           completionHandler: { [self] ad, error in
            if error != nil {
                didAdLoadFail = true
                return
            }
            rewardedAd = ad
            rewardedAd?.fullScreenContentDelegate = self
            isRewardedAdLoaded = true
        })
        
        Environment.debugPrint_END()
    }
    
    private func showAd() {
        Environment.debugPrint_START()
        
        if let ad = rewardedAd {
            ad.present(fromRootViewController: self, userDidEarnRewardHandler: {
                let reward = ad.adReward
                
                self.viewModel.addToken(tokens: reward.amount.doubleValue)
            })
        } else {
            self.showAlert(alertText: .adPreparing, alertType: .onlyConfirm)
        }
        
        Environment.debugPrint_END()
    }
}

// MARK: - Extensions
// MARK: - UITableViewDataSource,UITableViewDelegate Methods
extension SideMenuViewController: UITableViewDataSource, UITableViewDelegate {
    
    // 섹션당 행의 수
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.menuItems.count
    }
    
    // 셀 설정
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        Environment.debugPrint_START()
        
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
        
        Environment.debugPrint_END()
        return cell
    }
    
    // 셀 선택 시
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        Environment.debugPrint_START()
        
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
            self.showAlert(
                alertText: .leaveChatroom,
                alertType: .canCancel,
                confirmAction: { [weak self] in
                    self?.viewModel.leaveChatroom()
                }
            )
        default:
            print("Invalid row selected")
            return
        }
        
        Environment.debugPrint_END()
    }
}
// MARK: - GADFullScreenContentDelegate Methods
extension SideMenuViewController: GADFullScreenContentDelegate {
    // 정상적으로 광고가 로드되었을 경우
    func adDidRecordImpression(_ ad: GADFullScreenPresentingAd) {
        Environment.debugPrint_START()
        
        isRewardedAdLoaded = false
        
        Environment.debugPrint_END()
    }

    // 광고가 닫힌 후
    func adDidDismissFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        Environment.debugPrint_START()
        
        if hadAdError {
            self.showAlert(alertText: .adError, alertType: .onlyConfirm)
            self.hadAdError = false
        }
        
        // 광고가 닫힌 후 새로운 광고를 로드합니다.
        loadRewardedAd()
        
        Environment.debugPrint_END()
    }
    
    // 광고 표시에 실패했을 겨우
    func ad(_ ad: GADFullScreenPresentingAd, didFailToPresentFullScreenContentWithError error: Error) {
        Environment.debugPrint_START()
        
        print("광고 표시에 실패했습니다: \(error.localizedDescription)")
        
        Environment.debugPrint_END()
    }

    // 광고 표시하기 전
    func adWillPresentFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        Environment.debugPrint_START()
        
        print("광고가 풀 스크린으로 표시될 예정입니다.")
        
        Environment.debugPrint_END()
    }
}
