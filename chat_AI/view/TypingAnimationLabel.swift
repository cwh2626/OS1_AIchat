//
//  TypingAnimationLabel.swift
//  chat_AI
//
//  Created by 조웅희 on 2023/06/27.
//

import UIKit

class TypingAnimationLabel: UILabel {
    var typingAnimationDuration: Double = 0.1
    private var originalText: String?

    func startTypingAnimation() {
        guard let originalText = text else { return }
        self.originalText = originalText
        text = ""

        // 각 글자가 서서히 나타나는 애니메이션 구현
        for (index, character) in originalText.enumerated() {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5 * Double(index)) {
                self.text?.append(character)
            }
        }
//
//        DispatchQueue.global().async {
//            for (index, character) in originalText.enumerated() {
//                Thread.sleep(forTimeInterval: self.typingAnimationDuration)
//                DispatchQueue.main.async {
//                    self.text?.append(character)
//                }
//            }
//        }
    }

    func stopTypingAnimation() {
        text = originalText
    }
}

