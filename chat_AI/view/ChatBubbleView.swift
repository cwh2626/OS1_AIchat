//
//  ChatBubbleView.swift
//  chat_AI
//
//  Created by 조웅희 on 2023/04/06.
//

import UIKit

class ChatBubbleView: UIView {
    let label = PaddedLabel()

    init(text: String, isUser: Bool) {
        super.init(frame: .zero)

        setupLabel(text: text, isUser: isUser)
        setupLayout(isUser: isUser)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupLabel(text: String, isUser: Bool) {
        label.text = text
        label.numberOfLines = 0
        label.textAlignment = .left
        label.lineBreakMode = .byWordWrapping
        label.textColor = isUser ? .secondaryBackgroundColor : .secondaryBackgroundColor
        label.layer.backgroundColor = isUser ? UIColor(red: 220/255.0, green: 98/255.0, blue: 79/255.0, alpha: 0.8).cgColor : UIColor(red: 220/255.0, green: 98/255.0, blue: 79/255.0, alpha: 1.0).cgColor
        label.translatesAutoresizingMaskIntoConstraints = false
        label.layer.masksToBounds = true
        label.layer.cornerRadius = 18 // 둥근 모서리 각도 설정
        
        
        addSubview(label)
    }

    private func setupLayout(isUser:  Bool) {
        translatesAutoresizingMaskIntoConstraints = false

        let labelMargin: CGFloat = 10

        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: topAnchor),
            label.bottomAnchor.constraint(equalTo: bottomAnchor),
            label.widthAnchor.constraint(lessThanOrEqualTo: widthAnchor, multiplier: 0.8)
        ])

        if isUser {
            label.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -labelMargin).isActive = true
        } else {
            label.leadingAnchor.constraint(equalTo: leadingAnchor, constant: labelMargin).isActive = true
        }
    }
}
