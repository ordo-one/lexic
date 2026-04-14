import Lexic

extension ExpressionDecodableTests {
    enum Enum: String, ExpressionDecodableFromIdentifier {
        case a
        case `self`
    }
}
