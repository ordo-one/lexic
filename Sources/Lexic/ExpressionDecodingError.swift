public import SwiftSyntax

@frozen public struct ExpressionDecodingError: Error {
    let text: String
    let node: ExprSyntax
}
extension ExpressionDecodingError: CustomStringConvertible {
    public var description: String { self.text }
}
