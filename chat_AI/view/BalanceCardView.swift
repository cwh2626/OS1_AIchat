//
//  BalanceCardCell.swift
//  chat_AI
//
//  Created by 조웅희 on 2023/06/14.
//

import UIKit
import RxSwift
import RxCocoa

/// 사이드메뉴의 토큰관리 커스텀뷰
class BalanceCardView: UIView {
    // MARK: - Properties
    private let layerPadding: UIEdgeInsets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
    
    // MARK: - UI Components
    let tokenLabel: UILabel = {
        let label = UILabel()
        label.textColor = .secondaryBackgroundColor
        label.font = UIFont.systemFont(ofSize: 32)
        label.adjustsFontSizeToFitWidth = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let balanceLabel: UILabel = {
        let label = UILabel()
        label.textColor = .secondaryBackgroundColor.withAlphaComponent(0.8)
        label.text = "보유 토큰"
        label.font = UIFont.systemFont(ofSize: 14)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let separatorView: UIView = {
        let view = UIView()
        view.backgroundColor = .secondaryBackgroundColor.withAlphaComponent(0.3)
        view.heightAnchor.constraint(equalToConstant: 0.5).isActive = true  // 선의 두께를 결정
        return view
    }()
    
    private let balanceCardstackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.distribution = .fill
        stackView.alignment = .fill
        stackView.spacing = 10
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.backgroundColor = .clear
        return stackView
    }()
    
    private let balloonView: UIView = {
        let view = BalloonView(frame: CGRect(x: 0, y: 0, width: 85, height: 30))
        view.message = "4K 무료충전!"
        return view
    }()
    
    private let chargeContainerView: UIView = {
        let view = UIView()
        return view
        
    }()
    
    private let innerChargeContainerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
        
    }()
    
    private let limitContainerView: UIView = {
        let view = UIView()
        return view
        
    }()
    
    let chargeButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(UIImage(named: "ad_video")?.withRenderingMode(.alwaysTemplate), for: .normal)
        button.tintColor = UIColor.secondaryBackgroundColor
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let limitLabel: UILabel = {
        let label = UILabel()
        label.textColor = .secondaryBackgroundColor
        label.font = UIFont.systemFont(ofSize: 18)
        label.text = "OS 용량"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let limitValueLabel: UILabel = {
        let label = UILabel()
        label.textColor = .secondaryBackgroundColor.withAlphaComponent(0.8)
        label.font = UIFont.systemFont(ofSize: 14) // 시스템 기본 폰트의 크기를 20으로 설정
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    
    let limitProgressBar: UIProgressView = {
        let progressBar = UIProgressView(progressViewStyle: .default)
        progressBar.tintColor = .secondaryBackgroundColor
        progressBar.transform = progressBar.transform.scaledBy(x: 1, y: 2)  // y값을 줄여서 두께를 조절
        progressBar.translatesAutoresizingMaskIntoConstraints = false
        return progressBar
    }()
    
    private let floatingAnimation: CABasicAnimation = {
        let animation = CABasicAnimation(keyPath: "transform.translation.y")
        animation.duration = 1.0
        animation.repeatCount = Float.infinity
        animation.autoreverses = true
        animation.fromValue = -1.5
        animation.toValue = 1.5
        animation.isRemovedOnCompletion = false //애니메이션이 완료된 후에도 레이어에서 애니메이션을 제거하지 않음
        return animation
    }()
    
    // MARK: - Initializers
    init() {
        super.init(frame: .zero)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Interface Setup
    private func setupViews() {
        self.layer.cornerRadius = 10
        self.backgroundColor = .primaryBackgroundColor
                
        limitContainerView.addSubview(limitLabel)
        limitContainerView.addSubview(limitValueLabel)
        
        let viewsToAdd = [balanceLabel, tokenLabel, chargeContainerView, separatorView, limitContainerView, limitProgressBar]

        for view in viewsToAdd {
            balanceCardstackView.addArrangedSubview(view)
        }

        innerChargeContainerView.addSubview(chargeButton)
        innerChargeContainerView.addSubview(balloonView)
        chargeContainerView.addSubview(innerChargeContainerView)
        addSubview(balanceCardstackView)
        
        chargeButton.layer.add(floatingAnimation, forKey: "buttonFloatingAnimation")
                
        NSLayoutConstraint.activate([
            balanceCardstackView.topAnchor.constraint(equalTo: self.topAnchor, constant: layerPadding.top),
            balanceCardstackView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: layerPadding.left),
            balanceCardstackView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -layerPadding.right),
            balanceCardstackView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -layerPadding.bottom),
            balanceCardstackView.heightAnchor.constraint(equalToConstant: 160),
            
            innerChargeContainerView.trailingAnchor.constraint(equalTo: chargeContainerView.trailingAnchor),
            innerChargeContainerView.topAnchor.constraint(equalTo: chargeContainerView.topAnchor),
            innerChargeContainerView.bottomAnchor.constraint(equalTo: chargeContainerView.bottomAnchor),
            
            chargeButton.trailingAnchor.constraint(equalTo: innerChargeContainerView.trailingAnchor),
            chargeButton.centerYAnchor.constraint(equalTo: innerChargeContainerView.centerYAnchor),

            balloonView.trailingAnchor.constraint(equalTo: chargeButton.leadingAnchor,constant: -14),
            balloonView.centerYAnchor.constraint(equalTo: innerChargeContainerView.centerYAnchor),
            
            limitLabel.leadingAnchor.constraint(equalTo: limitContainerView.leadingAnchor),
            limitLabel.bottomAnchor.constraint(equalTo: limitContainerView.bottomAnchor),

            limitValueLabel.leadingAnchor.constraint(equalTo: limitLabel.trailingAnchor,constant: 5),
            limitValueLabel.bottomAnchor.constraint(equalTo: limitContainerView.bottomAnchor),
        ])
    }
}

