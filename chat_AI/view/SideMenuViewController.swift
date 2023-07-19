//
//  SideMenuViewController.swift
//  chat_AI
//
//  Created by 조웅희 on 2023/04/18.
//

import UIKit

class SideMenuViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let label = UILabel()
        label.text = "SIDE-MENU"
        label.font = UIFont.systemFont(ofSize: 30) // 폰트 크기 변경
        label.textColor = UIColor(red: 225/255.0, green: 224/255.0, blue: 214/255.0, alpha: 1.0)
        label.sizeToFit()
        label.translatesAutoresizingMaskIntoConstraints = false // Auto Layout을 사용하기 위해 필요

        
        self.view.addSubview(label)
        
        // 사이드 메뉴의 배경색 지정
        self.view.backgroundColor = UIColor.darkGray
        // 가운데 정렬 제약 조건 추가
        label.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        label.centerYAnchor.constraint(equalTo: self.view.centerYAnchor).isActive = true

    }
}

