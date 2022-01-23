import Foundation

public struct NetworkError: LocalizedError {
    public let cause: Error

    public var errorDescription: String? { "ネットワークエラー" }
    public var recoverySuggestion: String? { "通信に失敗しました。ネットワークの状態を確認して下さい。" }
    
    public init(cause: Error) {
        self.cause = cause
    }
}
