import Lexic

extension Expressions {
    struct Base58 {
        let string: String

        init?(_ string: String) {
            guard string.allSatisfy(Self.uses(_:)) else {
                return nil
            }
            self.string = string
        }
    }
}
extension Expressions.Base58: ExpressionDecodableFromStringLiteral {
    static var expectation: String { "a base58 string literal" }
}
extension Expressions.Base58 {
    private static func uses(_ character: Character) -> Bool {
        "123456789ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz".contains(character)
    }
}
