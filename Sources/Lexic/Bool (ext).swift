import SwiftSyntax

extension Bool: ExpressionDecodable {
    init(from node: borrowing BooleanLiteralExprSyntax) {
        if  case .keyword(.true) = node.literal.tokenKind {
            self = true
        } else {
            self = false
        }
    }
}
