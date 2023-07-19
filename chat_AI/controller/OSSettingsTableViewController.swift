//
//  OSSettingsTableViewController.swift
//  chat_AI
//
//  Created by 조웅희 on 2023/05/02.
//

import UIKit
import RxSwift
import RxCocoa

class OSSettingsTableViewController: UITableViewController, CustomTableViewCellDelegate {
    var cellHeights: [CGFloat] = []
    var sysData: [chatVO] = []
    let cellIdentifier = "CustomCell"
    var expandedCellIndexPath: IndexPath?
    
    private var viewModel = OSSettingsViewModel() // 뷰 모델 인스턴스
    // conbine의.store(in: &cancellables) 와 비슷한기능이다 disposeBag 담아 두었다가 해당 변수가 deinit 타이밍에 dispose 하는 구조이다.
    // Observable의 메모리 누수 방지를 위한 자동 구독해지 기능이라고 생각하면 편할듯
    private let disposeBag = DisposeBag()
    
    func textViewDidChange(text: String, cell: CustomTableViewCell) {
        let indexPath = tableView.indexPath(for: cell)!
        let textView = cell.textView
        let size = textView.frame.size
        let characterLimitLabellineHeight = cell.characterLimitLabel.font.lineHeight
        let newSize = textView.sizeThatFits(CGSize(width: size.width, height: CGFloat.greatestFiniteMagnitude))

        // 새로운 높이가 이전 높이와 다른지 확인
        if newSize.height + 10 + characterLimitLabellineHeight != cellHeights[indexPath.row] {
            cellHeights[indexPath.row] = newSize.height + 10 + characterLimitLabellineHeight
            tableView.beginUpdates()
            tableView.endUpdates()
        }
    }

    var startButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitleColor(UIColor.secondaryBackgroundColor, for: .normal)
        button.backgroundColor = .primaryBackgroundColor
        button.layer.cornerRadius = 5
        button.setTitle("OS 생성", for: .normal)
        button.setTitleColor(.secondaryBackgroundColor, for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 20) // 폰트 사이즈를 20으로 변경
        button.isHidden = true
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableView.backgroundColor = .secondaryBackgroundColor
        self.tableView.separatorStyle = .none
        self.tableView.register(CustomTableViewCell.self, forCellReuseIdentifier: cellIdentifier)
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "buttonCell")
        startButton.addTarget(self, action: #selector(startButtonTapped(_:)), for: .touchUpInside)
        
        let footerView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.bounds.width, height: 100))
        footerView.addSubview(startButton)
        
        self.tableView.tableFooterView = footerView
        startButton.centerXAnchor.constraint(equalTo: footerView.centerXAnchor).isActive = true
        startButton.centerYAnchor.constraint(equalTo: footerView.centerYAnchor).isActive = true
        startButton.widthAnchor.constraint(equalToConstant: 100).isActive = true
        startButton.heightAnchor.constraint(equalToConstant: 50).isActive = true

        sysData = viewModel.loadData()
    }
 
    // 테이블 뷰의 섹션 수를 반환합니다. 여기서는 하나의 섹션만 사용합니다.
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    // 테이블 뷰의 셀 수를 반환합니다. 여기서는 데이터 배열의 크기에 1을 더하여 마지막에 플러스 버튼이 있는 셀을 추가합니다.
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sysData.count
    }

    // 각 셀을 설정하는 메소드입니다.
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? CustomTableViewCell else {return UITableViewCell()}
        cell.delegate = self
        cell.textView.text = sysData[indexPath.row].content
        cell.textView.layoutIfNeeded()
        cell.characterLimitLabelInit(textRange: sysData[indexPath.row].content.count)
        let size = cell.textView.bounds.size
        let newSize = cell.textView.sizeThatFits(CGSize(width: size.width, height: CGFloat.greatestFiniteMagnitude))

        cellHeights.append(newSize.height + 10 + cell.characterLimitLabel.font.lineHeight)
        return cell
    }
    
    func selectedCell(cell: CustomTableViewCell, indexPath: IndexPath) {
        expandedCellIndexPath = indexPath
        tableView.beginUpdates()
        tableView.endUpdates()
        cell.textView.isUserInteractionEnabled = true
        cell.textView.isEditable = true
        cell.textView.becomeFirstResponder()
        cell.characterLimitLabel.isHidden = false
        UIView.animate(withDuration: 0.3, delay: 0.0, options: .curveEaseInOut) {
            cell.characterLimitLabel.alpha = 1.0
        }
    }
    
    func deselectedCell(cell: CustomTableViewCell, indexPath: IndexPath) {
        expandedCellIndexPath = nil
        tableView.beginUpdates()
        tableView.endUpdates()
        self.sysData[indexPath.row].content = cell.textView.text
        cell.textView.isUserInteractionEnabled = false
        cell.textView.isEditable = false
        cell.textView.resignFirstResponder()
        UIView.animate(withDuration: 0.3, delay: 0.0, options: .curveEaseInOut, animations: {
            cell.characterLimitLabel.alpha = 0.0
        }, completion: { finished in
            cell.characterLimitLabel.isHidden = true
        })
    }
    
    // 유저가 직접 셀을 선택되었을 때 호출되는 메소드입니다.
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print(#function, indexPath)
        guard let cell = tableView.cellForRow(at: indexPath) as? CustomTableViewCell else { return }
        selectedCell(cell: cell, indexPath: indexPath)
    }
     
    
    func getCurrentCellCount() -> Int {
        return self.tableView.numberOfRows(inSection: 0)
    }
    
    func addCell() {
        let indexPath = IndexPath(row: self.sysData.count, section: 0)
        self.sysData.append(chatVO.init())
        tableView.insertRows(at: [indexPath], with: .automatic)
    }
    
    override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        print(#function, indexPath)
        guard let cell = tableView.cellForRow(at: indexPath) as? CustomTableViewCell else { return }
        deselectedCell(cell: cell, indexPath: indexPath)
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        print(#function)
        guard cellHeights.indices.contains(indexPath.row) else {
            return 100
        }

        if indexPath == expandedCellIndexPath {
            return cellHeights[indexPath.row]
        } else {
            let font = UIFont.systemFont(ofSize: 12)
            let lineHeight = font.lineHeight
            return cellHeights[indexPath.row] - lineHeight
        }
    }
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        print(#function)
        
        // 선택된 행의 선택 상태를 해제합니다.
        if let selectedIndexPath = tableView.indexPathForSelectedRow {
            print("선택되어진 인덱스",selectedIndexPath)
            tableView.deselectRow(at: selectedIndexPath, animated: true)
            if let cell = tableView.cellForRow(at: selectedIndexPath) as? CustomTableViewCell {
                deselectedCell(cell: cell, indexPath: selectedIndexPath)
            }
        }
        
        let deleteAction = UIContextualAction(style: .destructive, title: nil) { (action, sourceView, completionHandler) in
            // 셀 삭제 로직
            self.sysData.remove(at: indexPath.row)
            self.cellHeights.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
            
            // 핸들러 호출
            completionHandler(true)
        }
        deleteAction.image = tintedImage(image: UIImage(named: "trash")!, color: UIColor(red: 197/255.0, green: 62/255.0, blue: 41/255.0, alpha: 1.0))
        deleteAction.backgroundColor = .secondaryBackgroundColor

        let configuration = UISwipeActionsConfiguration(actions: [deleteAction])
        return configuration
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {

        return true
    }
    
    func saveSystemSettings(){
        // 선택된 행의 선택 상태를 해제합니다.
        if let selectedIndexPath = tableView.indexPathForSelectedRow {
            print("선택되어진 인덱스",selectedIndexPath)
            tableView.deselectRow(at: selectedIndexPath, animated: true)
            if let cell = tableView.cellForRow(at: selectedIndexPath) as? CustomTableViewCell {
                deselectedCell(cell: cell, indexPath: selectedIndexPath)
            }
        }
        
        // 입력되어진 시스템설정 값들중 공백의 경우는 필터로 배열에서 제거한다.
        let filteredArr = self.sysData.filter { $0.content.trimmingCharacters(in: .whitespacesAndNewlines) != "" }
        print(#function,filteredArr)
        // 입력되어진 시스템설정 텍스트를 뷰모델로 보냄
        viewModel.settingsitems.accept(filteredArr)
    }
    
    
    @objc func startButtonTapped(_ sender: UIButton) {
        // 현재 뷰 컨트롤러에서 다음 뷰 컨트롤러를 모달로 표시합니다.
        print(#function)
        saveSystemSettings()
        
        let mainVC = MainViewController()

        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let sceneDelegate = windowScene.delegate as? SceneDelegate {
            sceneDelegate.changeRootVC(mainVC, animated: true)
        }
    }
    
    func tintedImage(image: UIImage, color: UIColor) -> UIImage {
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
        
        // 새로 그린 그림을 돌려줍니다.
        return newImage
    }
    
}
