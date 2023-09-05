//
//  CustomAlertViewController.swift
//  chat_AI
//
//  Created by 조웅희 on 2023/05/25.
//

import UIKit

enum AlertType {
    case onlyConfirm    // 확인 버튼
    case canCancel      // 확인 + 취소 버튼
}

/// 커스텀 얼러터 뷰컨트롤
class CustomAlertViewController: UIViewController {
    // MARK: - Properties
    private var alertText: String
    private var alertType: AlertType
    private var onConfirmAction: (() -> Void)?
    private var onCancelAction: (() -> Void)?
    
    // MARK: - UI Components
    private let alertView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.tertiaryBackgroundColor
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 10
        view.layer.shadowColor = UIColor.black.cgColor  // 그림자 색상
        view.layer.shadowOffset = CGSize(width: 0, height: 1.0)  // 그림자의 오프셋 (너비, 높이)
        view.layer.shadowOpacity = 0.2  // 그림자의 투명도 (0.0 ~ 1.0)
        view.layer.shadowRadius = 4.0  // 그림자의 퍼짐 정도
        return view
    }()
    
    private let alertTopView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .clear
        view.layer.cornerRadius = 10
        
        if #available(iOS 11.0, *) {
            // Top left corner, Top right corner
            view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        }
        return view
    }()
    
    private let titleImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "warning")?.withRenderingMode(.alwaysTemplate))
        imageView.tintColor = UIColor.secondaryBackgroundColor
        imageView.translatesAutoresizingMaskIntoConstraints = false

        return imageView
    }()
    
    private let textLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.secondaryBackgroundColor
        label.font = UIFont.boldSystemFont(ofSize: 14)
        label.textAlignment = .center // 텍스트 중앙 정렬
        label.numberOfLines = 0 // 여러 줄 텍스트 허용
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let cancelButton: UIButton = {
        let button = UIButton()
        button.setTitleColor(.white, for: .normal) // 텍스트 색상 설정
        button.setImage(UIImage(named: "close")?.withRenderingMode(.alwaysTemplate), for: .normal)
        button.tintColor = UIColor.secondaryBackgroundColor
        return button
    }()
    
    private let confirmButton: UIButton = {
        let button = UIButton()
        button.setTitleColor(.white, for: .normal) // 텍스트 색상 설정
        button.setImage(UIImage(named: "check")?.withRenderingMode(.alwaysTemplate), for: .normal)
        button.tintColor = UIColor.secondaryBackgroundColor
        return button
    }()
    
    // MARK: - Initializer
    init(alertText: String, alertType: AlertType, onConfirmAction: (() -> Void)? = nil, onCancelAction: (() -> Void)? = nil) {
        self.alertText = alertText
        self.alertType = alertType
        self.onConfirmAction = onConfirmAction
        self.onCancelAction = onCancelAction

        super.init(nibName: nil, bundle: nil)
        
        modalPresentationStyle = .overFullScreen
        if alertType == .canCancel {
            modalTransitionStyle = .crossDissolve
        } else if alertType == .onlyConfirm {
            modalTransitionStyle = .coverVertical
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        
    }
    
    // MARK: - Interface Setup
    // UI초기화 메서드
    private func setupViews() {
        alertView.addSubview(textLabel)
        alertView.addSubview(alertTopView)
        alertTopView.addSubview(titleImageView)
        view.addSubview(alertView)
        textLabel.text = alertText
                
        NSLayoutConstraint.activate([
            alertTopView.topAnchor.constraint(equalTo: alertView.safeAreaLayoutGuide.topAnchor),
            alertTopView.leadingAnchor.constraint(equalTo: alertView.leadingAnchor),
            alertTopView.trailingAnchor.constraint(equalTo: alertView.trailingAnchor),
            alertTopView.widthAnchor.constraint(equalTo: alertView.widthAnchor),

            titleImageView.widthAnchor.constraint(equalToConstant: 45),
            titleImageView.heightAnchor.constraint(equalToConstant: 45),
            titleImageView.centerXAnchor.constraint(equalTo: alertTopView.centerXAnchor),
            titleImageView.bottomAnchor.constraint(equalTo: alertTopView.bottomAnchor, constant: -10),
            
            alertView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            alertView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            alertView.widthAnchor.constraint(equalToConstant: 280),
            
            textLabel.topAnchor.constraint(equalTo: alertTopView.bottomAnchor, constant: 5),
            textLabel.leadingAnchor.constraint(equalTo: alertView.leadingAnchor, constant: 20),
            textLabel.trailingAnchor.constraint(equalTo: alertView.trailingAnchor, constant: -20),
            
        ])
        
        if alertType == .canCancel {
            alertView.addSubview(confirmButton)
            alertView.addSubview(cancelButton)
            
            alertView.heightAnchor.constraint(equalToConstant: 180).isActive = true
            alertTopView.heightAnchor.constraint(equalToConstant: 60).isActive = true
            
            confirmButton.translatesAutoresizingMaskIntoConstraints = false
            confirmButton.bottomAnchor.constraint(equalTo: alertView.bottomAnchor, constant: -20).isActive = true
            confirmButton.trailingAnchor.constraint(equalTo: alertView.trailingAnchor, constant: -55).isActive = true
            confirmButton.widthAnchor.constraint(equalToConstant: 30).isActive = true
            confirmButton.heightAnchor.constraint(equalToConstant: 30).isActive = true
            confirmButton.addTarget(self, action: #selector(confirmButtonTapped), for: .touchUpInside)
            
            cancelButton.translatesAutoresizingMaskIntoConstraints = false
            cancelButton.bottomAnchor.constraint(equalTo: alertView.bottomAnchor, constant: -20).isActive = true
            cancelButton.leadingAnchor.constraint(equalTo: alertView.leadingAnchor, constant: 55).isActive = true
            cancelButton.widthAnchor.constraint(equalToConstant: 30).isActive = true
            cancelButton.heightAnchor.constraint(equalToConstant: 30).isActive = true
            cancelButton.addTarget(self, action: #selector(cancelButtonTapped), for: .touchUpInside)
        } else if alertType == .onlyConfirm {
            textLabel.bottomAnchor.constraint(equalTo: alertView.bottomAnchor, constant: -15).isActive = true
            alertView.heightAnchor.constraint(equalToConstant: 162).isActive = true
            alertTopView.heightAnchor.constraint(equalToConstant: 72).isActive = true
            alertView.layoutIfNeeded()
            
            let grabberLayer: CALayer = {
                let layer = CALayer()
                layer.frame = CGRect(x: (alertView.bounds.width / 2) - 15, y: 6, width: 30, height: 6)
                layer.cornerRadius = 3
                layer.backgroundColor = UIColor.secondaryBackgroundColor.cgColor
                return layer
            }()
            
            alertView.layer.addSublayer(grabberLayer)
            
            let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handleDismiss(_:)))
            alertView.addGestureRecognizer(panGestureRecognizer)
        }
    }
    
    // MARK: - Action Methods
    @objc func confirmButtonTapped() {
        self.dismiss(animated: true) {
            self.onConfirmAction?()
        }
    }
    
    @objc func cancelButtonTapped() {
        self.dismiss(animated: true) {
            self.onCancelAction?()
        }
    }
    
    // 사용자가 뷰를 드래그하는 동작제어
    @objc func handleDismiss(_ gesture: UIPanGestureRecognizer) {
        // 사용자가 뷰를 얼마나 드래그했는지를 나타내는 값
        let translation = gesture.translation(in: alertView)
        
        // 제스쳐의 상태에 따라 다른 동작 수행
        switch gesture.state {
        case .changed:
            // 사용자가 뷰를 드래그하는 동안, 뷰의 위치 조절
            // 뷰는 아래쪽으로만 드래그 가능
            if translation.y >= 0 {
                alertView.transform = CGAffineTransform(translationX: 0, y: translation.y)
            }
        case .ended:
            // 사용자가 뷰를 드래그하고 손을 뗐을 때, 뷰의 최종 위치에 따라 다른 동작 수행
            // 사용자가 뷰를 충분히 아래쪽으로 드래그했다면, 알림을 닫음
            if translation.y > 110 {
                confirmButtonTapped()
            } else {
                // 사용자가 뷰를 충분히 아래쪽으로 드래그하지 않았다면, 뷰의 위치를 원래대로 되돌림
                UIView.animate(withDuration: 0.3) {
                    self.alertView.transform = CGAffineTransform(translationX: 0, y: 0)
                }
            }
        default:
            break
        }
    }
}
