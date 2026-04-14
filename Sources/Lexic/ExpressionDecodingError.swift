public import SwiftSyntax

@frozen public struct ExpressionDecodingError: Error {
    public let text: String
    public let node: Syntax

    private init(text: String, node: Syntax) {
        self.text = text
        self.node = node
    }
}
extension ExpressionDecodingError {
    public init(text: String, node: some SyntaxProtocol) {
        self.init(text: text, node: Syntax.init(node))
    }
}
extension ExpressionDecodingError: MacroExpansionError {}
extension ExpressionDecodingError: CustomStringConvertible {
    public var description: String { self.text }
}
