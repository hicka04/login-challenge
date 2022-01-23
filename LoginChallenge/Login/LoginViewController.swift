import UIKit
import Entities
import APIServices
import Logging
import SwiftUI
import Combine
import CombineCocoa

@MainActor
final class LoginViewController: UIViewController {
    @IBOutlet private var idField: UITextField!
    @IBOutlet private var passwordField: UITextField!
    @IBOutlet private var loginButton: UIButton!
    
    // String(reflecting:) はモジュール名付きの型名を取得するため。
    private let logger: Logger = .init(label: String(reflecting: LoginViewController.self))

    private let viewModel: LoginViewModel = .init()

    private var cancellables: Set<AnyCancellable> = []

    override func viewDidLoad() {
        super.viewDidLoad()

        idField.textPublisher.assign(to: &viewModel.$idString)
        passwordField.textPublisher.assign(to: &viewModel.$passwordString)

        viewModel.$isEnabledLoginButton.assign(to: \.isEnabled, on: loginButton).store(in: &cancellables)
        viewModel.$isEnabledIdFeild.assign(to: \.isEnabled, on: idField).store(in: &cancellables)
        viewModel.$isEnabledPasswordFeild.assign(to: \.isEnabled, on: passwordField).store(in: &cancellables)

        viewModel.$loginState.asyncSink { loginState in
            switch loginState {
            case .loggingOut(let error):
                guard let error = error else {
                    return
                }

                await self.dismiss(animated: true)

                let title: String
                let message: String
                switch error {
                case is LoginError:
                    title = "ログインエラー"
                    message = "IDまたはパスワードが正しくありません。"

                case is NetworkError:
                    title = "ネットワークエラー"
                    message = "通信に失敗しました。ネットワークの状態を確認して下さい。"

                case is ServerError:
                    title = "サーバーエラー"
                    message = "しばらくしてからもう一度お試し下さい。"

                default:
                    title = "システムエラー"
                    message = "エラーが発生しました。"
                }
                let alertController: UIAlertController = .init(
                    title: title,
                    message: message,
                    preferredStyle: .alert
                )
                alertController.addAction(.init(title: "閉じる", style: .default, handler: nil))
                self.present(alertController, animated: true, completion: nil)

            case .loginProccessing:
                // Activity Indicator を表示。
                let activityIndicatorViewController: ActivityIndicatorViewController = .init()
                activityIndicatorViewController.modalPresentationStyle = .overFullScreen
                activityIndicatorViewController.modalTransitionStyle = .crossDissolve
                await self.present(activityIndicatorViewController, animated: true)

            case .loggedIn:
                await self.dismiss(animated: true)
                
                // HomeView に遷移。
                let destination = UIHostingController(rootView: HomeView(dismiss: { [weak self] in
                    await self?.dismiss(animated: true)
                }))
                destination.modalPresentationStyle = .fullScreen
                destination.modalTransitionStyle = .flipHorizontal
                self.present(destination, animated: true, completion: nil)
            }
        }.store(in: &cancellables)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        viewModel.viewWillAppear()
    }
    
    // ログインボタンが押されたときにログイン処理を実行。
    @IBAction private func loginButtonPressed(_ sender: UIButton) {
        viewModel.loginButtonPressed()
    }
}
