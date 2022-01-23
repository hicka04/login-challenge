import Foundation

public struct LoginError: LocalizedError {
    public var errorDescription: String? { "ログインエラー" }
    public var failureReason: String? { "IDまたはパスワードが正しくありません。" }

    public init() {
    }
}
