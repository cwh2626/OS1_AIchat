//
//  UIViewController+Extensions.swift
//  chat_AI
//
//  Created by 조웅희 on 2023/09/05.
//

import UIKit

extension UIViewController {
    func showAlert(alertText: AlertMessage, alertType: AlertType, confirmAction: (() -> Void)? = nil, cancelAction: (() -> Void)? = nil) {
        let customAlertVC = CustomAlertViewController(
            alertText: alertText.rawValue,
            alertType: alertType,
            onConfirmAction: confirmAction,
            onCancelAction: cancelAction
        )

        present(customAlertVC, animated: true, completion: nil)
    }
}
