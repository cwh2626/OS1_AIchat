//
//  OSSettingsViewController.swift
//  chat_AI
//
//  Created by 조웅희 on 2023/05/08.
//

import UIKit

class OSSettingsViewController: UIViewController {
    // MyTableViewController 인스턴스를 저장할 변수 생성
    var tableViewController: OSSettingsTableViewController!
    var isStartupView: Bool
    
    init(isStartupView: Bool) {
        self.isStartupView = isStartupView
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // 탑툴바를 생성합니다.
    private let topNavigationBar: UINavigationBar = {
        let toolbar = UINavigationBar()
        toolbar.isTranslucent = false  // 블러처리 유무 default = true
        toolbar.barTintColor = .tertiaryBackgroundColor
        toolbar.translatesAutoresizingMaskIntoConstraints = false
        return toolbar
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "OS Settings"
        label.font = UIFont.systemFont(ofSize: 30) // 폰트 크기 변경
        label.textColor = .secondaryBackgroundColor
        label.sizeToFit()
    
        return label
    }()
    
    private func setupNavigationbar() {
        let navigationItem = UINavigationItem()
        // 플러스 버튼 생성
        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addButtonTapped))
        
        let infoButton = UIBarButtonItem(image: UIImage(systemName: "questionmark.circle"), style: .plain, target: self, action: #selector(showTooltip))
        
        

        infoButton.tintColor = .secondaryBackgroundColor
        addButton.tintColor = .secondaryBackgroundColor
        
        
        navigationItem.titleView = self.titleLabel
        navigationItem.rightBarButtonItems = [addButton,infoButton]
        
        if !isStartupView {
            let closeButton = UIBarButtonItem(image: UIImage(systemName: "xmark"), style: .plain, target: self, action: #selector(closeButtonTapped))
            closeButton.tintColor = .secondaryBackgroundColor
            navigationItem.leftBarButtonItem = closeButton
        }

        self.topNavigationBar.items = [navigationItem]
    }
    
    @objc func showTooltip(sender: UIBarButtonItem) {
        // 팝오버로 표시할 뷰 컨트롤러 생성
        let message = "우측 상단의 '+' 버튼을 눌러 OS를 커스텀하세요. 성격, 행동 등을 직접 설정할 수 있습니다.\n\n최대 5개의 설정 카드를 추가할 수 있으며, 영어로 설정하는 것이 인식률을 향상시킬 수 있습니다."
        let tipsVC = TooltipViewController(message: message)
        
        if let popoverController = tipsVC.popoverPresentationController {
            popoverController.barButtonItem = sender
            popoverController.permittedArrowDirections = .any
            popoverController.delegate = self
        }

        // 팝오버 표시
        self.present(tipsVC, animated: true, completion: nil)

    }
    
    // 플러스 버튼이 눌렸을 때 실행되는 메서드
    @objc func addButtonTapped() {
        print("플러스 버튼이 눌렸습니다.", tableViewController.getCurrentCellCount())
        
        guard tableViewController.getCurrentCellCount() < 5 else { return showAlert() }
        tableViewController.addCell()
    }
    
    @objc func closeButtonTapped() {
        tableViewController.saveSystemSettings()
        self.dismiss(animated: true)
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    // 나타날 때 알림 보내기
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if isStartupView {
            showTooltip(sender: (topNavigationBar.items?.first?.rightBarButtonItems?.last)!)
        }
        NotificationCenter.default.post(name: .childViewControllerDidAppear, object: nil)
    }

    // 사라질 때 알림 보내기
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        NotificationCenter.default.post(name: .childViewControllerDidDisappear, object: nil)
    }
    
    // UI초기화 메서드
    private func setupUI() {
        view.backgroundColor = .tertiaryBackgroundColor
        // MyTableViewController 인스턴스 생성
        tableViewController = OSSettingsTableViewController()
        addChild(tableViewController)
        if isStartupView {
            tableViewController.startButton.isHidden = false            
        }
        // 뷰 추가
        let tableView = tableViewController.view
        tableView?.translatesAutoresizingMaskIntoConstraints = false        
        view.addSubview(tableView!)
        view.addSubview(topNavigationBar)
        setupNavigationbar()

        // 레이아웃 설정
        NSLayoutConstraint.activate([
            tableView!.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            tableView!.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            tableView!.topAnchor.constraint(equalTo: topNavigationBar.bottomAnchor),
            tableView!.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            // topNavigationBar
            topNavigationBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            topNavigationBar.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            topNavigationBar.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
        ])

        // 컨테이너 뷰 컨트롤러로 추가
        tableViewController.didMove(toParent: self)
    }
}

extension OSSettingsViewController: CustomAlertDelegate {
    // CustomAlertDelegate 메서드 구현
    func handleConfirmAction() {
        print("확인 버튼을 눌렀습니다.")
    }

    func handleCancelAction() {
        print("취소 버튼을 눌렀습니다.")
    }
    
    func showAlert() {
        let customAlertVC = CustomAlertViewController(
            alertText: "설정 카드는 최대 5개까지만\n추가하실 수 있습니다.",
            alertType: .onlyConfirm,
            delegate: self
        )

        present(customAlertVC, animated: true, completion: nil)
    }
}

extension OSSettingsViewController: UIPopoverPresentationControllerDelegate {
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
}
