//
//  sendButton.swift
//  chat_AI
//
//  Created by 조웅희 on 2023/04/11.
//

import UIKit

class SendButton: UIButton {
    
    override var isHighlighted: Bool {
        didSet {
            updateTintColor()
        }
    }
    
    override var isEnabled: Bool {
        didSet {
            updateTintColor()
        }
    }
    
    private func updateTintColor() {
        if isEnabled {
            tintColor = isHighlighted ? UIColor(red: 225/255.0, green: 224/255.0, blue: 214/255.0, alpha: 1.0) : UIColor(red: 225/255.0, green: 224/255.0, blue: 214/255.0, alpha: 0.8)
        } else {
            tintColor = UIColor(red: 225/255.0, green: 224/255.0, blue: 214/255.0, alpha: 0.45)
        }
    }
}

