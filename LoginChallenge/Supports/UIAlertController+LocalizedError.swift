//
//  UIAlertController+LocalizedError.swift
//  LoginChallenge
//
//  Created by hicka04 on 2022/01/23.
//

import UIKit

extension UIAlertController {
    convenience init(localizedError: LocalizedError) {
        self.init(
            title: localizedError.errorDescription,
            message: localizedError.recoverySuggestion ?? localizedError.failureReason,
            preferredStyle: .alert
        )
    }
}
