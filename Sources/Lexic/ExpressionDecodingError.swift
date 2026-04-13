public import SwiftSyntax

@frozen public struct ExpressionDecodingError: Error {
    let text: String
    let node: Syntax

    private init(text: String, node: Syntax) {
        self.text = text
        self.node = node
    }
}
extension ExpressionDecodingError {
    init(text: String, node: some SyntaxProtocol) {
        self.init(text: text, node: Syntax.init(node))
    }
}
extension ExpressionDecodingError: CustomStringConvertible {
    public var description: String { self.text }
}
