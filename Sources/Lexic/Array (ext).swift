import SwiftSyntax

extension Array: ExpressionDecodable where Element: ExpressionDecodable {
    init(from node: borrowing ArrayExprSyntax) throws(ExpressionDecodingError) {
        self = try node.elements.map { element throws(ExpressionDecodingError) in
            try Element.init(from: try element.expression.expecting(Element.Node.self))
        }
    }
}
