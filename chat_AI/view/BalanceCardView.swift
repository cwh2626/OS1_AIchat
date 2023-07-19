//
//  BalanceCardCell.swift
//  chat_AI
//
//  Created by 조웅희 on 2023/06/14.
//

import UIKit
import RxSwift
import RxCocoa

class BalanceCardView: UIView {
    weak var delegate: BalanceCardViewDelegate?
    
    let tokenLabel: UILabel = {
        let label = UILabel()
        label.textColor = .secondaryBackgroundColor
        label.font = UIFont.systemFont(ofSize: 32) // 시스템 기본 폰트의 크기를 20으로 설정
        label.adjustsFontSizeToFitWidth = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let balanceLabel: UILabel = {
        let label = UILabel()
        label.textColor = .secondaryBackgroundColor.withAlphaComponent(0.8)
        label.text = "보유 토큰"
        label.font = UIFont.systemFont(ofSize: 14) // 시스템 기본 폰트의 크기를 20으로 설정
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let chargeContainerView: UIView = {
        let view = UIView()
        return view
        
    }()
    
    let innerChargeContainerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
        
    }()
    
    let limitContainerView: UIView = {
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
    
    let limitLabel: UILabel = {
        let label = UILabel()
        label.textColor = .secondaryBackgroundColor
        label.font = UIFont.systemFont(ofSize: 18) // 시스템 기본 폰트의 크기를 20으로 설정
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
    
    init() {
        super.init(frame: .zero)
        self.layer.cornerRadius = 10
        self.backgroundColor = .primaryBackgroundColor
        
        let separatorView = UIView()
        separatorView.backgroundColor = .secondaryBackgroundColor.withAlphaComponent(0.3)
        separatorView.heightAnchor.constraint(equalToConstant: 0.5).isActive = true  // 선의 두께를 결정

        limitContainerView.addSubview(limitLabel)
        limitContainerView.addSubview(limitValueLabel)
        // 스크린샷용
        // 광고 활성화전
        let stackView = UIStackView(arrangedSubviews: [balanceLabel, tokenLabel, chargeContainerView, separatorView, limitContainerView, limitProgressBar])
//        let stackView = UIStackView(arrangedSubviews: [balanceLabel, tokenLabel,  separatorView, limitContainerView, limitProgressBar])
        stackView.axis = .vertical
        stackView.distribution = .fill
        stackView.alignment = .fill
        stackView.spacing = 10
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.backgroundColor = .clear
         
        let balloonView = BalloonView(frame: CGRect(x: 0, y: 0, width: 85, height: 30))
        balloonView.message = "4K 무료충전!"

        innerChargeContainerView.addSubview(chargeButton)
        innerChargeContainerView.addSubview(balloonView)
        chargeContainerView.addSubview(innerChargeContainerView)
        
//        chargeButton.layer.add(shakeAnimation, forKey: "buttonShakeAnimation")
        
        addSubview(stackView)
        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: self.topAnchor, constant: 10),
            stackView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 10),
            stackView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -10),
            stackView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -10),
            // 스크린샷용
            stackView.heightAnchor.constraint(equalToConstant: 160),
//            stackView.heightAnchor.constraint(equalToConstant: 130),
            
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
        
//        let floatingAnimation = CABasicAnimation(keyPath: "transform.translation.y")
//        floatingAnimation.duration = 1.0
//        floatingAnimation.repeatCount = Float.infinity  // 무한 반복
//        floatingAnimation.autoreverses = true  // 애니메이션 뒤로 재생
//        floatingAnimation.fromValue = 0  // 시작 위치
//        floatingAnimation.toValue = -5  // 종료 위치 (위로 10포인트)
//
//        // 애니메이션 추가
//        chargeButton.layer.add(floatingAnimation, forKey: "buttonFloatingAnimation")
        
        chargeButton.addTarget(self, action: #selector(didTapChargeButton), for: .touchUpInside)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func didTapChargeButton() {
        
        // 버튼이 눌렸을 때 실행할 코드를 여기에 작성합니다.
        delegate?.adButtonDidTap()
    }
    
}

protocol BalanceCardViewDelegate: AnyObject {
    func adButtonDidTap()
}
