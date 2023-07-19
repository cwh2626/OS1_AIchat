//
//  PaddedLabel.swift
//  chat_AI
//
//  Created by 조웅희 on 2023/04/06.
//

import UIKit

class PaddedLabel: UILabel {
    private var padding = UIEdgeInsets(top: 10.0, left: 10.0, bottom: 10.0, right: 10.0)
    
    convenience init(padding: UIEdgeInsets) {
        self.init()
        self.padding = padding
    }
    
    override func drawText(in rect: CGRect) {
        // 부모 클래스의 drawText 메서드를 호출하며, 텍스트가 그려지는 영역에 패딩을 적용합니다.
        super.drawText(in: rect.inset(by: padding))
    }
    
    // intrinsicContentSize를 오버라이드하여 패딩을 포함한 UILabel의 총 크기를 반환

    override var intrinsicContentSize: CGSize {
        let size = super.intrinsicContentSize
        
        return CGSize(width: size.width + padding.left + padding.right,
                      height: size.height + padding.top + padding.bottom)
    }
    
    // bounds가 변경될 때마다 preferredMaxLayoutWidth를 업데이트하여 텍스트가 패딩 영역을 침범하지 않도록 함
    override var bounds: CGRect {
        didSet { preferredMaxLayoutWidth = bounds.width - (padding.left + padding.right) }
    }
}

