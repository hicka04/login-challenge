import Foundation

public struct AuthenticationError: LocalizedError {
    public var errorDescription: String? { "認証エラー" }
    public var recoverySuggestion: String? { "再度ログインして下さい。" }

    public init() {
    }
}
