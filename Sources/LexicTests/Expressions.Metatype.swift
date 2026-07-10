import Lexic
import SwiftSyntax

extension Expressions {
    struct Metatype: ExpressionListDecodable {
        let type: TypeSyntax

        enum CodingKey: String, Sendable {
            case type
        }

        init(from list: inout ExpressionListDecoder<CodingKey>) throws {
            let expression: MetatypeExpression = try list[.type].decode()
            self.type = expression.type
        }
    }
}
