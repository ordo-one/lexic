import SwiftSyntax

extension ExprSyntax {
    func expecting<T>(
        _: T.Type
    ) throws(ExpressionDecodingError) -> T where T: ExprSyntaxProtocol {
        if  let node: T = self.as(T.self) {
            return node
        }

        let expected: String
        switch T.self {
        case is NilLiteralExprSyntax.Type:
            expected = "a nil literal"
        case is StringLiteralExprSyntax.Type:
            expected = "a string literal"
        case is BooleanLiteralExprSyntax.Type:
            expected = "a boolean literal"
        case is IntegerLiteralExprSyntax.Type:
            expected = "an integer literal"
        case is ArrayExprSyntax.Type:
            expected = "an array literal"
        case is DictionaryExprSyntax.Type:
            expected = "a dictionary literal"
        case is TupleExprSyntax.Type:
            expected = "a tuple literal"
        default:
            expected = "an instance of '\(String.init(reflecting: self))'"
        }

        throw .init(text: "expected \(expected)", node: self)
    }
}
