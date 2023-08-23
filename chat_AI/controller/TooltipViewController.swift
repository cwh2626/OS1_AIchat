//
//  TooltipViewController.swift
//  chat_AI
//
//  Created by 조웅희 on 2023/05/23.
//

import UIKit

class TooltipViewController: UIViewController {
    private let message: String
    private let padding: CGFloat = 10.0
    private var label = UILabel()
    private var scrollView = UIScrollView()
    
    
    init(message: String) {
        self.message = message
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .popover
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        layoutViews()
    }
    
    private func setupViews() {
        
        label.textColor = .black
        let attributedText = NSMutableAttributedString(string: message)
        attributedText.addAttribute(.foregroundColor, value: UIColor.primaryBackgroundColor, range: (message as NSString).range(of: "+"))
        attributedText.addAttribute(.font, value: UIFont.boldSystemFont(ofSize: 20), range: (message as NSString).range(of: "+"))

        label.attributedText = attributedText
        
        label.textAlignment = .center
        label.numberOfLines = 0

        label.translatesAutoresizingMaskIntoConstraints = false
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(label)

        view.backgroundColor = UIColor.secondaryBackgroundColor
        view.addSubview(scrollView)
    }
    
    private func layoutViews() {
        NSLayoutConstraint.activate([
            scrollView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor,constant: padding),
            scrollView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor,constant: -padding),
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor,constant: padding),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor,constant: -padding),

            label.leadingAnchor.constraint(equalTo: scrollView.safeAreaLayoutGuide.leadingAnchor),
            label.trailingAnchor.constraint(equalTo: scrollView.safeAreaLayoutGuide.trailingAnchor),
            label.topAnchor.constraint(equalTo: scrollView.safeAreaLayoutGuide.topAnchor),
            label.bottomAnchor.constraint(equalTo: scrollView.safeAreaLayoutGuide.bottomAnchor),

        ])
        
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        // 툴팁 뷰의 preferredContentSize 업데이트
        // targetSize의 UIView.layoutFittingCompressedSize.height은 상수로 높이를 최소한으로 압축될수 있는 크기를 의미한다 그럼
        // 이걸 label.systemLayoutSizeFitting에 넣게되면 넓이는 TooltipViewController의 bouds사이즈 그리고 높이는 라벨의 콘텐츠에 맞게 높이를 최소한으로 압축한 사이즈를 반환하게 되는것이다.
        let targetSize = CGSize(width: view.bounds.width, height: UIView.layoutFittingCompressedSize.height)
        let fittingSize = label.systemLayoutSizeFitting(targetSize, withHorizontalFittingPriority: .required, verticalFittingPriority: .fittingSizeLevel)
        let adjustedSize = CGSize(width: fittingSize.width, height: fittingSize.height + padding * 2)
        preferredContentSize = adjustedSize
    }
}
