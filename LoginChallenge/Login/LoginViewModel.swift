//
//  LoginViewModel.swift
//  LoginChallenge
//
//  Created by hicka04 on 2022/01/22.
//

import Foundation
import Combine

@MainActor
final class LoginViewModel: ObservableObject {
    @Published var idString: String?
    @Published var passwordString: String?
    @Published private(set) var isEnabledLoginButton: Bool = false

    init() {
        Publishers.CombineLatest(
            $idString.replaceNil(with: ""),
            $passwordString.replaceNil(with: "")
        ).map { idString, passwordString in
            !idString.isEmpty && !passwordString.isEmpty
        }.assign(to: &$isEnabledLoginButton)
    }
}
