//
//  InitialSetupViewController.swift
//  chat_AI
//
//  Created by 조웅희 on 2023/04/20.
//

import UIKit

/// 초기 소개 페이지
class InitialSetupViewController: UIViewController {
    // MARK: - Properties and Constants
    private let layerPadding: UIEdgeInsets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10) // 4각 값이 같아서 굳이 방향별로 값을 적을 필요는없지만 가독성이좋은 느낌이랄까
    private var labels = [UILabel]()
    private let messages = ["성격부터 행동까지, \nAI를 직접 설정하세요.", "당신이 원하는\nAI를 만들어보세요.", "직접 만든 AI와의\n대화를 통해\n놀라운 일들을 경험해보세요."]
    private var autoScrollTimer: Timer?
    private let numberOfPages = 4

    // MARK: - UI Components
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.text = "OS1 "
        label.textAlignment = .center
        label.alpha = 0
        label.font = UIFont(name: "OoohBaby-Regular", size: 70)
        return label
    }()
    
    private let horizontalStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .fill
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private let pageControl: UIPageControl = {
        let pageControl = UIPageControl()
        pageControl.currentPage = 0
        pageControl.pageIndicatorTintColor = .lightGray
        pageControl.currentPageIndicatorTintColor = .black
        pageControl.translatesAutoresizingMaskIntoConstraints = false
        pageControl.isUserInteractionEnabled = false
        return pageControl
    }()
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.isPagingEnabled = true
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()
        
    private let startButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitleColor(UIColor.secondaryBackgroundColor, for: .normal)
        button.backgroundColor = .primaryBackgroundColor
        button.layer.cornerRadius = 5
        button.alpha = 0
        button.setTitle("시작하기", for: .normal)
        button.setTitleColor(.secondaryBackgroundColor, for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 20)
        button.translatesAutoresizingMaskIntoConstraints = false
        
        return button
    }()
    
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        debugPrint_START()
        
        super.viewDidLoad()
        setupUI()
        
        debugPrint_END()
    }
    
    /// Safe Area 여백이 변경되었을 때 호출되는 메서드
    override func viewSafeAreaInsetsDidChange() {
        debugPrint_START()
        
        // 배경 테두리 그리기
        let safeArea = view.safeAreaLayoutGuide

        let outerRect = CGRect(x: safeArea.layoutFrame.minX + layerPadding.left, // + 10
                            y: safeArea.layoutFrame.minY + layerPadding.top,
                            width: safeArea.layoutFrame.width - layerPadding.left - layerPadding.right, // -20
                            height: safeArea.layoutFrame.height - layerPadding.top - layerPadding.bottom) // -20

        let innerRect = CGRect(x: safeArea.layoutFrame.minX + layerPadding.left * 2, // + 20
                            y: safeArea.layoutFrame.minY + layerPadding.top * 2,
                        width: safeArea.layoutFrame.width - (layerPadding.left * 2) - (layerPadding.right * 2), // - 40
                            height: safeArea.layoutFrame.height - (layerPadding.top * 2) - (layerPadding.bottom * 2))

        let mainRect = CGRect(x: safeArea.layoutFrame.minX + layerPadding.left * 3, // + 30
                            y: safeArea.layoutFrame.minY + layerPadding.top * 3,
                            width: safeArea.layoutFrame.width - (layerPadding.left * 3) - (layerPadding.right * 3), // -60
                            height: safeArea.layoutFrame.height - (layerPadding.top * 3) - (layerPadding.bottom * 3))

        let outerLayer = makeLayerWith(rect: outerRect, fillColor: UIColor.clear, strokeColor: UIColor.secondaryBackgroundColor, isShadow: true)
        let innerLayer = makeLayerWith(rect: innerRect, fillColor: UIColor.clear, strokeColor: UIColor.secondaryBackgroundColor)
        let mainLayer = makeLayerWith(rect: mainRect, fillColor: UIColor.secondaryBackgroundColor, strokeColor: UIColor.secondaryBackgroundColor)

        innerLayer.addSublayer(mainLayer)
        outerLayer.addSublayer(innerLayer)
        
        // addSublayer(_:)는 레이어를 맨 위에 추가.
        // insertSublayer(_:at:)는 지정된 위치에 레이어를 추가. (at: 0 = 맨 밑에 넣겠다는 뜻 )
        view.layer.insertSublayer(outerLayer, at: 0)
        
        debugPrint_END()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        debugPrint_START()
        
        super.viewDidAppear(animated)
        // 첫 번째 라벨을 서서히 나타냄
        // 라벨을 서서히 나타냄
        UIView.animate(withDuration: 2.0, animations: {
            self.labels[0].alpha = 1.0
        }, completion: { _ in
            UIView.animate(withDuration: 3.0, animations: {
                self.nameLabel.alpha = 1.0
            }, completion: { _ in
                
            })
            self.autoScrollTimer = Timer.scheduledTimer(timeInterval: 3.5, target: self, selector: #selector(self.autoScroll), userInfo: nil, repeats: true)
            
        })
        
        debugPrint_END()
    }
    
    // MARK: - Action Methods
    
    /// 자동 스크롤 함수
    @objc func autoScroll() {
        debugPrint_START()
        
        let nextPage: Int = Int(scrollView.contentOffset.x / scrollView.bounds.width) + 1
        if nextPage < numberOfPages {
            UIView.animate(withDuration: 0.3, animations: {
                self.scrollView.contentOffset = CGPoint(x: self.scrollView.bounds.width * CGFloat(nextPage), y: 0)
            }) { _ in
                self.scrollViewDidEndDecelerating(self.scrollView)
            }
        } else {
            autoScrollTimer?.invalidate()
        }
        
        debugPrint_END()
    }
    
    
    /// 시작버튼 터치 함수
    /// - Parameter sender: UIButton
    @objc func startButtonTapped(_ sender: UIButton) {
        debugPrint_START()
        
        // 현재 뷰 컨트롤러에서 다음 뷰 컨트롤러를 모달로 표시합니다.
        let settingsVC = OSSettingsViewController(isStartupView: true)

        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let sceneDelegate = windowScene.delegate as? SceneDelegate {
            // 초기셋팅이 끝으로 다음부터는 초기소개화면이 안나오도록 true값을 줌
            UserDefaults.standard.set(true, forKey: "initialSetupCompleted")
            sceneDelegate.changeRootVC(settingsVC, animated: true)
        }
        
        debugPrint_END()
    }
        
    // MARK: - Interface Setup
    
    
    /// UI초기화 메서드
    private func setupUI() {
        debugPrint_START()
        
        pageControl.numberOfPages = self.numberOfPages
        
        startButton.addTarget(self, action: #selector(startButtonTapped(_:)), for: .touchUpInside)
        
        scrollView.delegate = self
        
        scrollView.addSubview(horizontalStackView)
        view.backgroundColor = .tertiaryBackgroundColor
        view.addSubview(scrollView)
        view.addSubview(pageControl)
        

        // 제약조건 활성화
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor,constant: view.safeAreaLayoutGuide.layoutFrame.minY + (layerPadding.top * 3)),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor,constant: -(view.safeAreaLayoutGuide.layoutFrame.minY + (layerPadding.bottom * 3))),
            scrollView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor,constant: -(layerPadding.right * 3)),
            scrollView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: layerPadding.left * 3),

            pageControl.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -16),
            pageControl.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor),
        
            horizontalStackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            horizontalStackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            horizontalStackView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            horizontalStackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor)
        ])

        // 각 페이지 뷰 생성
        for i in 0..<numberOfPages {
            let pageView = createPageView(forPage: i)

            horizontalStackView.addArrangedSubview(pageView)
            
            NSLayoutConstraint.activate([
                pageView.topAnchor.constraint(equalTo: horizontalStackView.topAnchor),
                pageView.bottomAnchor.constraint(equalTo: horizontalStackView.bottomAnchor),
                pageView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
                pageView.heightAnchor.constraint(equalTo: scrollView.heightAnchor),
            ])
        }
        
        debugPrint_END()
    }
        
    /// 페이지 생성
    /// - Parameter page: 페이지 번호
    /// - Returns: 페이지뷰
    func createPageView(forPage page: Int) -> UIView {
        debugPrint_START()
        
        let pageView = UIView()
        pageView.translatesAutoresizingMaskIntoConstraints = false
        pageView.backgroundColor = .clear

        let label = UILabel()
        label.textColor = .black
        label.textAlignment = .center
        label.alpha = 0 // 처음에 레이블이 보이지 않게 설정
        label.numberOfLines = 0

        var contentItem: UIView? = nil
        
        if page == 0 {
            // 첫 페이지
            label.text = "Hello \n I'm"
            label.font = UIFont.boldSystemFont(ofSize: 40) // 폰트 크기 변경
            contentItem = nameLabel
            
        } else {
            // 나머지 페이지
            label.text = messages[page - 1]
            label.font = UIFont.boldSystemFont(ofSize: 26) // 폰트 크기 변경
            
            // 마지막 페이지
            if page == numberOfPages - 1 {
                contentItem = startButton
                // 스택뷰는 내부적으로 오토레이아웃으로 뷰를 배치하기에 직접 프레임을 설정한 버튼의 크기가 적용이 안될 수 있어 버튼 크기를 오토레이아웃으로 설정함
                startButton.widthAnchor.constraint(equalToConstant: 100).isActive = true  // 버튼의 넓이
                startButton.heightAnchor.constraint(equalToConstant: 50).isActive = true   // 버튼의 높이
            } else {
                label.translatesAutoresizingMaskIntoConstraints = false
                pageView.addSubview(label)
                label.centerXAnchor.constraint(equalTo: pageView.centerXAnchor).isActive = true
                label.centerYAnchor.constraint(equalTo: pageView.centerYAnchor,constant: -60).isActive = true
            }
        }
        
        // 첫 페이지 또는 마지막 페이지
        if let item = contentItem {
            let stackView = UIStackView(arrangedSubviews: [label, item])
            stackView.axis = .vertical
            stackView.alignment = .center
            stackView.spacing = 10
            stackView.translatesAutoresizingMaskIntoConstraints = false
            pageView.addSubview(stackView)
            stackView.centerXAnchor.constraint(equalTo: pageView.centerXAnchor).isActive = true
            stackView.centerYAnchor.constraint(equalTo: pageView.centerYAnchor,constant: page == 0 ? -60 : -30).isActive = true
        }

        labels.append(label)
        
        debugPrint_END()
        return pageView
    }
    
    
    /// 배경 테두리 만들기
    /// - Parameters:
    ///   - rect: 사각형 모양
    ///   - fillColor: 채우기 색깔
    ///   - strokeColor: 선 색깔
    ///   - isShadow: 그림자 유무
    /// - Returns: 테두리
    func makeLayerWith(rect: CGRect, fillColor: UIColor, strokeColor: UIColor, isShadow: Bool = false) -> CAShapeLayer {
        let path = UIBezierPath(rect: rect)
        let layer = CAShapeLayer()
        layer.path = path.cgPath
        layer.strokeColor = strokeColor.cgColor
        layer.fillColor = fillColor.cgColor
        layer.lineWidth = 5.0
        
        if isShadow {
            layer.shadowColor = UIColor.black.cgColor
            layer.shadowOpacity = 0.4
            layer.shadowOffset = CGSize(width: 4, height: 4)
            layer.shadowRadius = 6
        }
        
        return layer
    }
}

// MARK: - Extensions

extension InitialSetupViewController: UIScrollViewDelegate  {
    
    /// 스크롤 제스처가 끝났을때
    /// - Parameter scrollView: UIScrollView
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        debugPrint_START()
        
        let page = Int(scrollView.contentOffset.x / scrollView.bounds.width)
        pageControl.currentPage = page
        
        guard page < 4, labels[page].alpha != 1.0 else { return debugPrint_END() }
        // 라벨을 서서히 나타냄
        UIView.animate(withDuration: 2.0, animations: {
            self.labels[page].alpha = 1.0
        }, completion: { _ in
            if page == self.numberOfPages - 1 {
                UIView.animate(withDuration: 1, animations: {
                    self.startButton.alpha = 1.0
                })
            }
        })
        
        debugPrint_END()
    }
    
    /// 스크롤 제스처를 시작할때
    /// - Parameter scrollView: UIScrollView
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        debugPrint_START()
        
        // 사용자가 스크롤시 자동 스크롤을 종료함
        autoScrollTimer?.invalidate()
        autoScrollTimer = nil
        
        debugPrint_END()
    }
}

