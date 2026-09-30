import Lexic

extension Expressions {
    struct Base58: ExpressionDecodableFromStringLiteral {
        static let expectedDescription: String = "a base58 string literal"

        let string: String

        init?(_ string: String) {
            guard string.allSatisfy({ "123456789ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz".contains($0) }) else {
                return nil
            }
            self.string = string
        }
    }
}
