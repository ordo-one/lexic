import Lexic

extension BijectionMacro {
    struct Configuration {
        let `where`: String?
        let label: String
    }
}
extension BijectionMacro.Configuration: ExpressionListDecodable {
    enum CodingKey: String, Sendable {
        case `where`
        case label
    }

    init(from list: inout ExpressionListDecoder<CodingKey>) throws {
        self.init(
            where: try list[.where]?.decode(),
            label: try list[.label]?.decode() ?? "_"
        )
    }
}
