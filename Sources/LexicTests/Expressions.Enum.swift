import Lexic

extension Expressions {
    enum Enum: String, ExpressionDecodableFromIdentifier {
        case a
        case `self`
    }
}
