import Foundation

public enum ServerError: LocalizedError {
    case response(HTTPURLResponse)
    case `internal`(cause: Error)

    public var errorDescription: String? { "サーバーエラー" }
    public var recoverySuggestion: String? { "しばらくしてからもう一度お試し下さい。" }
}
