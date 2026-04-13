public import SwiftSyntax

extension Never: ExpressionDecodable {
    public init(from node: borrowing NilLiteralExprSyntax) throws(ExpressionDecodingError) {
        throw .init(text: "unexpected value", node: copy node)
    }
}
