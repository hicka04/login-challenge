//
//  HomeViewModel.swift
//  LoginChallenge
//
//  Created by hicka04 on 2022/01/24.
//

import Foundation
import Entities
import Logging
import APIServices

@MainActor
final class HomeViewModel: ObservableObject {
    @Published private(set) var user: User?
    @Published private(set) var isReloading: Bool = false

    @Published var presentsAuthenticationErrorAlert: Bool = false
    @Published var presentsNetworkErrorAlert: Bool = false
    @Published var presentsServerErrorAlert: Bool = false
    @Published var presentsSystemErrorAlert: Bool = false

    private let logger: Logger = .init(label: String(reflecting: HomeViewModel.self))

    func onAppear() {
        Task { [weak self] in
            await self?.loadUser()
        }
    }

    func reloadButtonTapped() {
        Task { [weak self] in
            await self?.loadUser()
        }
    }

    private func loadUser() async {
        // 処理が二重に実行されるのを防ぐ。
        if isReloading { return }

        // 処理中はリロードボタン押下を受け付けない。
        isReloading = true

        do {
            // API を叩いて User を取得。
            let user = try await UserService.currentUser()

            // 取得した情報を View に反映。
            self.user = user
        } catch let error as AuthenticationError {
            logger.info("\(error)")

            // エラー情報を表示。
            presentsAuthenticationErrorAlert = true
        } catch let error as NetworkError {
            logger.info("\(error)")

            // エラー情報を表示。
            presentsNetworkErrorAlert = true
        } catch let error as ServerError {
            logger.info("\(error)")

            // エラー情報を表示。
            presentsServerErrorAlert = true
        } catch {
            logger.info("\(error)")

            // エラー情報を表示。
            presentsSystemErrorAlert = true
        }

        // 処理が完了したのでリロードボタン押下を再度受け付けるように。
        isReloading = false
    }
}
