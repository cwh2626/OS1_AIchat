//
//  BubbleLabel.swift
//  chat_AI
//
//  Created by 조웅희 on 2023/03/31.
//

import UIKit

class BubbleLabel: UILabel {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
        
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    convenience init(frame: CGRect = .zero,isUser: Bool) {
        self.init(frame: frame)
        configureLabelAppearanceForUser(isUser)
    }
    
    private func commonInit() {
        textColor = .white
        numberOfLines = 0
        lineBreakMode = .byWordWrapping
        backgroundColor = .clear
        translatesAutoresizingMaskIntoConstraints = false
    }
    
    private func configureLabelAppearanceForUser(_ isUser: Bool = true) {
        textAlignment = .left
        layer.backgroundColor = isUser ? UIColor.blue.cgColor : UIColor.gray.cgColor
    }
}
