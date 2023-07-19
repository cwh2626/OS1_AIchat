//
//  SideMenuTableViewController.swift
//  chat_AI
//
//  Created by 조웅희 on 2023/06/01.
//

import UIKit

class SideMenuTableViewController: UITableViewController {
    
    let menuItems = ["Settings", "Exit"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 테이블 뷰 셀 등록
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        self.tableView.backgroundColor = .secondaryBackgroundColor
        self.tableView.separatorStyle = .none

    }
        
    // 섹션당 행의 수
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return menuItems.count
    }
    
    // 셀 설정
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        // 이미지 설정
        cell.backgroundColor = UIColor.secondaryBackgroundColor
        if menuItems[indexPath.row] == "Settings" {
            cell.imageView?.image = UIImage(named: "setting")?.withRenderingMode(.alwaysTemplate)
        } else {
            cell.imageView?.image = UIImage(named: "exit")?.withRenderingMode(.alwaysTemplate)
        }
        cell.imageView?.tintColor = UIColor.primaryBackgroundColor
        cell.textLabel?.text = menuItems[indexPath.row]
        cell.textLabel?.textColor = UIColor.primaryBackgroundColor
        
        return cell
    }
    
    // 셀 선택 시
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
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
            showAlert()
        default:
            print("Invalid row selected")
            return
        }
        
    }
}

extension SideMenuTableViewController: CustomAlertDelegate {
    // CustomAlertDelegate 메서드 구현
    func handleConfirmAction() {
        let chatDAO = ChatHistoryDAO()
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
