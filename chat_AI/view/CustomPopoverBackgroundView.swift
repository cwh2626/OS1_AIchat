//
//  CustomPopoverBackgroundView.swift
//  chat_AI
//
//  Created by 조웅희 on 2023/05/24.
//

import UIKit

class CustomPopoverBackgroundView: UIPopoverBackgroundView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        layer.borderColor = UIColor.red.cgColor
        layer.borderWidth = 2
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // 필수적으로 구현해야 하는 UIPopoverBackgroundView의 속성들
//    override var arrowHeight: CGFloat { return 0 }
//    override var arrowBase: CGFloat { return 0 }
    override var arrowOffset: CGFloat { get { return 0 } set { } }
    override var arrowDirection: UIPopoverArrowDirection { get { return .up } set { } }
}
