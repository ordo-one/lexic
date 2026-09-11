import Lexic
import SwiftSyntax

extension DiscriminatedMacro {
    struct Configuration {
        let by: TypeSyntax?
        let backing: TypeSyntax?
    }
}
extension DiscriminatedMacro.Configuration: ExpressionListDecodable {
    enum CodingKey: String, Sendable {
        case by
        case backing
    }

    init(from list: inout ExpressionListDecoder<CodingKey>) throws {
        self.init(
            by: try list[.by]?.decode(to: MetatypeExpression?.self)?.type,
            backing: try list[.backing]?.decode(to: MetatypeExpression?.self)?.type,
        )
    }
}
