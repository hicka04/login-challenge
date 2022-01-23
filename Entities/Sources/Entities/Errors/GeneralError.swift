import Foundation

public struct GeneralError: LocalizedError {
    public let message: String
    public let cause: Error?

    public var errorDescription: String? { "システムエラー" }
    public var failureReason: String? { "エラーが発生しました。" }
    
    public init(message: String, cause: Error? = nil) {
        self.message = message
        self.cause = cause
    }
}
