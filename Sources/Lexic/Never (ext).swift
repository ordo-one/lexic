import SwiftSyntax

extension Never: ExpressionDecodable {
    init(from node: borrowing NilLiteralExprSyntax) throws(ExpressionDecodingError) {
        throw .init(description: "unexpected value", node: ExprSyntax.init(node))
    }
}
