public import SwiftSyntax

extension Bool: ExpressionDecodable {
    public init(from node: borrowing BooleanLiteralExprSyntax) {
        if  case .keyword(.true) = node.literal.tokenKind {
            self = true
        } else {
            self = false
        }
    }
}
