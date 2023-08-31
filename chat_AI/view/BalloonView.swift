//
//  BalloonView.swift
//  chat_AI
//
//  Created by 조웅희 on 2023/06/19.
//

import UIKit

/// 말풍선 커스텀뷰
class BalloonView: UIView {

    var message: String? {
        didSet {
            label.text = message
        }
    }
    
    private lazy var label: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = .black
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
        setupLabel()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func draw(_ rect: CGRect) {
        let width = rect.width
        let height = rect.height
        let path = UIBezierPath()

        let radius: CGFloat = 10
        path.move(to: CGPoint(x: width - 75, y: height))
        path.addLine(to: CGPoint(x: radius, y: height))
        path.addArc(withCenter: CGPoint(x: radius, y: height - radius), radius: radius, startAngle: CGFloat.pi / 2, endAngle: CGFloat.pi, clockwise: true)
        path.addLine(to: CGPoint(x: 0, y: radius))
        path.addArc(withCenter: CGPoint(x: radius, y: radius), radius: radius, startAngle: CGFloat.pi, endAngle: 3 * CGFloat.pi / 2, clockwise: true)
        path.addLine(to: CGPoint(x: width - radius, y: 0))
        path.addArc(withCenter: CGPoint(x: width - radius, y: radius), radius: radius, startAngle: 3 * CGFloat.pi / 2, endAngle: 2 * CGFloat.pi, clockwise: true)
        path.addLine(to: CGPoint(x: width, y: height - radius))
        path.addArc(withCenter: CGPoint(x: width - radius, y: height - radius), radius: radius, startAngle: 0, endAngle: CGFloat.pi / 2, clockwise: true)
        path.close()

        // 삼각형 추가
        path.move(to: CGPoint(x: width, y: height/2 - 5))
        path.addLine(to: CGPoint(x: width + 10, y: height / 2))
        path.addLine(to: CGPoint(x: width, y: height/2 + 5))
        
        path.close()

        let shapeLayer = CAShapeLayer()
        shapeLayer.path = path.cgPath
        shapeLayer.fillColor = UIColor.secondaryBackgroundColor.cgColor

        layer.insertSublayer(shapeLayer, at: 0)
    }
    
    private func setupLabel() {
        addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8),
            label.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8),
            label.topAnchor.constraint(equalTo: topAnchor, constant: 5),
            label.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -5),
        ])
    }
}
