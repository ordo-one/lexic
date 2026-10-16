import Lexic

extension ProjectionMacro {
    struct Configuration {
        let through: String
        let flatten: Bool
    }
}
extension ProjectionMacro.Configuration: ExpressionListDecodable {
    enum CodingKey: String, Sendable {
        case through
        case flatten
    }

    init(from list: inout ExpressionListDecoder<CodingKey>) throws {
        self.init(
            through: try list[.through]?.decode() ?? "",
            flatten: try list[.flatten]?.decode() ?? true
        )
    }
}
