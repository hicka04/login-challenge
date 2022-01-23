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
    case loggingOut(Error?)
    case loginProccessing
    case loggedIn

    var isLoginProcessing: Bool {
        switch self {
        case .loginProccessing: return true
        default: return false
        }
    }

    mutating func updateStateIfNeeded(_ newState: Self) {
        switch (current: self, new: newState) {
        case (.loggingOut(nil), .loggingOut(nil)):
            return

        case (.loggingOut, .loginProccessing):
            break

        case (.loginProccessing, .loggedIn):
            break

        case (.loginProccessing, .loggingOut(let error)) where error != nil:
            break

        case (.loggedIn, .loggingOut(nil)):
            break

        default:
            assertionFailure()
        }

        self = newState
    }
}

@MainActor
final class LoginViewModel: ObservableObject {
    @Published var idString: String?
    @Published var passwordString: String?
    @Published private(set) var isEnabledLoginButton: Bool = false
    @Published private(set) var isEnabledIdFeild: Bool = true
    @Published private(set) var isEnabledPasswordFeild: Bool = true
    @Published private(set) var loginState: LoginState = .loggingOut(nil)

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
        loginState.updateStateIfNeeded(.loggingOut(nil))
    }

    func loginButtonPressed() {
        guard !loginState.isLoginProcessing else {
            return
        }

        loginState.updateStateIfNeeded(.loginProccessing)

        Task {
            do {
                // API を叩いて処理を実行。
                try await AuthService.logInWith(id: idString!, password: passwordString!)

                loginState = .loggedIn
            } catch {
                logger.info("\(error)")

                loginState.updateStateIfNeeded(.loggingOut(error))
            }
        }
    }
}
