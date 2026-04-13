import SwiftSyntax

struct ExpressionDecodingError: Error, CustomStringConvertible {
    let description: String
    let node: ExprSyntax
}
