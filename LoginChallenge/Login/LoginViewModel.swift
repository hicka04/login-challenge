//
//  LoginViewModel.swift
//  LoginChallenge
//
//  Created by hicka04 on 2022/01/22.
//

import Foundation
import Combine
import Entities
import APIServices
import Logging

enum LoginState {
    case loggingOut
    case loginProccessing
    case loggedIn
    case loginError(Error)

    var isLoginProcessing: Bool {
        switch self {
        case .loginProccessing: return true
        default: return false
        }
    }
}

@MainActor
final class LoginViewModel: ObservableObject {
    @Published var idString: String?
    @Published var passwordString: String?
    @Published private(set) var isEnabledLoginButton: Bool = false
    @Published private(set) var isEnabledIdFeild: Bool = true
    @Published private(set) var isEnabledPasswordFeild: Bool = true
    @Published private(set) var loginState: LoginState = .loggingOut

    private let logger: Logger = .init(label: String(reflecting: LoginViewModel.self))

    init() {
        Publishers.CombineLatest3(
            $idString.replaceNil(with: ""),
            $passwordString.replaceNil(with: ""),
            $loginState
        ).map { idString, passwordString, state in
            !idString.isEmpty && !passwordString.isEmpty && !state.isLoginProcessing
        }.assign(to: &$isEnabledLoginButton)

        $loginState.map { !$0.isLoginProcessing }.assign(to: &$isEnabledIdFeild)
        $loginState.map { !$0.isLoginProcessing }.assign(to: &$isEnabledPasswordFeild)
        $loginState.map { !$0.isLoginProcessing }.assign(to: &$isEnabledIdFeild)
    }

    func viewWillAppear() {
        loginState = .loggingOut
    }

    func loginButtonPressed() {
        guard !loginState.isLoginProcessing else {
            return
        }

        loginState = .loginProccessing

        Task {
            do {
                // API を叩いて処理を実行。
                try await AuthService.logInWith(id: idString!, password: passwordString!)

                loginState = .loggedIn
            } catch {
                logger.info("\(error)")

                loginState = .loginError(error)
            }
        }
    }
}
