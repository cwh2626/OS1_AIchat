//
//  OSSettingsViewController.swift
//  chat_AI
//
//  Created by 조웅희 on 2023/05/08.
//

import UIKit
import RxSwift
import RxCocoa

/// OS1 행동 및 성격 설정 페이지
class OSSettingsViewController: UIViewController, CustomTableViewCellDelegate {
    // MARK: - Properties and Constants
    private var isStartupView: Bool
    private let toolTipMessage = "우측 상단의 '+' 버튼을 눌러 OS를 커스텀하세요. 성격, 행동 등을 직접 설정할 수 있습니다.\n\n최대 5개의 설정 카드를 추가할 수 있으며, 영어로 설정하는 것이 인식률을 향상시킬 수 있습니다."
    private var cellHeights: [CGFloat] = []
    private var sysData: [chatVO] = []
    private let cellIdentifier = "CustomCell"
    private var expandedCellIndexPath: IndexPath?
    private var viewModel = OSSettingsViewModel() // 뷰 모델 인스턴스
    
    // conbine의.store(in: &cancellables) 와 비슷한기능이다 disposeBag 담아 두었다가 해당 변수가 deinit 타이밍에 dispose 하는 구조이다.
    // Observable의 메모리 누수 방지를 위한 자동 구독해지 기능이라고 생각하면 편할듯
    private let disposeBag = DisposeBag()
        
    // MARK: - UI Components
    
    private var settingCardTableView: UITableView = {
        let tableView = UITableView()
        tableView.backgroundColor = .secondaryBackgroundColor
        tableView.separatorStyle = .none
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()

    private var startButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitleColor(UIColor.secondaryBackgroundColor, for: .normal)
        button.backgroundColor = .primaryBackgroundColor
        button.layer.cornerRadius = 5
        button.setTitle("OS 생성", for: .normal)
        button.setTitleColor(.secondaryBackgroundColor, for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 20)
        button.isHidden = true
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

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
    
    // MARK: - View Lifecycle
    
    init(isStartupView: Bool) {
        self.isStartupView = isStartupView
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad(){
        debugPrint_START()
        
        super.viewDidLoad()
        setupUI()
        sysData = viewModel.loadData()
        
        debugPrint_END()
    }
    
    // 나타날 때 알림 보내기
    override func viewDidAppear(_ animated: Bool) {
        debugPrint_START()
        
        super.viewDidAppear(animated)
        if isStartupView {
            showTooltip(sender: (topNavigationBar.items?.first?.rightBarButtonItems?.last)!)
        }
        
        // 메인채팅방에서 키보드 문제로 인한 코드 -- 수정 필요 -- MainViewController 리펙토링 할 때 같이 진행
        NotificationCenter.default.post(name: .childViewControllerDidAppear, object: nil)
        
        debugPrint_END()
    }

    // 사라질 때 알림 보내기
    override func viewDidDisappear(_ animated: Bool) {
        debugPrint_START()
        
        super.viewDidDisappear(animated)
        // 메인채팅방에서 키보드 문제로 인한 코드 -- 수정 필요 -- MainViewController 리펙토링 할 때 같이 진행
        NotificationCenter.default.post(name: .childViewControllerDidDisappear, object: nil)
        
        debugPrint_END()
    }
    
    
    // MARK: - Action Methods

    @objc func startButtonTapped(_ sender: UIButton) {
        debugPrint_START()
        // 현재 뷰 컨트롤러에서 다음 뷰 컨트롤러를 모달로 표시합니다.
        saveSystemSettings()
        
        let mainVC = MainViewController()

        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let sceneDelegate = windowScene.delegate as? SceneDelegate {
            sceneDelegate.changeRootVC(mainVC, animated: true)
        }
        
        debugPrint_END()
    }
    
    @objc private func showTooltip(sender: UIBarButtonItem) {
        debugPrint_START()
        
        // 팝오버로 표시할 뷰 컨트롤러 생성
        let tipsVC = TooltipViewController(message: toolTipMessage)
        
        if let popoverController = tipsVC.popoverPresentationController {
            popoverController.barButtonItem = sender
            popoverController.permittedArrowDirections = .any
            popoverController.delegate = self
        }

        // 팝오버 표시
        self.present(tipsVC, animated: true, completion: nil)

        debugPrint_END()
    }
    
    // 플러스 버튼이 눌렸을 때 실행되는 메서드
    @objc private func addButtonTapped() {
        debugPrint_START()
        
        // 설정카드가 5개를 초과할 경우 경고 얼러터 표시
        guard self.settingCardTableView.numberOfRows(inSection: 0) < 5 else { return showAlert() }
        
        let indexPath = IndexPath(row: self.sysData.count, section: 0)
        self.sysData.append(chatVO.init())
        settingCardTableView.insertRows(at: [indexPath], with: .automatic)
        
        debugPrint_END()
    }
    
    @objc private func closeButtonTapped() {
        debugPrint_START()
        
        saveSystemSettings()
        self.dismiss(animated: true)
        
        debugPrint_END()
    }
    
    // MARK: - Interface Setup
    
    // UI초기화 메서드
    private func setupUI() {
        debugPrint_START()
        
        view.backgroundColor = .tertiaryBackgroundColor
        
        // 테이블 하단컨테이너뷰 생성
        let settingCardFooterView = UIView(frame: CGRect(x: 0, y: 0, width: settingCardTableView.bounds.width, height: 100))
        
        // 테이블 뷰 초기화 및 설정
        self.settingCardTableView.delegate = self
        self.settingCardTableView.dataSource = self
        self.settingCardTableView.register(CustomTableViewCell.self, forCellReuseIdentifier: cellIdentifier)
        self.settingCardTableView.tableFooterView = settingCardFooterView
        
        startButton.addTarget(self, action: #selector(startButtonTapped(_:)), for: .touchUpInside)

        settingCardFooterView.addSubview(startButton)
        view.addSubview(settingCardTableView)
        view.addSubview(topNavigationBar)
        setupNavigationbar()

        if isStartupView {
            self.startButton.isHidden = false
        }
        
        // 레이아웃 설정
        NSLayoutConstraint.activate([
            settingCardTableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            settingCardTableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            settingCardTableView.topAnchor.constraint(equalTo: topNavigationBar.bottomAnchor),
            settingCardTableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            // topNavigationBar
            topNavigationBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            topNavigationBar.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            topNavigationBar.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            
            // startButton
            startButton.centerXAnchor.constraint(equalTo: settingCardFooterView.centerXAnchor),
            startButton.centerYAnchor.constraint(equalTo: settingCardFooterView.centerYAnchor),
            startButton.widthAnchor.constraint(equalToConstant: 100),
            startButton.heightAnchor.constraint(equalToConstant: 50)
        ])
        
        debugPrint_END()
    }
    
    private func setupNavigationbar() {
        debugPrint_START()
        
        let navigationItem = UINavigationItem()
        
        // 플러스 버튼 생성
        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addButtonTapped))
        
        // 물음표 버튼 생성
        let infoButton = UIBarButtonItem(image: UIImage(systemName: "questionmark.circle"), style: .plain, target: self, action: #selector(showTooltip))
        
        infoButton.tintColor = .secondaryBackgroundColor
        addButton.tintColor = .secondaryBackgroundColor
        
        navigationItem.titleView = self.titleLabel
        navigationItem.rightBarButtonItems = [addButton,infoButton]
        
        // 초기설정 화면이 아닐경우 클로즈(x)버튼 추가
        if !isStartupView {
            let closeButton = UIBarButtonItem(image: UIImage(systemName: "xmark"), style: .plain, target: self, action: #selector(closeButtonTapped))
            closeButton.tintColor = .secondaryBackgroundColor
            navigationItem.leftBarButtonItem = closeButton
        }

        self.topNavigationBar.items = [navigationItem]
        
        debugPrint_END()
    }
    
    // MARK: - Utility Methods
    
    // CustomTableViewCellDelegate 프로토콜의 델리게이트 함수
    func textViewDidChange(text: String, cell: CustomTableViewCell) {
        debugPrint_START()
        
        let indexPath = settingCardTableView.indexPath(for: cell)!
        let textView = cell.textView
        let size = textView.frame.size
        let characterLimitLabellineHeight = cell.characterLimitLabel.font.lineHeight
        let newSize = textView.sizeThatFits(CGSize(width: size.width, height: CGFloat.greatestFiniteMagnitude))

        // 새로운 높이가 이전 높이와 다른지 확인
        if newSize.height + 10 + characterLimitLabellineHeight != cellHeights[indexPath.row] {
            cellHeights[indexPath.row] = newSize.height + 10 + characterLimitLabellineHeight
            settingCardTableView.beginUpdates()
            settingCardTableView.endUpdates()
        }
        
        debugPrint_END()
    }
    
    private func selectedCell(cell: CustomTableViewCell, indexPath: IndexPath) {
        debugPrint_START()
        
        expandedCellIndexPath = indexPath
        settingCardTableView.beginUpdates()
        settingCardTableView.endUpdates()
        cell.textView.isUserInteractionEnabled = true // 뷰가 사용자의 터치 이벤트를 받아들일 수 있는지 여부
        cell.textView.isEditable = true
        
        // `becomeFirstResponder()` 메서드는 해당 객체를 첫 번째 응답자로 만듭니다.
        // 이 메서드를 호출하면, 객체는 사용자의 입력 및 이벤트에 응답할 준비가 된 상태가 됩니다.
        // 예: UITextField나 UITextView에서 호출하면, 해당 객체가 활성화되고 키보드가 표시됩니다.
        cell.textView.becomeFirstResponder()
        
        cell.characterLimitLabel.isHidden = false
        UIView.animate(withDuration: 0.3, delay: 0.0, options: .curveEaseInOut) {
            cell.characterLimitLabel.alpha = 1.0
        }
        
        debugPrint_END()
    }
    
    private func deselectedCell(cell: CustomTableViewCell, indexPath: IndexPath) {
        debugPrint_START()
        
        expandedCellIndexPath = nil
        settingCardTableView.beginUpdates()
        settingCardTableView.endUpdates()
        self.sysData[indexPath.row].content = cell.textView.text
        cell.textView.isUserInteractionEnabled = false
        cell.textView.isEditable = false
        
        // becomeFirstResponder() 메서드의 반대로 동작합니다.
        // 첫 번째 응답자 상태를 포기하도록 합니다.
        cell.textView.resignFirstResponder()
        UIView.animate(withDuration: 0.3, delay: 0.0, options: .curveEaseInOut, animations: {
            cell.characterLimitLabel.alpha = 0.0
        }, completion: { finished in
            cell.characterLimitLabel.isHidden = true
        })
        
        debugPrint_END()
    }
    
    private func saveSystemSettings(){
        debugPrint_START()
        
        // 선택된 행의 선택 상태를 해제합니다.(해제 타이밍에 sysData값이 갱신 되기 때문에 deselectedCell() 함수 확인)
        if let selectedIndexPath = settingCardTableView.indexPathForSelectedRow {
            settingCardTableView.deselectRow(at: selectedIndexPath, animated: true)
            if let cell = settingCardTableView.cellForRow(at: selectedIndexPath) as? CustomTableViewCell {
                deselectedCell(cell: cell, indexPath: selectedIndexPath)
            }
        }
        
        // 입력되어진 시스템설정 값들중 공백의 경우는 필터로 배열에서 제거한다.
        let filteredArr = self.sysData.filter { $0.content.trimmingCharacters(in: .whitespacesAndNewlines) != "" }
        // 입력되어진 시스템설정 텍스트를 뷰모델로 보냄
        viewModel.settingsitems.accept(filteredArr)
        
        debugPrint_END()
    }
    
    private func tintedImage(image: UIImage, color: UIColor) -> UIImage {
        debugPrint_START()
        
        // 새로운 그림을 그릴 '캔버스'를 만들어줍니다. 그림의 크기는 원본 이미지의 크기와 같습니다.
        UIGraphicsBeginImageContextWithOptions(image.size, false, image.scale)
        
        // '붓'을 준비합니다. 이 붓은 우리가 그림을 그릴 도구입니다.
        let context = UIGraphicsGetCurrentContext()!
        
        // 붓에 물감을 묻힙니다. 우리가 원하는 색깔로 물감을 묻힙니다.
        color.setFill()
        
        // 캔버스를 돌려서, 그림을 그릴 때 아래에서 위로 그릴 수 있게 합니다.
        // 이는 그림을 그리는 방향이 컴퓨터와 사람이 다르기 때문입니다.
        context.translateBy(x: 0, y: image.size.height)
        context.scaleBy(x: 1.0, y: -1.0)
        
        // 우리가 그림을 그릴 방법을 정합니다. 여기서는 일반적인 방법을 선택합니다.
        context.setBlendMode(.normal)
        
        // 캔버스에 그림을 그릴 영역을 정합니다. 그림을 그릴 영역은 원본 이미지의 크기와 같습니다.
        let rect = CGRect(x: 0, y: 0, width: image.size.width, height: image.size.height)
        
        // 우리가 그림을 그릴 영역을 마스킹 테이프로 붙여서 정확하게 그 영역에만 그릴 수 있게 합니다.
        context.clip(to: rect, mask: image.cgImage!)
        
        // 정해진 영역에 물감을 칠합니다.
        context.fill(rect)
        
        // 그린 그림을 떼어냅니다. 이제 이 그림은 새로운 이미지가 되었습니다.
        let newImage = UIGraphicsGetImageFromCurrentImageContext()!
        
        // 캔버스를 치웁니다. 그림을 다 그렸으니, 더 이상 캔버스가 필요하지 않습니다.
        UIGraphicsEndImageContext()
        
        debugPrint_END()
        
        // 새로 그린 그림을 돌려줍니다.
        return newImage
    }
    
    
}

// MARK: - Extensions

extension OSSettingsViewController: CustomAlertDelegate {
    // CustomAlertDelegate 메서드 구현
    func handleConfirmAction() {
        print("확인 버튼을 눌렀습니다.")
    }

    func handleCancelAction() {
        print("취소 버튼을 눌렀습니다.")
    }
    
    func showAlert() {
        debugPrint_START()
        
        let customAlertVC = CustomAlertViewController(
            alertText: "설정 카드는 최대 5개까지만\n추가하실 수 있습니다.",
            alertType: .onlyConfirm,
            delegate: self
        )

        present(customAlertVC, animated: true, completion: nil)
        
        debugPrint_END()
    }
    
    
}

extension OSSettingsViewController: UITableViewDataSource, UITableViewDelegate {
    // MARK: - UITableViewDataSource Methods
    
    // 테이블 뷰의 섹션 수를 반환합니다. 여기서는 하나의 섹션만 사용합니다.
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    // 테이블 뷰의 셀 수를 반환합니다. 여기서는 데이터 배열의 크기에 1을 더하여 마지막에 플러스 버튼이 있는 셀을 추가합니다.
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sysData.count
    }

    // 각 셀을 설정하는 메소드입니다.
    // tableView.rowHeight = UITableView.automaticDimension 을 이용해서 컨테츠의 크기에 맞추어 자동으로 높이를 측정해주는 기능이 있지만
    // 현재 텍스트뷰의 위에 제한수를 띄우고 있기에 아래와 같은 메서드를 활용
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        debugPrint_START()
        
        // 재사용 가능한 셀을 큐에서 가져옵니다. 해당 셀이 CustomTableViewCell 타입이 아니면 기본 UITableViewCell을 반환합니다.
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? CustomTableViewCell else {return UITableViewCell()}
        cell.delegate = self
        cell.textView.text = sysData[indexPath.row].content
        
        cell.textView.layoutIfNeeded()
        
        cell.characterLimitLabelInit(textRange: sysData[indexPath.row].content.count)
        let size = cell.textView.bounds.size
        let newSize = cell.textView.sizeThatFits(CGSize(width: size.width, height: CGFloat.greatestFiniteMagnitude))

        cellHeights.append(newSize.height + 10 + cell.characterLimitLabel.font.lineHeight)
        
        debugPrint_END()
        
        return cell
    }
    
    // MARK: - UITableViewDelegate Methods
    
    // 유저가 직접 셀을 선택되었을 때 호출되는 메소드입니다.
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        debugPrint_START()
        
        guard let cell = tableView.cellForRow(at: indexPath) as? CustomTableViewCell else { return }
        self.selectedCell(cell: cell, indexPath: indexPath)
        
        debugPrint_END()
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        debugPrint_START()
        
        guard let cell = tableView.cellForRow(at: indexPath) as? CustomTableViewCell else { return }
        self.deselectedCell(cell: cell, indexPath: indexPath)
        
        debugPrint_END()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        debugPrint_START()
        guard cellHeights.indices.contains(indexPath.row) else {
            return 100
        }

        if indexPath == expandedCellIndexPath {
            
            debugPrint_END()
            
            return cellHeights[indexPath.row]
        } else {
            let font = UIFont.systemFont(ofSize: 12)
            let lineHeight = font.lineHeight
            
            debugPrint_END()
            
            return cellHeights[indexPath.row] - lineHeight
        }
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        debugPrint_START()
        
        // 선택 활성화가된 행의 선택 상태를 해제합니다.
        if let selectedIndexPath = tableView.indexPathForSelectedRow {
            tableView.deselectRow(at: selectedIndexPath, animated: true)
            if let cell = tableView.cellForRow(at: selectedIndexPath) as? CustomTableViewCell {
                deselectedCell(cell: cell, indexPath: selectedIndexPath)
            }
        }
        
        // "삭제" 스와이프 액션 정의
        let deleteAction = UIContextualAction(style: .destructive, title: nil) { (action, sourceView, completionHandler) in
            // 해당 행의 데이터와 높이 정보를 삭제
            self.sysData.remove(at: indexPath.row)
            self.cellHeights.remove(at: indexPath.row)
            
            // 애니메이션과 함께 테이블 뷰에서 해당 행을 삭제
            tableView.deleteRows(at: [indexPath], with: .automatic)
            
            // 액션이 성공적으로 완료되었음을 알립
            completionHandler(true)
        }
        
        // 액션에 표시될 이미지와 배경색을 설정
        deleteAction.image = tintedImage(image: UIImage(named: "trash")!, color: UIColor.tertiaryBackgroundColor)
        deleteAction.backgroundColor = .secondaryBackgroundColor

        let configuration = UISwipeActionsConfiguration(actions: [deleteAction])

        debugPrint_END()
        
        return configuration
    }

}

extension OSSettingsViewController: UIPopoverPresentationControllerDelegate {
    /// `adaptivePresentationStyle(for:)`는 `UIAdaptivePresentationControllerDelegate` 프로토콜의 메서드입니다.
    /// 이 메서드는 뷰 컨트롤러의 presentation 스타일이 환경 변화 (예: 디바이스 회전)에 따라 어떻게 적응해야 하는지 결정하는 데 사용됩니다.
    ///
    /// 예를 들어, 아이패드에서 popover로 표시되는 뷰 컨트롤러가 있을 때, 디바이스가 가로 모드에서 세로 모드로 회전하면 popover는 기본적으로 전체 화면 모달로 바뀔 수 있습니다.
    /// 그러나 `adaptivePresentationStyle(for:)`에서 `.none`을 반환하면, 회전에도 불구하고 popover 스타일이 그대로 유지됩니다.
    ///
    /// - Parameter controller: 적응적 presentation 스타일을 결정하는 데 사용되는 presentation controller입니다.
    /// - Returns: 적응적 presentation 스타일. 여기서는 `.none`을 반환하여 환경 변화에도 presentation 스타일이 변경되지 않게 합니다.
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
}
