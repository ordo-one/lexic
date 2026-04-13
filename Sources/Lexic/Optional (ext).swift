public import SwiftSyntax

extension Optional: ExpressionDecodable where Wrapped: ExpressionDecodable {
    public init(from node: borrowing ExprSyntax) throws(ExpressionDecodingError) {
        if  node.is(NilLiteralExprSyntax.self) {
            self = nil
        } else {
            self = try Wrapped.init(from: try node.expecting(Wrapped.Node.self))
        }
    }
}
