//
//  UIHelper.swift
//  chat_AI
//
//  Created by 조웅희 on 2023/07/21.
//

import UIKit

class UIHelper {
    static func createScrollView() -> UIScrollView {
        let scrollView = UIScrollView()
        scrollView.isPagingEnabled = true
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }

    static func createPageControl(numberOfPages: Int) -> UIPageControl {
        let pageControl = UIPageControl()
        pageControl.numberOfPages = numberOfPages
        pageControl.currentPage = 0
        pageControl.pageIndicatorTintColor = .lightGray
        pageControl.currentPageIndicatorTintColor = .black
        pageControl.translatesAutoresizingMaskIntoConstraints = false
        pageControl.isUserInteractionEnabled = false
        return pageControl
    }

    static func createButton(title: String, width: CGFloat, height: CGFloat) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitleColor(UIColor.secondaryBackgroundColor, for: .normal)
        button.backgroundColor = .primaryBackgroundColor
        button.layer.cornerRadius = 5
        button.alpha = 0
        button.setTitle(title, for: .normal)
        button.setTitleColor(.secondaryBackgroundColor, for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 20) // 폰트 사이즈를 20으로 변경
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }

    static func createView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }
}
