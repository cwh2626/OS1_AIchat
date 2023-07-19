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

protocol CustomAlertDelegate {
    func handleConfirmAction()
    func handleCancelAction()
}

class CustomAlertViewController: UIViewController {    
    var alertText: String
    var alertType: AlertType
    var delegate: CustomAlertDelegate?
    
    init(
        alertText: String,
        alertType: AlertType,
        delegate: CustomAlertDelegate
    ) {
        self.alertText = alertText
        self.alertType = alertType
        self.delegate = delegate

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

    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        
    }
    
    // MARK: - UI컴포넌트 정의
    let alertView: UIView = {
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
    
    let alertTopView: UIView = {
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
    
    let titleImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "warning")?.withRenderingMode(.alwaysTemplate))
        imageView.tintColor = UIColor.secondaryBackgroundColor
        imageView.translatesAutoresizingMaskIntoConstraints = false

        return imageView
    }()
    
    let textLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.secondaryBackgroundColor
        label.font = UIFont.boldSystemFont(ofSize: 14)
        label.textAlignment = .center // 텍스트 중앙 정렬
        label.numberOfLines = 0 // 여러 줄 텍스트 허용
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let cancelButton: UIButton = {
        let button = UIButton()
        button.setTitleColor(.white, for: .normal) // 텍스트 색상 설정
        button.setImage(UIImage(named: "close")?.withRenderingMode(.alwaysTemplate), for: .normal)
        button.tintColor = UIColor.secondaryBackgroundColor
        return button
    }()
    
    let confirmButton: UIButton = {
        let button = UIButton()
        button.setTitleColor(.white, for: .normal) // 텍스트 색상 설정
        button.setImage(UIImage(named: "check")?.withRenderingMode(.alwaysTemplate), for: .normal)
        button.tintColor = UIColor.secondaryBackgroundColor
        return button
    }()
    
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
       
        /* 탑뷰 하단 줄긋기 처리 (필요에 따라 활성유무)
        let borderLayer = CALayer()
        let borderHeight: CGFloat = 3.0  // 테두리 높이
        borderLayer.frame = CGRect(x: 0, y: alertTopView.bounds.height - borderHeight, width: alertTopView.bounds.width, height: borderHeight)
        borderLayer.backgroundColor = UIColor.black.cgColor  // 테두리 색상 설정
        alertTopView.layer.addSublayer(borderLayer)
        */

        
        /* 그래버는 추후에 상단 뷰가 만들어지면 하는걸로
        let grabberView = GrabberView(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
        grabberView.translatesAutoresizingMaskIntoConstraints = false
//        alertView.addSubview(grabberView)
        alertView.layoutIfNeeded()
        let grabberLayer = CALayer()
        grabberLayer.frame = CGRect(x: 0, y: alertView.bounds.height - 6, width: alertView.bounds.width, height: 6)
        grabberLayer.cornerRadius = 3
            grabberLayer.backgroundColor = UIColor.white.cgColor
        alertView.layer.addSublayer(grabberLayer)
        
//        grabberView.centerXAnchor.constraint(equalTo: alertView.centerXAnchor).isActive = true
         */
    }
    
    // MARK: - 액션 메소드 정의
    @objc func confirmButtonTapped() {
        self.dismiss(animated: true) {
            self.delegate?.handleConfirmAction()
        }
        
    }
    
    @objc func cancelButtonTapped() {
        self.dismiss(animated: true) {
            self.delegate?.handleCancelAction()
        }
        
    }
    
    // 이 함수는 UIPanGestureRecognizer의 동작을 처리합니다. 사용자가 뷰를 드래그하는 동작을 제어하고 관리합니다.
    @objc func handleDismiss(_ gesture: UIPanGestureRecognizer) {
        // 사용자가 뷰를 얼마나 드래그했는지를 나타내는 값입니다.
        let translation = gesture.translation(in: alertView)
        
        // 제스쳐의 상태에 따라 다른 동작을 수행합니다.
        switch gesture.state {
        case .changed:
            // 사용자가 뷰를 드래그하는 동안, 뷰의 위치를 조절합니다.
            // 뷰는 아래쪽으로만 드래그될 수 있습니다.
            if translation.y >= 0 {
                alertView.transform = CGAffineTransform(translationX: 0, y: translation.y)
            }
        case .ended:
            // 사용자가 뷰를 드래그하고 손을 뗐을 때, 뷰의 최종 위치에 따라 다른 동작을 수행합니다.
            // 사용자가 뷰를 충분히 아래쪽으로 드래그했다면, 알림을 닫습니다.
            if translation.y > 110 {  // 이 값은 당신의 필요에 따라 조정할 수 있습니다.
                confirmButtonTapped()
            } else {
                // 사용자가 뷰를 충분히 아래쪽으로 드래그하지 않았다면, 뷰의 위치를 원래대로 되돌립니다.
                UIView.animate(withDuration: 0.3) {
                    self.alertView.transform = CGAffineTransform(translationX: 0, y: 0)
                }
            }
        default:
            // 기타 상황에서는 아무런 동작도 수행하지 않습니다.
            break
        }
    }

}
