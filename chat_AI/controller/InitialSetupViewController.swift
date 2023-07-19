//
//  InitialSetupViewController.swift
//  chat_AI
//
//  Created by 조웅희 on 2023/04/20.
//

import UIKit

class InitialSetupViewController: UIViewController {
    let layerPadding: UIEdgeInsets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
    let mainLayerPadding: CGFloat = 20
    var labels = [UILabel]()
    var nameLabel = UILabel()
    let messages = ["성격부터 행동까지, \nAI를 직접 설정하세요.", "당신이 원하는\nAI를 만들어보세요.", "직접 만든 AI와의\n대화를 통해\n놀라운 일들을 경험해보세요."]
    var autoScrollTimer: Timer?
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.isPagingEnabled = true
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()
    
    private let pageControl = UIPageControl()
    private let numberOfPages = 4
    
    // 스크롤 뷰 설정
    private func setupScrollView() {
        scrollView.isPagingEnabled = true
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.delegate = self
        scrollView.backgroundColor = .green
        
        mainContainerView.addSubview(scrollView)
        
        NSLayoutConstraint.activate([
           scrollView.leadingAnchor.constraint(equalTo: mainContainerView.leadingAnchor),
           scrollView.trailingAnchor.constraint(equalTo: mainContainerView.trailingAnchor),
           scrollView.topAnchor.constraint(equalTo: mainContainerView.topAnchor),
           scrollView.bottomAnchor.constraint(equalTo: mainContainerView.bottomAnchor)
        ])
        
        mainContainerView.layoutIfNeeded()
        scrollView.layoutIfNeeded()
        
        for i in 0..<numberOfPages {
            let pageView = UIView(frame: CGRect(x: CGFloat(i) * mainContainerView.bounds.width, y: 0, width: mainContainerView.bounds.width, height: mainContainerView.bounds.height))
            pageView.backgroundColor = UIColor(hue: CGFloat(i) / CGFloat(numberOfPages), saturation: 0.8, brightness: 0.9, alpha: 1)
            scrollView.addSubview(pageView)
        }

        scrollView.contentSize = CGSize(width: mainContainerView.bounds.width * CGFloat(numberOfPages), height: mainContainerView.bounds.height)

    }

    // 페이지 컨트롤 설정
    private func setupPageControl() {
        pageControl.numberOfPages = numberOfPages
        pageControl.currentPage = 0
        pageControl.pageIndicatorTintColor = .lightGray
        pageControl.currentPageIndicatorTintColor = .black
        pageControl.translatesAutoresizingMaskIntoConstraints = false
        pageControl.isUserInteractionEnabled = false
        view.addSubview(pageControl)

        NSLayoutConstraint.activate([
            pageControl.bottomAnchor.constraint(equalTo: mainContainerView.bottomAnchor, constant: -16),
            pageControl.centerXAnchor.constraint(equalTo: mainContainerView.centerXAnchor)
        ])
    }
    
    // 전송 버튼 생성합니다.
    private let resultButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitleColor(UIColor.secondaryBackgroundColor, for: .normal)
        button.backgroundColor = .primaryBackgroundColor
        button.layer.cornerRadius = 5
        button.alpha = 0
        button.setTitle("시작하기", for: .normal)
        button.setTitleColor(.secondaryBackgroundColor, for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 20) // 폰트 사이즈를 20으로 변경
        button.translatesAutoresizingMaskIntoConstraints = false
        
        return button
    }()
    
    private let mainContainerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print(#function)
        setupUI()
        setupPageControl()

    }
    
    override func viewSafeAreaInsetsDidChange() {
        print(#function, "-START")
        setCAShapeLayer()
    }

    
    override func viewDidAppear(_ animated: Bool) {
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
    }
    
    // 자동 스크롤 메소드
    @objc func autoScroll() {
        print(#function)
        let nextPage: Int = Int(scrollView.contentOffset.x / mainContainerView.bounds.width) + 1
        if nextPage < numberOfPages {
            UIView.animate(withDuration: 0.3, animations: {
                self.scrollView.contentOffset = CGPoint(x: self.scrollView.bounds.width * CGFloat(nextPage), y: 0)
            }) { _ in
                self.scrollViewDidEndDecelerating(self.scrollView)
            }
        } else {
            autoScrollTimer?.invalidate()
        }
    }
    
    
    @objc func resultButtonTapped(_ sender: UIButton) {
        // 현재 뷰 컨트롤러에서 다음 뷰 컨트롤러를 모달로 표시합니다.
        print(#function)
        let settingsVC = OSSettingsViewController(isStartupView: true)

        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let sceneDelegate = windowScene.delegate as? SceneDelegate {
            completeInitialSetup()
            sceneDelegate.changeRootVC(settingsVC, animated: true)
        }
    }
    
    func completeInitialSetup() {
        print(#function, "- START")
        UserDefaults.standard.set(true, forKey: "initialSetupCompleted")
    }
    
    func setCAShapeLayer() {
        let safeArea = view.safeAreaLayoutGuide

        let paddedRect = CGRect(x: safeArea.layoutFrame.minX + layerPadding.left,
                                y: safeArea.layoutFrame.minY + layerPadding.top,
                                width: safeArea.layoutFrame.width - layerPadding.left - layerPadding.right,
                                height: safeArea.layoutFrame.height - layerPadding.top - layerPadding.bottom)

        let path = UIBezierPath(rect: paddedRect)

        let outerLayer = CAShapeLayer()
        outerLayer.path = path.cgPath
        outerLayer.strokeColor = UIColor.secondaryBackgroundColor.cgColor
        outerLayer.fillColor = UIColor.clear.cgColor
        outerLayer.lineWidth = 5.0 // 선의 두께 설정
        
        let innerLayer = CAShapeLayer()
        let innerLayerPaddedRect = CGRect(x: safeArea.layoutFrame.minX + layerPadding.left + mainLayerPadding - 10,
                                y: safeArea.layoutFrame.minY + layerPadding.top + mainLayerPadding - 10,
                                width: safeArea.layoutFrame.width - layerPadding.left - layerPadding.right - mainLayerPadding,
                                height: safeArea.layoutFrame.height - layerPadding.top - layerPadding.bottom - mainLayerPadding)

        let path2 = UIBezierPath(rect: innerLayerPaddedRect)
        innerLayer.path = path2.cgPath
        innerLayer.strokeColor = UIColor.secondaryBackgroundColor.cgColor
        innerLayer.fillColor = UIColor.clear.cgColor
        innerLayer.lineWidth = 5.0 // 선의 두께 설정
        
        let mainLayer = CAShapeLayer()
        let mainLayerPaddedRect = CGRect(x: safeArea.layoutFrame.minX + layerPadding.left + mainLayerPadding,
                                y: safeArea.layoutFrame.minY + layerPadding.top + mainLayerPadding,
                                width: safeArea.layoutFrame.width - layerPadding.left - layerPadding.right - mainLayerPadding * 2,
                                height: safeArea.layoutFrame.height - layerPadding.top - layerPadding.bottom - mainLayerPadding * 2)
        
        let path3 = UIBezierPath(rect: mainLayerPaddedRect)
        mainLayer.path = path3.cgPath
        mainLayer.strokeColor = UIColor.secondaryBackgroundColor.cgColor
        mainLayer.fillColor = UIColor.secondaryBackgroundColor.cgColor
        mainLayer.lineWidth = 5.0 // 선의 두께 설정

        // 그림자 효과 설정
        outerLayer.shadowColor = UIColor.black.cgColor
        outerLayer.shadowOpacity = 0.4 // 그림자의 투명도 설정 (0 ~ 1 사이의 값)
        outerLayer.shadowOffset = CGSize(width: 4, height: 4) // 그림자의 위치 오프셋 설정
        outerLayer.shadowRadius = 6 // 그림자의 흐림 정도 설정
        
        innerLayer.addSublayer(mainLayer)
        outerLayer.addSublayer(innerLayer)
        view.layer.insertSublayer(outerLayer,at: 0)
    }
    
    // UI초기화 메서드
    private func setupUI() {
        view.backgroundColor = .tertiaryBackgroundColor
        view.addSubview(mainContainerView)
        mainContainerView.addSubview(scrollView)
        resultButton.addTarget(self, action: #selector(resultButtonTapped(_:)), for: .touchUpInside)
        scrollView.delegate = self

        // 제약조건 활성화
        NSLayoutConstraint.activate([
            mainContainerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor,constant: view.safeAreaLayoutGuide.layoutFrame.minY + layerPadding.top + mainLayerPadding),
            mainContainerView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor,constant: -(view.safeAreaLayoutGuide.layoutFrame.minY + layerPadding.bottom + mainLayerPadding)),
            
            mainContainerView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor,constant: -(layerPadding.right + mainLayerPadding) ),
            mainContainerView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: layerPadding.left + mainLayerPadding),

            scrollView.leadingAnchor.constraint(equalTo: mainContainerView.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: mainContainerView.trailingAnchor),
            scrollView.topAnchor.constraint(equalTo: mainContainerView.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: mainContainerView.bottomAnchor)
        ])

        scrollView.layoutIfNeeded()

        for i in 0..<numberOfPages {
            let pageView = UIView()
            pageView.translatesAutoresizingMaskIntoConstraints = false
            pageView.backgroundColor = .clear
           
            // UILabel 추가
            if i == 0 {
                // 라벨 생성
                let label1 = UILabel()
                label1.textColor = .black
                label1.text = "Hello \n I'm"
                label1.textAlignment = .center
                label1.alpha = 0
                label1.numberOfLines = 0
                label1.font = UIFont.boldSystemFont(ofSize: 40) // 폰트 크기 변경
                
                nameLabel.textColor = .black
                nameLabel.text = "OS1 "
                nameLabel.textAlignment = .center
                nameLabel.alpha = 0
                nameLabel.font = UIFont(name: "OoohBaby-Regular", size: 70)


                // 스택뷰 생성
                let stackView = UIStackView(arrangedSubviews: [label1, nameLabel])
                stackView.axis = .vertical
                stackView.distribution = .fill
                stackView.spacing = 10
                stackView.translatesAutoresizingMaskIntoConstraints = false
                labels.append(label1)
                pageView.addSubview(stackView)
                stackView.centerXAnchor.constraint(equalTo: pageView.centerXAnchor).isActive = true
                stackView.centerYAnchor.constraint(equalTo: pageView.centerYAnchor,constant: -60).isActive = true
            } else {
                let label = UILabel()
                label.translatesAutoresizingMaskIntoConstraints = false
                label.text = messages[i - 1]
                label.font = UIFont.boldSystemFont(ofSize: 26) // 폰트 크기 변경
                label.textColor = .black
                label.textAlignment = .center
                label.alpha = 0 // 처음에 레이블이 보이지 않게 설정
                label.numberOfLines = 0
                labels.append(label)
                
                if i == numberOfPages - 1{
                    print("이것은 마지막 반복입니다.")
                    // 여기에 마지막 반복일 때 수행할 작업을 넣을 수 있습니다.
                    let buttonContainer = UIView()
                    buttonContainer.addSubview(resultButton)

                    // 버튼의 크기와 위치 설정
                    NSLayoutConstraint.activate([
                        resultButton.centerXAnchor.constraint(equalTo: buttonContainer.centerXAnchor),
                        resultButton.centerYAnchor.constraint(equalTo: buttonContainer.centerYAnchor),
                        resultButton.widthAnchor.constraint(equalToConstant: 100),  // 버튼의 넓이
                        resultButton.heightAnchor.constraint(equalToConstant: 50)   // 버튼의 높이
                    ])
                    
                    // 스택뷰 생성
                    let stackView = UIStackView(arrangedSubviews: [label, buttonContainer])
                    stackView.axis = .vertical
                    stackView.distribution = .fillEqually
                    stackView.spacing = 10
                    stackView.translatesAutoresizingMaskIntoConstraints = false
                                        
                    pageView.addSubview(stackView)
                    stackView.centerXAnchor.constraint(equalTo: pageView.centerXAnchor).isActive = true
                    stackView.centerYAnchor.constraint(equalTo: pageView.centerYAnchor,constant: -30).isActive = true
                    
                } else {
                    pageView.addSubview(label)
                    label.centerXAnchor.constraint(equalTo: pageView.centerXAnchor).isActive = true
                    label.centerYAnchor.constraint(equalTo: pageView.centerYAnchor,constant: -60).isActive = true
                }
            }

            scrollView.addSubview(pageView)
           
            NSLayoutConstraint.activate([
               pageView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: scrollView.bounds.width * CGFloat(i)),
               pageView.topAnchor.constraint(equalTo: mainContainerView.topAnchor),
               pageView.bottomAnchor.constraint(equalTo: mainContainerView.bottomAnchor),
               pageView.widthAnchor.constraint(equalTo: mainContainerView.widthAnchor),
            ])

        }

        scrollView.layoutIfNeeded()

        scrollView.contentSize = CGSize(width: (scrollView.subviews.first?.bounds.width)! * CGFloat(numberOfPages), height: mainContainerView.bounds.height)
    }

}

extension InitialSetupViewController: UIScrollViewDelegate  {
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
       let page = Int(scrollView.contentOffset.x / scrollView.bounds.width)
       pageControl.currentPage = page
        
        guard page < 4, labels[page].alpha != 1.0 else { return }
        print(#function)
        // 라벨을 서서히 나타냄
        UIView.animate(withDuration: 2.0, animations: {
            self.labels[page].alpha = 1.0
        }, completion: { _ in
            if page == self.numberOfPages - 1 {
                UIView.animate(withDuration: 1, animations: {
                    self.resultButton.alpha = 1.0
                })
            }
        })
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        // 사용자가 스크롤시 자동 스크롤을 종료함
        autoScrollTimer?.invalidate()
        autoScrollTimer = nil
    }
}

